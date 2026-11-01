import Foundation

/// A write may reach OneNote even when its response is lost. Retain its intent
/// before sending, and its returned ID before opening the resulting object.
public struct CloudCreationIntent: Codable, Equatable, Sendable {
    public var account: String
    public var root: String
    public var parent: String
    public var kind: String
    public var name: String
    public var createdID: String?
    public init(account: String, root: String, parent: String, kind: String, name: String) {
        self.account = account; self.root = root; self.parent = parent; self.kind = kind; self.name = name
    }
}

extension MarkdownVault {
    public func creationIntents() throws -> [CloudCreationIntent] {
        let url = try safeURL(".o2n/config/cloud-creation-intents.json")
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return try JSONDecoder().decode([CloudCreationIntent].self, from: Data(contentsOf: url))
    }
    public func storeCreationIntents(_ values: [CloudCreationIntent]) throws {
        try FileManager.default.createDirectory(at: safeURL(".o2n/config"), withIntermediateDirectories: true)
        try JSONEncoder().encode(values).write(to: safeURL(".o2n/config/cloud-creation-intents.json"), options: .atomic)
    }
}
