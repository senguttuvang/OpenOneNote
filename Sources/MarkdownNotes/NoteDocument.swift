import Foundation

/// Portable semantic content; vendor DOM and Markdown AST types stop at the converter.
public indirect enum NoteNode: Codable, Equatable, Sendable {
    case text(String)
    case element(String, [String: String], [NoteNode])

    public var text: String {
        switch self {
        case .text(let value): return value
        case .element(_, _, let children): return children.map(\.text).joined()
        }
    }
}

public struct NoteDocument: Codable, Equatable, Sendable {
    public var blocks: [NoteNode]
    public var warnings: [String]
    public init(blocks: [NoteNode], warnings: [String] = []) {
        self.blocks = blocks; self.warnings = warnings
    }
}

public enum NotesError: Error, LocalizedError, Equatable {
    case invalid(String)
    case authenticationRequired
    case http(Int)
    case conflict
    case remoteChanged
    case unsupported(String)

    public var errorDescription: String? {
        switch self {
        case .invalid(let reason), .unsupported(let reason): return reason
        case .authenticationRequired: return "Microsoft delegated sign-in with Notes.ReadWrite is required."
        case .http(let status): return "Microsoft Graph returned HTTP \(status). Local notes are retained."
        case .conflict: return "Overlapping edits need resolution. Local, remote and baseline copies are retained."
        case .remoteChanged: return "The remote page changed during sync. Refresh before retrying."
        }
    }
}

public struct RemotePage: Codable, Equatable, Sendable {
    public var id: String
    public var title: String
    public var html: String
    public init(id: String, title: String, html: String) { self.id = id; self.title = title; self.html = html }
}

public struct PageIdentity: Codable, Hashable, Sendable {
    public let root: String
    public let pageID: String
    public let accountKey: String?
    public init(root: String = "me", pageID: String, accountKey: String? = nil) {
        self.root = root; self.pageID = pageID; self.accountKey = accountKey
    }
}

public struct GraphItem: Codable, Identifiable, Sendable {
    public let id: String
    public var displayName: String?
    public var title: String?
    public var name: String { displayName ?? title ?? "Untitled" }
    public init(id: String, displayName: String? = nil, title: String? = nil) {
        self.id = id; self.displayName = displayName; self.title = title
    }
}

public struct PageCommand: Codable, Equatable, Sendable {
    public var target: String
    public var action: String
    public var position: String?
    public var content: String
    public init(target: String, action: String, position: String? = nil, content: String) {
        self.target = target; self.action = action; self.position = position; self.content = content
    }
}

public struct BinaryPart: Sendable {
    public let name: String
    public let mimeType: String
    public let bytes: Data
    public init(name: String, mimeType: String, bytes: Data) {
        self.name = name; self.mimeType = mimeType; self.bytes = bytes
    }
}

public protocol OneNoteRemote: Sendable {
    func fetch(_ identity: PageIdentity) async throws -> RemotePage
    func resource(_ url: URL) async throws -> Data
    func update(_ identity: PageIdentity, commands: [PageCommand], parts: [BinaryPart]) async throws
}
