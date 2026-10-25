import Foundation

public struct NoteBlock: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var x: Double
    public var y: Double
    public var width: Double
    public var text: String

    public init(id: UUID = UUID(), x: Double = 48, y: Double = 120, width: Double = 720, text: String = "") {
        self.id = id; self.x = x; self.y = y; self.width = width; self.text = text
    }
}

public struct NotePage: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var blocks: [NoteBlock]
    public init(id: UUID = UUID(), title: String, blocks: [NoteBlock] = [NoteBlock()]) {
        self.id = id; self.title = title; self.blocks = blocks
    }
}

public struct NoteSection: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var pages: [NotePage]
    public init(id: UUID = UUID(), title: String, pages: [NotePage] = []) {
        self.id = id; self.title = title; self.pages = pages
    }
}

public struct Notebook: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var sections: [NoteSection]
    public init(id: UUID = UUID(), title: String, sections: [NoteSection] = []) {
        self.id = id; self.title = title; self.sections = sections
    }

    public func validate() throws {
        var identities = Set<UUID>()
        func register(_ id: UUID) throws {
            guard identities.insert(id).inserted else { throw NotebookError.duplicateIdentity(id) }
        }
        try register(id)
        for section in sections {
            try register(section.id)
            for page in section.pages {
                try register(page.id)
                for block in page.blocks {
                    try register(block.id)
                    guard block.x.isFinite, block.y.isFinite, block.width.isFinite,
                          block.x >= 0, block.y >= 0, block.width > 0 else { throw NotebookError.invalidGeometry(block.id) }
                }
            }
        }
    }
}

public enum NotebookError: Error, Equatable {
    case duplicateIdentity(UUID)
    case invalidGeometry(UUID)
    case unsupportedSchema(Int)
}

public protocol NotebookRepository: Sendable {
    func load() throws -> Notebook
    func save(_ notebook: Notebook) throws
}
