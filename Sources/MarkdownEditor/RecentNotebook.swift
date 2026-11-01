import Foundation

/// Local navigation metadata, scoped to the authenticated O2N account.
public struct RecentNotebook: Codable, Identifiable, Equatable, Sendable {
    public let root: String
    public let notebookID: String
    public let name: String
    public let accountKey: String
    public let openedAt: Date
    public var id: String { accountKey + ":" + root + ":" + notebookID }
}
