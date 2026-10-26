import Foundation
import SQLite3

// Opens only persisted SQLite schema in immutable/read-only mode. This deliberately
// ignores live WAL changes and never selects application rows, file names, or note text.
let fm = FileManager.default
let root = fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/Containers/com.microsoft.onenote.mac/Data/Library/Application Support/Microsoft User Data/OneNote/15.0")
let keys: Set<URLResourceKey> = [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]
let knownDirectories = Set(["AccessibilityCheckerIndex", "Backup", "FullTextSearchIndex", "MasterIndex", "NoteTags", "RecentSearches", "ServerListings", "cache"])
func identifier(_ value: String) -> Bool {
    value.range(of: "^[a-zA-Z_][a-zA-Z_0-9]{0,79}$", options: .regularExpression) != nil
}
var directoryTotals: [String: [String: [String: Int64]]] = [:]
var schemas: [[String: Any]] = []
var failures = 0
guard let items = fm.enumerator(at: root, includingPropertiesForKeys: Array(keys), options: [.skipsHiddenFiles], errorHandler: { _, _ in failures += 1; return true }) else { fatalError("OneNote root unavailable") }
for case let url as URL in items {
    let values = try url.resourceValues(forKeys: keys)
    if values.isSymbolicLink == true { items.skipDescendants(); continue }
    guard values.isRegularFile == true else { continue }
    let components = Array(url.path.dropFirst(root.path.count + 1).split(separator: "/").map(String.init))
    guard let first = components.first, knownDirectories.contains(first) else { continue }
    let ext = url.pathExtension.lowercased()
    let category = ["bin", "db", "one"].contains(ext) ? ext : "other"
    var total = directoryTotals[first, default: [:]][category, default: ["files": 0, "bytes": 0]]
    total["files", default: 0] += 1; total["bytes", default: 0] += Int64(values.fileSize ?? 0)
    directoryTotals[first, default: [:]][category] = total
    guard ext == "db" else { continue }
    var db: OpaquePointer?
    var parts = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    parts.queryItems = [.init(name: "mode", value: "ro"), .init(name: "immutable", value: "1")]
    let status = sqlite3_open_v2(parts.string!, &db, SQLITE_OPEN_READONLY | SQLITE_OPEN_URI, nil)
    defer { sqlite3_close(db) }
    guard status == SQLITE_OK else { failures += 1; continue }
    var statement: OpaquePointer?
    guard sqlite3_prepare_v2(db, "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name", -1, &statement, nil) == SQLITE_OK else { failures += 1; continue }
    var tables: [[String: Any]] = []
    while sqlite3_step(statement) == SQLITE_ROW {
        let name = String(cString: sqlite3_column_text(statement, 0))
        guard identifier(name) else { failures += 1; continue }
        var pragma: OpaquePointer?
        guard sqlite3_prepare_v2(db, "PRAGMA table_info(\"\(name)\")", -1, &pragma, nil) == SQLITE_OK else { failures += 1; continue }
        var columns: [String] = []
        while sqlite3_step(pragma) == SQLITE_ROW {
            let column = String(cString: sqlite3_column_text(pragma, 1))
            if identifier(column) { columns.append(column) } else { failures += 1 }
        }
        sqlite3_finalize(pragma)
        tables.append(["table": name, "columns": columns])
    }
    sqlite3_finalize(statement)
    // Repeated schemas are retained; no account directory or database leaf name emitted.
    schemas.append(["directory": first, "tables": tables, "mode": "read-only-immutable-persisted-schema"])
}
let data = try JSONSerialization.data(withJSONObject: ["capturedAt": ISO8601DateFormatter().string(from: Date()), "directoryTotals": directoryTotals, "schemas": schemas, "failures": failures], options: [.prettyPrinted, .sortedKeys])
print(String(decoding: data, as: UTF8.self))
