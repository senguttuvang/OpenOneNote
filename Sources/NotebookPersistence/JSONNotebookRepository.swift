import Foundation
import NotebookCore

/// Single-writer research prototype. A missing or corrupt file is always an error;
/// opening a broken notebook never substitutes an empty one or overwrites it.
public struct JSONNotebookRepository: NotebookRepository {
    public let url: URL
    public init(url: URL) { self.url = url }

    private struct Envelope: Codable {
        let schemaVersion: Int
        let notebook: Notebook
    }

    public func load() throws -> Notebook {
        let data = try Data(contentsOf: url)
        // Check the version before interpreting a future model schema.
        struct Version: Decodable { let schemaVersion: Int }
        let version = try JSONDecoder().decode(Version.self, from: data)
        guard version.schemaVersion == 1 else { throw NotebookError.unsupportedSchema(version.schemaVersion) }
        let envelope = try JSONDecoder().decode(Envelope.self, from: data)
        try envelope.notebook.validate()
        return envelope.notebook
    }

    public func save(_ notebook: Notebook) throws {
        try notebook.validate()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(Envelope(schemaVersion: 1, notebook: notebook))
        try data.write(to: url, options: .atomic)
    }
}
