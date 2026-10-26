import Foundation
import CryptoKit

// Exports only allowlisted probe outputs and synthetic HTML. No cache/account files.
let fm = FileManager.default
let root = URL(fileURLWithPath: fm.currentDirectoryPath)
let source = root.appendingPathComponent("scratch/sync")
let destination = root.appendingPathComponent("research/sync/runtime")
try fm.createDirectory(at: destination, withIntermediateDirectories: true)
func transform(_ text: String, pattern: String, replacement: (String) -> String) throws -> String {
    let regex = try NSRegularExpression(pattern: pattern)
    var result = text
    for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).reversed() {
        guard let range = Range(match.range, in: result) else { throw CocoaError(.coderReadCorrupt) }
        result.replaceSubrange(range, with: replacement(String(result[range])))
    }
    return result
}
func safeURL(_ value: String) -> String {
    guard let url = URL(string: value.replacingOccurrences(of: "&amp;", with: "&")), url.host == "graph.microsoft.com" else { return "https://redacted.invalid/{resource}" }
    let known = Set(["v1.0", "me", "users", "onenote", "resources", "pages", "notebooks", "sections", "content", "$value"])
    return "https://graph.microsoft.com/" + url.path.split(separator: "/").map { known.contains(String($0)) ? String($0) : "{synthetic-id}" }.joined(separator: "/")
}
let files = ["storage-before.json", "storage-after-graph.json", "native-observation.json", "native-final.json", "graph-events.jsonl"]
for name in files {
    let data = try Data(contentsOf: source.appendingPathComponent(name))
    try data.write(to: destination.appendingPathComponent(name))
}
let schema = try JSONSerialization.jsonObject(with: Data(contentsOf: source.appendingPathComponent("storage-schema.json"))) as! [String: Any]
var compact = schema
let schemas = schema["schemas"] as! [[String: Any]]
var unique: [String: [String: Any]] = [:]
for entry in schemas {
    let canonical = try JSONSerialization.data(withJSONObject: entry, options: [.sortedKeys])
    unique[String(decoding: canonical, as: UTF8.self)] = entry
}
compact["schemas"] = unique.sorted { $0.key < $1.key }.map(\.value)
compact["databasesExamined"] = schemas.count
try JSONSerialization.data(withJSONObject: compact, options: [.prettyPrinted, .sortedKeys]).write(to: destination.appendingPathComponent("storage-schema.json"))
for name in ["initial", "readback", "remote-beta", "after-outer-replace", "attachment", "stale-final"] {
    let file = source.appendingPathComponent(name + ".private.html")
    guard fm.fileExists(atPath: file.path) else { continue }
    var text = try String(contentsOf: file, encoding: .utf8)
    guard text.contains("OON-SYNC-20261026"), !text.contains("<script") else { throw CocoaError(.coderReadCorrupt) }
    text = try transform(text, pattern: "(?:https?|onenote):[^\"<>\\s]+", replacement: safeURL)
    text = try transform(text, pattern: "(?<!data-)\\bid=\"[^\"]*\"", replacement: { _ in "id=\"{generated-element-id}\"" })
    // Graph emits native identifiers in data-id for generated outlines too.
    text = try transform(text, pattern: "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}", replacement: { _ in "{redacted-guid}" })
    try Data(text.utf8).write(to: destination.appendingPathComponent(name + ".sanitized.html"))
}
let log = source.appendingPathComponent("csi-analysis/analysis.log")
let rawLog = try String(contentsOf: log, encoding: .utf8)
let sanitizedLog = rawLog.replacingOccurrences(of: root.path, with: "{worktree}").replacingOccurrences(of: fm.homeDirectoryForCurrentUser.path, with: "{home}")
try Data(sanitizedLog.utf8).write(to: root.appendingPathComponent("research/sync/static/analysis.sanitized.log"))
print("Exported sanitized probe records and synthetic fixtures; registry excluded")
