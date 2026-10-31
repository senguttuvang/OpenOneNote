import Foundation
import CryptoKit

/// Offline lexical/symbol index. It has no networking or provider dependency.
public struct SourceIndex: Codable, Sendable {
    public struct Document: Codable, Sendable, Equatable {
        public let path: String
        public let sha256: String
        public let provenance: String
        public let lines: [String]
    }
    public struct Hit: Sendable {
        public let path: String
        public let line: Int
        public let text: String
    }
    public let revision: String
    public let documents: [Document]
    public let skipped: [String]
    public var policy = "Local only; authored Swift and static research text; no archives, binaries, assets, account data or screenshot"

    public static func build(root: URL, revision: String) throws -> SourceIndex {
        let root = root.resolvingSymlinksInPath().standardizedFileURL
        var documents: [Document] = []
        var skipped: [String] = []
        let roots = ["Sources", "Tests", "Tools", "research/extracted", "research/decompiled"]
        let extensions = Set(["swift", "java", "c", "h", "txt", "tsv", "xml", "json", "md", "plist"])
        for directory in roots {
            let base = root.appendingPathComponent(directory)
            guard let files = FileManager.default.enumerator(at: base, includingPropertiesForKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey], options: [.skipsHiddenFiles]) else { continue }
            for case let url as URL in files {
                let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
                guard values.isRegularFile == true, values.isSymbolicLink != true else { continue }
                // Enumerator depth avoids /var versus /private/var spelling differences.
                let path = directory + "/" + url.pathComponents.suffix(files.level).joined(separator: "/")
                guard !path.hasPrefix("Sources/MarkdownEditor/Resources/") else { skipped.append(path); continue }
                guard extensions.contains(url.pathExtension), (values.fileSize ?? 0) <= 32 * 1024 * 1024 else { skipped.append(path); continue }
                let data = try Data(contentsOf: url)
                guard let text = String(data: data, encoding: .utf8), !text.hasPrefix("version https://git-lfs.github.com/spec/v1"), !text.contains("\0") else { skipped.append(path); continue }
                documents.append(Document(path: path, sha256: SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined(),
                    provenance: path.hasPrefix("research/decompiled") ? "Inferred Ghidra pseudocode, not recovered source" : path.hasPrefix("research/") ? "Static Microsoft bundle evidence" : "Independent authored source",
                    lines: text.components(separatedBy: .newlines)))
            }
        }
        return SourceIndex(revision: revision, documents: documents.sorted { $0.path < $1.path }, skipped: skipped.sorted())
    }
    /// AND query over a line and its file path; exact symbols remain searchable.
    public func search(_ query: String, limit: Int = 20) -> [Hit] {
        let terms = query.lowercased().split(whereSeparator: \.isWhitespace).map(String.init)
        guard !terms.isEmpty else { return [] }
        var hits: [Hit] = []
        for document in documents {
            for (offset, line) in document.lines.enumerated() {
                let candidate = (document.path + " " + line).lowercased()
                if terms.allSatisfy({ candidate.contains($0) }) {
                    hits.append(Hit(path: document.path, line: offset + 1, text: String(line.prefix(400))))
                    if hits.count >= max(1, limit) { return hits }
                }
            }
        }
        return hits
    }
    public func verify(root: URL) throws {
        // Enumerate the allowlist again so added/deleted files cannot look like current coverage.
        // Never read a path supplied by a decoded index manifest.
        let current = try Self.build(root: root, revision: revision)
        guard current.documents == documents, current.skipped == skipped else {
            throw DevelopmentError.invalidArguments("Stale index coverage or content; rebuild source-index")
        }
    }
}

extension DevelopmentWorkflow {
    public func sourceIndex(query: String?) throws {
        let url = root.appendingPathComponent("scratch/source-index.json")
        if let query {
            let index = try JSONDecoder().decode(SourceIndex.self, from: Data(contentsOf: url))
            try index.verify(root: root)
            print("Offline index at \(index.revision); \(index.documents.count) hashed text files")
            let hits = index.search(query)
            if hits.isEmpty { print("No matches") }
            for hit in hits { print("\(hit.path):\(hit.line): \(hit.text)") }
        } else {
            let revision = try run("git", ["rev-parse", "HEAD"], capture: true).stdout
            let index = try SourceIndex.build(root: root, revision: revision)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let encoder = JSONEncoder(); encoder.outputFormatting = [.sortedKeys]
            try encoder.encode(index).write(to: url, options: .atomic)
            print("Indexed \(index.documents.count) text files; skipped \(index.skipped.count); local only: \(url.path)")
        }
    }
}
