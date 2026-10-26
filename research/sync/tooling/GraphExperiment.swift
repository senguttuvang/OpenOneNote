import Foundation
import Darwin

// Uses the sanctioned m365 CLI's own refresh-capable authentication. No token access.
// All writes require either new-object creation or an ID in this run's owned registry.
struct ProbeFailure: Error { let message: String }
let fm = FileManager.default
let root = URL(fileURLWithPath: fm.currentDirectoryPath)
let privateDirectory = root.appendingPathComponent("scratch/sync")
try fm.createDirectory(at: privateDirectory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
let registryURL = privateDirectory.appendingPathComponent("owned-objects.json")
let logURL = privateDirectory.appendingPathComponent("graph-events.jsonl")
let base = "https://graph.microsoft.com/v1.0/me/onenote"
let title = "OpenOneNote Sync Research 20261026 Synthetic"
let mode = CommandLine.arguments.dropFirst().first ?? "inspect"

@MainActor func protectedWrite(_ data: Data, to url: URL) throws {
    try data.write(to: url, options: .atomic)
    try fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
}
func json(_ value: Any) throws -> String {
    String(decoding: try JSONSerialization.data(withJSONObject: value, options: [.sortedKeys]), as: UTF8.self)
}
@MainActor func event(_ value: [String: Any]) throws {
    let line = try json(value) + "\n"
    if !fm.fileExists(atPath: logURL.path) { try protectedWrite(Data(), to: logURL) }
    let handle = try FileHandle(forWritingTo: logURL)
    try handle.seekToEnd()
    try handle.write(contentsOf: Data(line.utf8))
    try handle.close()
    print(line, terminator: "")
}
func allowsRequestURL(_ method: String, _ url: String, template: String) -> Bool {
    let parsedURL = URL(string: url)
    let isOwnedResourceRead = method == "get" && template == "/me/onenote/resources/{synthetic-resource}/$value" && parsedURL?.path.contains("/onenote/resources/") == true
    let isAccountProbe = method == "get" && template == "/me?identity-metadata-only" && url == "https://graph.microsoft.com/v1.0/me?$select=userPrincipalName"
    return parsedURL?.scheme == "https" && parsedURL?.host == "graph.microsoft.com" && parsedURL?.user == nil && parsedURL?.password == nil && (parsedURL?.port == nil || parsedURL?.port == 443) && (url.hasPrefix(base + "/") || isOwnedResourceRead || isAccountProbe)
}
@MainActor func request(_ method: String, _ url: String, template: String, body: String? = nil, html: Bool = false, contentType: String? = nil, accept: String? = nil, download: URL? = nil) throws -> Data {
    guard allowsRequestURL(method, url, template: template) else { throw ProbeFailure(message: "Rejected URL") }
    let process = Process()
    process.executableURL = fm.homeDirectoryForCurrentUser.appendingPathComponent(".bun/bin/m365")
    let expectsHTML = method == "get" && template.contains("/content")
    var arguments = ["request", "--method", method, "--url", url, "--output", expectsHTML ? "text" : "json"]
    var bodyFile: URL?
    if let body {
        var argument = body
        if body.hasPrefix("--") {
            let file = privateDirectory.appendingPathComponent("body-\(UUID()).private")
            try protectedWrite(Data(body.utf8), to: file)
            bodyFile = file
            argument = "@" + file.path
        }
        arguments += ["--body", argument, "--content-type", contentType ?? (html ? "text/html" : "application/json")]
    }
    defer { if let bodyFile { try? fm.removeItem(at: bodyFile) } }
    if let accept { arguments += ["--accept", accept] }
    else if expectsHTML { arguments += ["--accept", "text/html"] }
    if let download { arguments += ["--filePath", download.path] }
    process.arguments = arguments
    var environment = ProcessInfo.processInfo.environment
    environment["CLIMICROSOFT365_NOUPDATE"] = "1"
    process.environment = environment
    let stdout = privateDirectory.appendingPathComponent("response-\(UUID()).private")
    let stderr = privateDirectory.appendingPathComponent("error-\(UUID()).private")
    try protectedWrite(Data(), to: stdout)
    try protectedWrite(Data(), to: stderr)
    let out = try FileHandle(forWritingTo: stdout), err = try FileHandle(forWritingTo: stderr)
    process.standardOutput = out
    process.standardError = err
    defer { try? out.close(); try? err.close(); try? fm.removeItem(at: stdout); try? fm.removeItem(at: stderr) }
    let began = Date()
    try process.run()
    let deadline = ProcessInfo.processInfo.systemUptime + 90
    while process.isRunning && ProcessInfo.processInfo.systemUptime < deadline { Thread.sleep(forTimeInterval: 0.025) }
    if process.isRunning {
        process.terminate()
        Thread.sleep(forTimeInterval: 0.25)
        if process.isRunning { kill(process.processIdentifier, SIGKILL) }
        process.waitUntilExit()
        try event(["method": method, "pathTemplate": template, "outcome": "timeout-unknown-write-state-no-retry", "at": ISO8601DateFormatter().string(from: began)])
        throw ProbeFailure(message: "CLI deadline exceeded; reconcile before retry")
    }
    process.waitUntilExit()
    try out.synchronize(); try err.synchronize()
    let output = try Data(contentsOf: stdout)
    let errors = try String(contentsOf: stderr, encoding: .utf8)
    // Emit only an allowlisted error code, never the CLI's raw diagnostics or URLs.
    let codes = ["401", "403", "404", "429", "consent_required", "invalid_grant", "Unauthorized", "Forbidden", "BadRequest"]
    let expression = try NSRegularExpression(pattern: "[\"']?code[\"']?\\s*:\\s*[\"']?([A-Za-z0-9_.-]{1,50})")
    let codeMatch = expression.firstMatch(in: errors, range: NSRange(errors.startIndex..., in: errors))
    let parsedCode = codeMatch.flatMap { Range($0.range(at: 1), in: errors) }.map { String(errors[$0]) }
    let errorCode = parsedCode ?? codes.first(where: errors.contains) ?? "unspecified"
    if process.terminationStatus != 0 {
        let subjects = ["multipart", "boundary", "target", "absolute", "Content-Type", "parse", "option", "Cannot", "invalid", "JSON", "unsupported"]
        try event(["diagnosticSubjects": subjects.filter { errors.localizedCaseInsensitiveContains($0) }, "diagnosticCode": errorCode])
    }
    try event(["method": method, "pathTemplate": template, "outcome": process.terminationStatus == 0 ? "cli-success-http-status-not-exposed" : "cli-failure-\(errorCode)", "milliseconds": Int(Date().timeIntervalSince(began) * 1000), "at": ISO8601DateFormatter().string(from: began), "responseBytes": output.count])
    guard process.terminationStatus == 0 else { throw ProbeFailure(message: "CLI request failed: \(errorCode)") }
    return output
}
func object(_ data: Data) throws -> [String: Any] {
    guard let value = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { throw ProbeFailure(message: "Expected object") }
    return value
}
var registry: [String: String] = fm.fileExists(atPath: registryURL.path) ? try JSONDecoder().decode([String: String].self, from: Data(contentsOf: registryURL)) : [:]
@MainActor func save(_ kind: String, _ response: Data) throws -> String {
    let value = try object(response)
    guard let id = value["id"] as? String else { throw ProbeFailure(message: "Write returned no ID; stop and reconcile") }
    registry[kind] = id
    try protectedWrite(try JSONEncoder().encode(registry), to: registryURL)
    return id
}
@MainActor func owned(_ kind: String) throws -> String {
    guard registry["notebookTitle"] == title, let id = registry[kind] else { throw ProbeFailure(message: "No owned synthetic object") }
    return id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed.subtracting(CharacterSet(charactersIn: "/?#")))!
}
@MainActor func readProjection(_ label: String, kind: String = "page") throws {
    let page = try owned(kind)
    let response = try request("get", base + "/pages/\(page)/content?includeIDs=true", template: "/me/onenote/pages/{synthetic-page}/content?includeIDs=true")
    let html = String(decoding: response, as: UTF8.self)
    try protectedWrite(response, to: privateDirectory.appendingPathComponent("\(label).private.html"))
    let styles = try NSRegularExpression(pattern: "style=\"([^\"]*(?:position:absolute|border|font-size)[^\"]*)\"").matches(in: html, range: NSRange(html.startIndex..., in: html)).compactMap { Range($0.range(at: 1), in: html).map { String(html[$0]) } }
    let tags = ["<table", "<ol", "<ul", "<strong", "<b>", "<img", "<object"]
    try event(["projection": label, "syntheticMarkerPresent": html.contains("OON-SYNC-20261026"), "remoteMarkerPresent": html.contains("REMOTE-BETA"), "nativeMarkerPresent": html.contains("NATIVE-GAMMA"), "writerAPresent": html.contains("WRITER-A"), "writerBPresent": html.contains("WRITER-B"), "styles": styles, "tagCounts": Dictionary(uniqueKeysWithValues: tags.map { ($0, html.components(separatedBy: $0).count - 1) })])
}
@MainActor func downloadAttachment() throws {
    _ = try owned("attachmentPage")
    let text = "OON-SYNC-20261026 synthetic attachment payload\n"
    let response = try String(contentsOf: privateDirectory.appendingPathComponent("attachment.private.html"), encoding: .utf8)
    let regex = try NSRegularExpression(pattern: "data=\"(https://graph\\.microsoft\\.com/v1\\.0/[^\"]+/onenote/resources/[^\"]+)\"")
    guard let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)), let range = Range(match.range(at: 1), in: response) else { throw ProbeFailure(message: "No owned attachment resource in synthetic projection") }
    let url = String(response[range]).replacingOccurrences(of: "&amp;", with: "&")
    let destination = privateDirectory.appendingPathComponent("attachment.private.txt")
    try protectedWrite(Data(), to: destination)
    _ = try request("get", url, template: "/me/onenote/resources/{synthetic-resource}/$value", accept: "application/octet-stream", download: destination)
    let bytes = try Data(contentsOf: destination)
    try event(["attachmentBytes": bytes.count, "exactSyntheticPayload": bytes == Data(text.utf8)])
}
do {
    switch mode {
    case "self-test":
        let cases: [(String, String, String, Bool)] = [
            ("get", "http://graph.microsoft.com/v1.0/me/onenote/pages/x", "read", false),
            ("get", "https://graph.microsoft.com.evil.invalid/v1.0/me/onenote/pages/x", "read", false),
            ("get", "https://user:password@graph.microsoft.com/v1.0/me/onenote/pages/x", "read", false),
            ("get", "https://graph.microsoft.com/v1.0/users('synthetic')/onenote/resources/x/$value", "/me/onenote/resources/{synthetic-resource}/$value", true),
            ("post", "https://graph.microsoft.com/v1.0/users('synthetic')/onenote/resources/x/$value", "/me/onenote/resources/{synthetic-resource}/$value", false),
            ("get", base + "/pages/synthetic/content", "read", true),
            ("get", "https://graph.microsoft.com/v1.0/me/messages", "read", false)
        ]
        for (method, url, template, expected) in cases {
            guard allowsRequestURL(method, url, template: template) == expected else { throw ProbeFailure(message: "Request scope self-test failed") }
        }
        do { _ = try owned("unregistered-object"); throw ProbeFailure(message: "Ownership self-test failed") }
        catch let error as ProbeFailure where error.message == "No owned synthetic object" { }
        try event(["requestScopeCasesPassed": cases.count, "unknownObjectRejected": true, "networkRequestsPerformed": 0])
    case "account":
        guard let expected = ProcessInfo.processInfo.environment["OON_EXPECTED_PRINCIPAL"], !expected.isEmpty else { throw ProbeFailure(message: "Expected principal must be supplied privately in OON_EXPECTED_PRINCIPAL") }
        let response = try object(request("get", "https://graph.microsoft.com/v1.0/me?$select=userPrincipalName", template: "/me?identity-metadata-only"))
        let principal = (response["userPrincipalName"] as? String ?? "").lowercased()
        try event(["expectedPrincipalCaseInsensitive": principal == expected.lowercased(), "guestPrincipal": principal.contains("#ext#"), "identityValuesRetained": false])
    case "provision":
        guard registry.isEmpty else { throw ProbeFailure(message: "Registry exists; refusing duplicate provisioning") }
        registry["notebookTitle"] = title
        let response = try request("post", base + "/notebooks", template: "/me/onenote/notebooks", body: json(["displayName": title]))
        let notebook = try save("notebook", response)
        let section = try save("section", request("post", base + "/notebooks/\(notebook)/sections", template: "/me/onenote/notebooks/{synthetic-notebook}/sections", body: json(["displayName": "Synthetic Storage Fixtures"])))
        let html = "<html><head><title>OON-SYNC-20261026 Canvas Fixture</title></head><body data-absolute-enabled=\"true\"><div data-id=\"fixture-main\" style=\"position:absolute;left:48px;top:120px;width:720px;font-family:Calibri;font-size:14pt\"><p data-id=\"fixture-text\">OON-SYNC-20261026 ALPHA English தமிழ் 😀 <b>bold</b> <i>italic</i></p><ul><li>synthetic bullet one</li><li>synthetic bullet two</li></ul><table style=\"border:1px solid black\"><tr><td>synthetic A</td><td>synthetic B</td></tr></table></div><div data-id=\"fixture-side\" style=\"position:absolute;left:820px;top:250px;width:280px\"><p>OON-SYNC-20261026 SIDE</p></div></body></html>"
        _ = try save("page", request("post", base + "/sections/\(section)/pages", template: "/me/onenote/sections/{synthetic-section}/pages", body: html, html: true))
        try readProjection("initial")
    case "append":
        let page = try owned("page")
        _ = try request("patch", base + "/pages/\(page)/content", template: "/me/onenote/pages/{synthetic-page}/content", body: json([["target": "body", "action": "append", "content": "<p>OON-SYNC-20261026 REMOTE-BETA external Graph edit</p>"]]))
        try readProjection("remote-beta")
    case "inspect": try readProjection("readback")
    case "reconcile":
        let section = try owned("section")
        var next: String? = base + "/sections/\(section)/pages?$select=id,title,lastModifiedDateTime"
        var total = 0, foreignTitles = 0, attachmentPages = 0
        while let url = next {
            let response = try object(request("get", url, template: "/me/onenote/sections/{synthetic-section}/pages?metadata-only"))
            guard let pages = response["value"] as? [[String: Any]] else { throw ProbeFailure(message: "Expected page collection") }
            for page in pages {
                total += 1
                let name = page["title"] as? String ?? ""
                if !name.hasPrefix("OON-SYNC-20261026") { foreignTitles += 1 }
                if name == "OON-SYNC-20261026 Attachment Fixture" { attachmentPages += 1 }
            }
            next = response["@odata.nextLink"] as? String
        }
        try event(["ownedSectionPages": total, "unexpectedTitles": foreignTitles, "attachmentFixturePages": attachmentPages])
    case "outer-replace":
        let page = try owned("page")
        let data = try request("get", base + "/pages/\(page)/content?includeIDs=true", template: "/me/onenote/pages/{synthetic-page}/content?includeIDs=true")
        let projection = String(decoding: data, as: UTF8.self)
        let tagRegex = try NSRegularExpression(pattern: "<div[^>]*data-id=\"fixture-main\"[^>]*>")
        guard let match = tagRegex.firstMatch(in: projection, range: NSRange(projection.startIndex..., in: projection)), let range = Range(match.range, in: projection) else { throw ProbeFailure(message: "Owned container missing") }
        let tag = String(projection[range])
        let idRegex = try NSRegularExpression(pattern: "\\sid=\"([^\"]+)\"")
        guard let idMatch = idRegex.firstMatch(in: tag, range: NSRange(tag.startIndex..., in: tag)), let idRange = Range(idMatch.range(at: 1), in: tag) else { throw ProbeFailure(message: "Fresh generated container ID missing") }
        _ = try request("patch", base + "/pages/\(page)/content", template: "/me/onenote/pages/{synthetic-page}/content", body: json([["target": String(tag[idRange]), "action": "replace", "content": "<div data-id=\"fixture-main\" style=\"position:absolute;left:48px;top:120px;width:750px\"><p>OON-SYNC-20261026 OUTER-REPLACE</p></div>"]]))
        try readProjection("after-outer-replace")
    case "attachment":
        guard registry["attachmentPage"] == nil else { throw ProbeFailure(message: "Attachment page exists; refusing duplicate") }
        let section = try owned("section")
        let boundary = "OONBoundary20261026"
        let text = "OON-SYNC-20261026 synthetic attachment payload\n"
        let html = "<html><head><title>OON-SYNC-20261026 Attachment Fixture</title></head><body><p>OON-SYNC-20261026 attachment</p><object data-attachment=\"synthetic.txt\" type=\"text/plain\" data=\"name:fixture-file\"></object></body></html>"
        let body = "--\(boundary)\r\nContent-Disposition: form-data; name=\"Presentation\"\r\nContent-Type: text/html\r\n\r\n\(html)\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"fixture-file\"\r\nContent-Type: text/plain\r\n\r\n\(text)\r\n--\(boundary)--\r\n"
        _ = try save("attachmentPage", request("post", base + "/sections/\(section)/pages", template: "/me/onenote/sections/{synthetic-section}/pages", body: body, contentType: "multipart/form-data; boundary=\(boundary)"))
        try readProjection("attachment", kind: "attachmentPage")
        try downloadAttachment()
    case "download-attachment": try downloadAttachment()
    case "stale-writes":
        guard registry["staleProbeStarted"] == nil else { throw ProbeFailure(message: "Stale probe already started; refusing duplicate") }
        registry["staleProbeStarted"] = "true"
        try protectedWrite(try JSONEncoder().encode(registry), to: registryURL)
        let page = try owned("page")
        let url = base + "/pages/\(page)/content"
        _ = try request("patch", url, template: "/me/onenote/pages/{synthetic-page}/content", body: json([["target": "body", "action": "append", "content": "<p data-id=\"fixture-conflict\">OON-SYNC-20261026 CONFLICT-BASE</p>"]]))
        let template = "/me/onenote/pages/{synthetic-page}/content?includeIDs=true"
        let a = String(decoding: try request("get", url + "?includeIDs=true", template: template), as: UTF8.self)
        let b = String(decoding: try request("get", url + "?includeIDs=true", template: template), as: UTF8.self)
        func conflictID(_ html: String) throws -> String {
            let tagRegex = try NSRegularExpression(pattern: "<p[^>]*data-id=\"fixture-conflict\"[^>]*>")
            guard let match = tagRegex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)), let range = Range(match.range, in: html) else { throw ProbeFailure(message: "Conflict paragraph missing") }
            let tag = String(html[range])
            let idRegex = try NSRegularExpression(pattern: "\\sid=\"([^\"]+)\"")
            guard let match = idRegex.firstMatch(in: tag, range: NSRange(tag.startIndex..., in: tag)), let range = Range(match.range(at: 1), in: tag) else { throw ProbeFailure(message: "Conflict generated ID missing") }
            return String(tag[range])
        }
        let aID = try conflictID(a), bID = try conflictID(b)
        try event(["staleBaseIDsEqual": aID == bID, "experiment": "sequential-stale-read-replace-not-simultaneous-native-edits"])
        _ = try request("patch", url, template: "/me/onenote/pages/{synthetic-page}/content", body: json([["target": aID, "action": "replace", "content": "<p>OON-SYNC-20261026 WRITER-A</p>"]]))
        try readProjection("writer-a")
        do {
            _ = try request("patch", url, template: "/me/onenote/pages/{synthetic-page}/content", body: json([["target": bID, "action": "replace", "content": "<p>OON-SYNC-20261026 WRITER-B stale base</p>"]]))
            try event(["staleWriterAccepted": true])
        } catch {
            try event(["staleWriterAccepted": false, "failureMeaning": "CLI-failure-does-not-establish-coherency-conflict"])
        }
        try readProjection("stale-final")
    default: throw ProbeFailure(message: "Expected provision, append, inspect, reconcile, outer-replace, or attachment")
    }
} catch let error as ProbeFailure {
    FileHandle.standardError.write(Data("Probe stopped: \(error.message)\n".utf8))
    exit(1)
} catch {
    FileHandle.standardError.write(Data("Probe stopped: local decode or I/O failure; raw diagnostics suppressed\n".utf8))
    exit(1)
}
