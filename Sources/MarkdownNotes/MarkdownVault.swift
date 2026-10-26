import Foundation
import CryptoKit

public struct AssetRecord: Codable, Equatable, Sendable {
    public var resourceURL: String
    public var path: String
    public var hash: String
}
public struct NoteLedger: Codable, Equatable, Identifiable, Sendable {
    public var schema = 1
    public let id: UUID
    public var identity: PageIdentity
    public var title: String
    public var hierarchy: [String]?
    public var relativePath: String
    public var baseline: NoteDocument
    public var baselineMarkdown: String
    public var remoteHTMLHash: String
    public var assets: [AssetRecord]
    public var state: String
    public var pendingMarkdown: String?
    public var materializationPreviousHash: String?
    public var remoteRecovery: NoteDocument?
    public var recoveryVersions: [RecoveryVersion]?
    public init(identity: PageIdentity, title: String, baseline: NoteDocument, markdown: String, htmlHash: String, assets: [AssetRecord]) {
        id = UUID(); self.identity = identity; self.title = title
        relativePath = id.uuidString.lowercased() + ".md"
        self.baseline = baseline; baselineMarkdown = markdown; remoteHTMLHash = htmlHash
        self.assets = assets; state = "synced"
    }
}

public struct RecoveryVersion: Codable, Equatable, Sendable {
    public let baseline: NoteDocument
    public let localMarkdown: String
    public let remote: NoteDocument
}

/// One ledger per page, portable Markdown plus content-addressed assets. No legacy store mutation.
public struct MarkdownVault: Sendable {
    public let root: URL
    public init(root: URL) throws {
        self.root = root.standardizedFileURL
        try FileManager.default.createDirectory(at: self.root, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: self.root.appendingPathComponent(".o2n"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: self.root.appendingPathComponent(".assets"), withIntermediateDirectories: true)
        _ = try safeURL(".o2n"); _ = try safeURL(".assets")
    }
    public static func hash(_ data: Data) -> String { SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined() }
    public static func hash(_ text: String) -> String { hash(Data(text.utf8)) }
    public func safeURL(_ relative: String) throws -> URL {
        guard !relative.isEmpty, !relative.hasPrefix("/"), !relative.contains("\\"),
              !relative.split(separator: "/", omittingEmptySubsequences: false).contains(where: { $0 == ".." || $0.isEmpty }) else { throw NotesError.invalid("Unsafe vault path") }
        let url = root.appendingPathComponent(relative).standardizedFileURL
        let resolved = url.resolvingSymlinksInPath().path
        let base = root.resolvingSymlinksInPath().path + "/"
        guard resolved.hasPrefix(base) else { throw NotesError.invalid("Vault path escapes through a symbolic link") }
        // Reject all symlinks within the vault, including links to another owned note.
        var component = root
        for part in relative.split(separator: "/") {
            component.appendPathComponent(String(part))
            if (try? component.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true { throw NotesError.invalid("Symbolic links are not writable vault paths") }
        }
        return url
    }
    public func ledgers() throws -> [NoteLedger] {
        let directory = try safeURL(".o2n")
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }.map { try load(UUID(uuidString: $0.deletingPathExtension().lastPathComponent) ?? { throw NotesError.invalid("Invalid ledger filename") }()) }
    }
    public func load(_ id: UUID) throws -> NoteLedger {
        let data = try Data(contentsOf: safeURL(".o2n/\(id.uuidString).json"))
        let value = try JSONDecoder().decode(NoteLedger.self, from: data)
        guard value.schema == 1, value.id == id, value.relativePath.hasSuffix(".md") else { throw NotesError.invalid("Unsupported or mismatched vault ledger") }
        _ = try safeURL(value.relativePath)
        return value
    }
    public func markdown(_ ledger: NoteLedger) throws -> String {
        try String(contentsOf: safeURL(ledger.relativePath), encoding: .utf8)
    }
    public func saveLedger(_ ledger: NoteLedger) throws {
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(ledger).write(to: safeURL(".o2n/\(ledger.id.uuidString).json"), options: .atomic)
    }
    public func create(_ ledger: NoteLedger) throws {
        guard !FileManager.default.fileExists(atPath: try safeURL(ledger.relativePath).path) else { throw NotesError.invalid("Refusing to overwrite an existing note") }
        // Ledger first records the recovery intent; a crash never loses the imported Markdown.
        var pending = ledger; pending.pendingMarkdown = ledger.baselineMarkdown; pending.state = "materializing"
        try saveLedger(pending)
        try writeMarkdown(ledger.baselineMarkdown, ledger: ledger)
        try saveLedger(ledger)
    }
    public func writeMarkdown(_ text: String, ledger: NoteLedger) throws {
        try Data(text.utf8).write(to: safeURL(ledger.relativePath), options: .atomic)
    }
    public func saveOffline(_ text: String, ledger: inout NoteLedger) throws {
        ledger.pendingMarkdown = text; ledger.state = "outbox"
        try saveLedger(ledger)
        try writeMarkdown(text, ledger: ledger)
    }
    public func storeAsset(_ data: Data, resourceURL: String, extension suffix: String = "bin") throws -> AssetRecord {
        guard data.count <= 20 * 1024 * 1024 else { throw NotesError.invalid("Resource exceeds 20 MiB") }
        guard suffix.allSatisfy({ $0.isASCII && $0.isLetter }), suffix.count <= 8 else { throw NotesError.invalid("Invalid asset extension") }
        let hash = Self.hash(data); let path = ".assets/\(hash).\(suffix)"
        let destination = try safeURL(path)
        if FileManager.default.fileExists(atPath: destination.path) {
            guard try Data(contentsOf: destination) == data else { throw NotesError.conflict }
        } else { try data.write(to: destination, options: .atomic) }
        // Graph resource URLs have already passed the adapter's strict URL boundary.
        return AssetRecord(resourceURL: resourceURL, path: path, hash: hash)
    }
    public func asset(_ path: String) throws -> Data {
        guard MarkdownConversion.safeAsset(path) else { throw NotesError.invalid("Unsafe asset reference") }
        let data = try Data(contentsOf: safeURL(path))
        guard data.count <= 20 * 1024 * 1024 else { throw NotesError.invalid("Resource exceeds 20 MiB") }
        let stem = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
        if stem.count == 64, stem.allSatisfy(\.isHexDigit), Self.hash(data) != stem {
            throw NotesError.invalid("Content-addressed asset changed. Import it as a new asset to preserve revision identity.")
        }
        return data
    }
    public func recover(_ ledger: inout NoteLedger) throws {
        if let pending = ledger.pendingMarkdown, ledger.state == "materializing" {
            let exists = FileManager.default.fileExists(atPath: try safeURL(ledger.relativePath).path)
            if exists {
                let current = try markdown(ledger)
                if current != pending {
                    guard ledger.materializationPreviousHash == Self.hash(current) else {
                        ledger.state = "recovery"; ledger.remoteRecovery = ledger.baseline; try saveLedger(ledger)
                        throw NotesError.conflict
                    }
                    try writeMarkdown(pending, ledger: ledger)
                }
            } else { try writeMarkdown(pending, ledger: ledger) }
            ledger.pendingMarkdown = nil; ledger.materializationPreviousHash = nil
            ledger.state = "synced"; try saveLedger(ledger)
        }
        // Outbox holds the newest explicit save even if the process died before the .md rename.
        if let pending = ledger.pendingMarkdown, ledger.state == "outbox", try markdown(ledger) != pending {
            // Preserve an externally modified file instead of choosing a winner.
            ledger.state = "recovery"; try saveLedger(ledger)
            throw NotesError.conflict
        }
    }
    /// Explicit user resolution retains the prior three copies before establishing a new merge base.
    public func resolve(_ ledger: inout NoteLedger, editedMarkdown: String) throws {
        guard let remote = ledger.remoteRecovery else { throw NotesError.invalid("No remote conflict copy to resolve") }
        _ = try MarkdownConversion().parse(editedMarkdown)
        let version = RecoveryVersion(baseline: ledger.baseline, localMarkdown: try markdown(ledger), remote: remote)
        ledger.recoveryVersions = (ledger.recoveryVersions ?? []) + [version]
        ledger.baseline = remote; ledger.remoteRecovery = nil
        try saveOffline(editedMarkdown, ledger: &ledger)
    }
}
