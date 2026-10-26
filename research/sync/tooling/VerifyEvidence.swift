import Foundation
import CryptoKit

struct EvidenceEntry: Codable, Equatable { let path: String; let bytes: Int; let sha256: String }
struct EvidenceManifest: Codable { let schemaVersion: Int; let capturedBuild: String; let files: [EvidenceEntry] }
struct EvidenceFailure: Error, CustomStringConvertible { let description: String }
let fm = FileManager.default
let root = URL(fileURLWithPath: fm.currentDirectoryPath).standardizedFileURL
let manifestURL = root.appendingPathComponent("research/sync/evidence-manifest.json")
let roots = ["research/sync", "reconstruction/onenote-internals"]
let exclusions: Set<String> = ["research/sync/evidence-manifest.json", "research/sync/verification.json"]
var files: [EvidenceEntry] = []
var violations: [String] = []
var privateIDs: [String] = []
let registry = root.appendingPathComponent("scratch/sync/owned-objects.json")
if fm.fileExists(atPath: registry.path) {
    let ids = try JSONDecoder().decode([String: String].self, from: Data(contentsOf: registry))
    privateIDs = ["notebook", "section", "page", "attachmentPage"].compactMap { ids[$0] }
}
let linkPattern = try NSRegularExpression(pattern: "\\[[^\\]]*\\]\\(([^)]+)\\)")
let runtimePattern = try NSRegularExpression(pattern: "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}|eyJ[A-Za-z0-9_-]{50,}\\.[A-Za-z0-9_-]{50,}\\.[A-Za-z0-9_-]+|Bearer [A-Za-z0-9_-]{30,}")
for directory in roots {
    guard let iterator = fm.enumerator(at: root.appendingPathComponent(directory), includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey]) else { throw EvidenceFailure(description: "Evidence directory missing") }
    for case let file as URL in iterator {
        let values = try file.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey])
        guard values.isSymbolicLink != true else { throw EvidenceFailure(description: "Evidence symlink rejected") }
        guard values.isRegularFile == true else { continue }
        let relative = String(file.path.dropFirst(root.path.count + 1))
        if exclusions.contains(relative) { continue }
        let data = try Data(contentsOf: file)
        guard let text = String(data: data, encoding: .utf8) else { throw EvidenceFailure(description: "Non-text evidence rejected: \(relative)") }
        let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        files.append(.init(path: relative, bytes: data.count, sha256: hash))
        if privateIDs.contains(where: text.contains) { violations.append("Private object ID in \(relative)") }
        if relative.hasPrefix("research/sync/runtime/"), runtimePattern.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil { violations.append("Unredacted runtime identifier/token pattern in \(relative)") }
        if file.pathExtension == "md" {
            for match in linkPattern.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                guard let range = Range(match.range(at: 1), in: text) else { continue }
                let target = String(text[range])
                if target.contains("://") || target.hasPrefix("#") { continue }
                let path = String(target.split(separator: "#", maxSplits: 1).first ?? "")
                let resolved = file.deletingLastPathComponent().appendingPathComponent(path).standardizedFileURL
                if !resolved.path.hasPrefix(root.path + "/") || !fm.fileExists(atPath: resolved.path) { violations.append("Missing/outside local link in \(relative): \(path)") }
            }
        }
    }
}
guard violations.isEmpty else { throw EvidenceFailure(description: violations.joined(separator: "\n")) }
files.sort { $0.path < $1.path }
let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
if CommandLine.arguments.contains("seal") {
    try encoder.encode(EvidenceManifest(schemaVersion: 1, capturedBuild: "16.114.1 (16.114.26102031)", files: files)).write(to: manifestURL)
    print("Sealed \(files.count) text evidence/document/tool files after link and redaction checks")
} else {
    let manifest = try JSONDecoder().decode(EvidenceManifest.self, from: Data(contentsOf: manifestURL))
    guard manifest.schemaVersion == 1, manifest.files == files else { throw EvidenceFailure(description: "Evidence bytes or file set changed; manifest verification failed") }
    print("Verified \(files.count) evidence hashes, local links, and redaction; known private IDs checked: \(privateIDs.count)")
}
