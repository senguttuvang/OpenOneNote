import Foundation
import CryptoKit

// Read-only, metadata-only probe. Never emits leaf names, account IDs, or bodies.
let fm = FileManager.default
let home = fm.homeDirectoryForCurrentUser
let roots = [
    "sandbox-support": "Library/Containers/com.microsoft.onenote.mac/Data/Library/Application Support/Microsoft User Data/OneNote/15.0",
    "sandbox-cache": "Library/Containers/com.microsoft.onenote.mac/Data/Library/Caches",
    "office-onenote": "Library/Group Containers/UBF8T346G9.Office/OneNote"
]
struct Bucket: Codable { var files = 0; var bytes: Int64 = 0; var headers: [String: Int] = [:] }
struct Snapshot: Codable { let capturedAt: String; let roots: [String: [String: Bucket]]; let failures: Int }
var result: [String: [String: Bucket]] = [:]
var failures = 0
for (label, relative) in roots {
    let root = home.appendingPathComponent(relative)
    var buckets: [String: Bucket] = [:]
    guard let iterator = fm.enumerator(at: root, includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey], options: [.skipsHiddenFiles], errorHandler: { _, _ in failures += 1; return true }) else {
        failures += 1
        continue
    }
    for case let url as URL in iterator {
        do {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
            if values.isSymbolicLink == true { iterator.skipDescendants(); continue }
            // Credential-related trees are excluded even when encountered below an allowed root.
            let parts = url.pathComponents.map { $0.lowercased() }
            if parts.contains(where: { $0.contains("token") || $0.contains("identity") || $0.contains("credential") || $0.contains("keychain") || $0.contains("adal") || $0.contains("msal") }) {
                iterator.skipDescendants(); continue
            }
            guard values.isRegularFile == true else { continue }
            let ext = url.pathExtension.lowercased()
            let allowed = ["bin", "dat", "db", "sqlite", "sqlite3", "one", "onetoc2", "plist", "log", "json", "png", "jpg", "jpeg", "pdf", "tmp", "cache", "wal", "shm"]
            let category = allowed.contains(ext) ? ext : (ext.isEmpty ? "no-extension" : "other-extension")
            var bucket = buckets[category, default: Bucket()]
            bucket.files += 1
            bucket.bytes += Int64(values.fileSize ?? 0)
            // Only header classification; no raw bytes or strings leave the process.
            let handle = try FileHandle(forReadingFrom: url)
            let bytes = try handle.read(upToCount: 16) ?? Data()
            try handle.close()
            let kind: String
            if bytes.starts(with: Data("SQLite format 3\0".utf8)) { kind = "sqlite3" }
            else if bytes.starts(with: Data("bplist00".utf8)) { kind = "binary-plist" }
            else if bytes.starts(with: [0xE4, 0x52, 0x5C, 0x7B, 0x8C, 0xD8, 0xA7, 0x4D]) { kind = "onestore-guid-prefix" }
            else if bytes.starts(with: [0x50, 0x4B, 0x03, 0x04]) { kind = "zip" }
            else if bytes.starts(with: Data("<?xml".utf8)) { kind = "xml" }
            else if bytes.isEmpty { kind = "empty" }
            else { kind = "unclassified" }
            bucket.headers[kind, default: 0] += 1
            buckets[category] = bucket
        } catch { failures += 1 }
    }
    result[label] = buckets
}
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let snapshot = Snapshot(capturedAt: ISO8601DateFormatter().string(from: Date()), roots: result, failures: failures)
print(String(decoding: try encoder.encode(snapshot), as: UTF8.self))
