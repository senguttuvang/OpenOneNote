import AppKit
import Foundation
import MarkdownNotes

/// Validation-only delegated CLI adapter. It never exports a token and can write only its newly-created synthetic page.
private actor ProbeRemote: OneNoteRemote {
    let cli: String
    let directory: URL
    let fingerprint: String
    var pageID: String?
    var online = true
    init(cli: String, directory: URL, fingerprint: String) { self.cli = cli; self.directory = directory; self.fingerprint = fingerprint }
    func setOnline(_ value: Bool) { online = value }
    func register(_ id: String) { pageID = id }
    private func run(_ arguments: [String]) throws -> String {
        try NativeProcessRunner().run(cli, arguments, at: directory, capture: true, timeout: 90, allowFailure: false, environment: [:]).stdout
    }
    func request(_ url: URL, method: String = "get", body: Data? = nil, type: String = "application/json") throws -> Data {
        guard online else { throw URLError(.notConnectedToInternet) }
        guard url.scheme == "https", url.host == "graph.microsoft.com", url.user == nil, url.password == nil,
              url.port == nil, url.fragment == nil, url.path.hasPrefix("/v1.0/"), url.path.contains("/onenote/"),
              !(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []).contains(where: { $0.name.lowercased().contains("token") || $0.name.lowercased().contains("auth") }) else { throw DevelopmentError.invalidArguments("Untrusted validation URL") }
        let status = try run(["status", "--output", "json"])
        guard Self.identity(status) == fingerprint else { throw DevelopmentError.invalidArguments("Delegated CLI identity changed during the synthetic probe") }
        let output = directory.appendingPathComponent("response-\(UUID()).bin")
        var arguments = ["request", "--url", url.absoluteString, "--method", method, "--filePath", output.path, "--output", "none"]
        let input = directory.appendingPathComponent("request-\(UUID()).txt")
        defer { try? FileManager.default.removeItem(at: output); try? FileManager.default.removeItem(at: input) }
        if let body { try body.write(to: input, options: .atomic); arguments += ["--content-type", type, "--body", "@" + input.path] }
        _ = try run(arguments)
        return FileManager.default.fileExists(atPath: output.path) ? try Data(contentsOf: output) : Data()
    }
    static func identity(_ status: String) -> String {
        guard let data = status.data(using: .utf8), let value = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return "" }
        guard ["browser", "devicecode"].contains((value["authType"] as? String ?? "").lowercased()) else { return "" }
        let fields = ["connectedAs", "appId", "appTenant"].compactMap { value[$0] as? String }
        return fields.count == 3 ? MarkdownVault.hash(fields.joined(separator: "\n").lowercased()) : ""
    }
    func fetch(_ identity: PageIdentity) throws -> RemotePage {
        guard identity.pageID == pageID else { throw DevelopmentError.invalidArguments("Probe cannot read a pre-existing page") }
        let base = try endpoint("pages/\(identity.pageID)")
        let item = try JSONDecoder().decode(GraphItem.self, from: request(base))
        let content = try request(endpoint("pages/\(identity.pageID)/content?includeIDs=true"))
        guard let html = String(data: content, encoding: .utf8) else { throw DevelopmentError.invalidArguments("Graph content is not UTF-8") }
        return RemotePage(id: item.id, title: item.title ?? "Synthetic", html: html)
    }
    func resource(_ url: URL) throws -> Data {
        guard url.path.contains("/onenote/resources/"), url.path.hasSuffix("/$value") else { throw DevelopmentError.invalidArguments("Probe resource is not a OneNote resource") }
        return try request(url)
    }
    func update(_ identity: PageIdentity, commands: [PageCommand], parts: [BinaryPart]) throws {
        guard identity.pageID == pageID else { throw DevelopmentError.invalidArguments("Probe cannot update a pre-existing page") }
        var mapped = commands
        let resources = Dictionary(uniqueKeysWithValues: parts.map { ($0.name, $0) })
        for index in mapped.indices {
            mapped[index].content = try HTMLAssetRewriter.rewrite(mapped[index].content) { reference, image in
                guard image, reference.hasPrefix("name:"), let part = resources[String(reference.dropFirst(5))], part.mimeType.hasPrefix("image/") else {
                    throw DevelopmentError.invalidArguments("CLI probe supports documented image data URLs; binary source attachments require the native transport")
                }
                return "data:\(part.mimeType);base64," + part.bytes.base64EncodedString()
            }
        }
        _ = try request(endpoint("pages/\(identity.pageID)/content"), method: "patch", body: JSONEncoder().encode(mapped))
    }
    func create(_ path: String, body: Data, type: String = "application/json") throws -> GraphItem {
        try JSONDecoder().decode(GraphItem.self, from: request(endpoint(path), method: "post", body: body, type: type))
    }
    func endpoint(_ path: String) throws -> URL {
        let allowed = CharacterSet.urlPathAllowed.subtracting(CharacterSet(charactersIn: "?#"))
        let pieces = path.components(separatedBy: "?")
        guard let encoded = pieces[0].addingPercentEncoding(withAllowedCharacters: allowed),
              let url = URL(string: "https://graph.microsoft.com/v1.0/me/onenote/" + encoded + (pieces.count == 2 ? "?" + pieces[1] : "")) else { throw DevelopmentError.invalidArguments("Invalid probe endpoint") }
        return url
    }
}

extension DevelopmentWorkflow {
    public func graphProbe(cli: String, output: URL) async throws {
        guard cli.hasPrefix("/"), FileManager.default.isExecutableFile(atPath: cli), !FileManager.default.fileExists(atPath: output.path) else { throw DevelopmentError.invalidArguments("Supply an installed sanctioned CLI and a new synthetic output directory") }
        let status = try run(cli, ["status", "--output", "json"], capture: true).stdout
        let fingerprint = ProbeRemote.identity(status)
        guard !fingerprint.isEmpty else { throw DevelopmentError.invalidArguments("No usable delegated CLI identity") }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        let remote = ProbeRemote(cli: cli, directory: output, fingerprint: fingerprint)
        var registry = ["classification": "synthetic-only; CLI delegated transport, not native MSAL", "state": "started"]
        registry["sourceRevision"] = try run("git", ["rev-parse", "HEAD"], capture: true).stdout
        registry["sourceState"] = try run("git", ["status", "--porcelain", "--", "Package.swift", "Package.resolved", "Sources"], capture: true).stdout.isEmpty ? "committed" : "working-tree"
        func record() throws { try JSONEncoder().encode(registry).write(to: output.appendingPathComponent("synthetic-registry.json"), options: .atomic) }
        try record()
        let name = "O2N Synthetic CLI Graph Probe " + String(UUID().uuidString.prefix(8))
        let notebook = try await remote.create("notebooks", body: JSONEncoder().encode(["displayName": name]))
        registry["notebookID"] = notebook.id; try record()
        let section = try await remote.create("notebooks/\(notebook.id)/sections", body: JSONEncoder().encode(["displayName": "Markdown validation"]))
        registry["sectionID"] = section.id; try record()
        let input = "<html><head><title>\(name)</title></head><body><div><p>Local base</p><p>Remote base</p><p><b>Bold</b> and <i>italic</i></p><table><tr><td>Name</td><td>State</td></tr><tr><td>O2N</td><td>Ready</td></tr></table></div></body></html>"
        let page = try await remote.create("sections/\(section.id)/pages", body: Data(input.utf8), type: "text/html")
        registry["pageID"] = page.id; try record(); await remote.register(page.id)
        let identity = PageIdentity(pageID: page.id, accountKey: fingerprint)
        let vault = try MarkdownVault(root: output.appendingPathComponent("vault"))
        let sync = NoteSync(vault: vault, remote: remote)
        var ledger = try await sync.open(identity)
        _ = try await sync.save(ledger.id, markdown: vault.markdown(ledger).replacingOccurrences(of: "Local base", with: "Local changed"))
        ledger = try await sync.sync(ledger.id)
        registry["samePageFormattingTable"] = "Graph readback passed"; try record()
        func changeRemote(_ original: String, _ changed: String) async throws {
            let page = try await remote.fetch(identity)
            let document = try HTMLConversion().decode(page.html)
            guard let block = document.blocks.first(where: { $0.editable && $0.node.text == original }) else { throw DevelopmentError.invalidArguments("Synthetic remote anchor missing") }
            try await remote.update(identity, commands: [PageCommand(target: block.target, action: "replace", content: "<p>" + changed + "</p>")], parts: [])
        }
        try await changeRemote("Remote base", "Remote external")
        ledger = try await sync.sync(ledger.id, allowPush: false)
        guard try vault.markdown(ledger).contains("Remote external") else { throw DevelopmentError.invalidArguments("Live refresh failed") }
        await remote.setOnline(false)
        _ = try await sync.save(ledger.id, markdown: vault.markdown(ledger).replacingOccurrences(of: "Local changed", with: "Local offline"))
        do { _ = try await sync.sync(ledger.id); throw DevelopmentError.invalidArguments("Offline probe unexpectedly succeeded") } catch is URLError { }
        await remote.setOnline(true)
        try await changeRemote("Remote external", "Remote disjoint")
        ledger = try await sync.sync(ledger.id)
        let merged = try vault.markdown(ledger)
        guard merged.contains("Local offline"), merged.contains("Remote disjoint") else { throw DevelopmentError.invalidArguments("Live disjoint merge failed") }
        _ = try await sync.save(ledger.id, markdown: merged.replacingOccurrences(of: "Local offline", with: "Local overlap"))
        try await changeRemote("Local offline", "Remote overlap")
        do { _ = try await sync.sync(ledger.id); throw DevelopmentError.invalidArguments("Overlap was not rejected") } catch NotesError.conflict { }
        guard try vault.load(ledger.id).remoteRecovery != nil else { throw DevelopmentError.invalidArguments("Live conflict recovery missing") }
        registry["externalRefreshOfflineReconnectDisjointOverlap"] = "passed"; registry["state"] = "passed; native MSAL/image/diagram/native OneNote visual acceptance remain separate"
        try record()
        print("Real delegated CLI Graph probe passed: same-page formatted/table readback, external refresh, offline reconnect, disjoint merge and overlap preservation. Fixtures retained locally. This does not prove native MSAL or image/diagram transport.")
    }
}
