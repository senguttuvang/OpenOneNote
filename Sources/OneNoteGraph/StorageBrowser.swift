import Foundation
import MarkdownNotes

/// Read-only location browsing. Display metadata is never treated as authorization.
public struct StorageEntry: Identifiable, Equatable, Sendable {
    public enum Kind: String, Sendable { case site, library, folder, notebook }
    public let id: String
    public let name: String
    public let kind: Kind
    public let root: String
    public let driveID: String?
    public let webURL: URL?
    public init(id: String, name: String, kind: Kind, root: String, driveID: String? = nil, webURL: URL? = nil) {
        self.id = id; self.name = name; self.kind = kind; self.root = root; self.driveID = driveID; self.webURL = webURL
    }
}

public protocol StorageBrowsing: Sendable {
    func sites() async throws -> [StorageEntry]
    func oneDrive() async throws -> [StorageEntry]
    func children(of entry: StorageEntry) async throws -> [StorageEntry]
    func notebook(for entry: StorageEntry) async throws -> GraphItem
}

extension GraphClient: StorageBrowsing {
    private struct StorageObject: Decodable {
        struct Folder: Decodable {}
        struct Package: Decodable { var type: String? }
        var id: String
        var name: String?
        var displayName: String?
        var webUrl: URL?
        var folder: Folder?
        var package: Package?
    }
    private struct StoragePage: Decodable {
        var value: [StorageObject]
        var next: String?
        enum CodingKeys: String, CodingKey { case value; case next = "@odata.nextLink" }
    }
    private func storageList(_ path: String) async throws -> [StorageObject] {
        guard let initial = URL(string: "https://graph.microsoft.com/v1.0/" + path) else { throw NotesError.invalid("Invalid storage location") }
        var next: URL? = initial; var seen: Set<URL> = []; var result: [StorageObject] = []
        while let current = next {
            try Task.checkCancellation()
            guard seen.insert(current).inserted, seen.count <= 1000 else { throw NotesError.invalid("Storage pagination limit") }
            let page = try JSONDecoder().decode(StoragePage.self, from: await request(current))
            result += page.value
            if let link = page.next {
                guard let value = URL(string: link), value.path == initial.path else { throw NotesError.invalid("Storage pagination left this folder") }
                try Self.validate(value); next = value
            } else { next = nil }
        }
        return result
    }
    public func sites() async throws -> [StorageEntry] {
        try await storageList("sites?search=*&$select=id,displayName,webUrl").map {
            StorageEntry(id: $0.id, name: $0.displayName ?? $0.name ?? "SharePoint", kind: .site, root: "sites/" + $0.id, webURL: $0.webUrl)
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
    public func oneDrive() async throws -> [StorageEntry] {
        try await storageList("me/drives?$select=id,name,webUrl").map {
            StorageEntry(id: $0.id, name: $0.name ?? "OneDrive", kind: .library, root: "me", driveID: $0.id, webURL: $0.webUrl)
        }
    }
    public func children(of entry: StorageEntry) async throws -> [StorageEntry] {
        if entry.kind == .site {
            return try await storageList("sites/\(Self.component(entry.id))/drives?$select=id,name,webUrl").map {
                StorageEntry(id: $0.id, name: $0.name ?? "Documents", kind: .library, root: entry.root, driveID: $0.id, webURL: $0.webUrl)
            }
        }
        guard entry.kind == .library || entry.kind == .folder, let drive = entry.driveID else { throw NotesError.invalid("Choose a folder") }
        let parent = entry.kind == .library ? "root" : "items/\(try Self.component(entry.id))"
        return try await storageList("drives/\(Self.component(drive))/\(parent)/children?$select=id,name,folder,package,webUrl&$top=200").compactMap {
            let kind: StorageEntry.Kind
            if $0.package?.type?.caseInsensitiveCompare("oneNote") == .orderedSame { kind = .notebook }
            else if $0.folder != nil { kind = .folder }
            else { return nil }
            return StorageEntry(id: $0.id, name: $0.name ?? "Untitled", kind: kind, root: entry.root, driveID: drive, webURL: $0.webUrl)
        }.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
    public func notebook(for entry: StorageEntry) async throws -> GraphItem {
        guard entry.kind == .notebook else { throw NotesError.invalid("Choose a notebook") }
        let matches = try await list(root: entry.root, path: "notebooks").filter { item in
            guard let client = item.links?.oneNoteClientUrl?.href, let expected = entry.webURL else { return false }
            let normalized = client.hasPrefix("onenote:") ? String(client.dropFirst(8)) : client
            guard let url = URL(string: normalized) else { return false }
            return url.host?.lowercased() == expected.host?.lowercased() && url.path.removingPercentEncoding == expected.path.removingPercentEncoding
        }
        guard matches.count == 1, let match = matches.first else {
            throw NotesError.unsupported("This notebook could not be matched safely. Refresh the folder and try again.")
        }
        return match
    }
}

extension GraphClient {
    public func site(id: String) async throws -> StorageEntry {
        struct Site: Decodable { var id: String; var displayName: String; var webUrl: URL? }
        let endpoint = URL(string: "https://graph.microsoft.com/v1.0/sites/\(try Self.component(id))?$select=id,displayName,webUrl")!
        let value = try JSONDecoder().decode(Site.self, from: await request(endpoint))
        return StorageEntry(id: value.id, name: value.displayName, kind: .site, root: "sites/" + value.id, webURL: value.webUrl)
    }
}
