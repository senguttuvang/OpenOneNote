import Foundation
import Observation
import OneNoteGraph
import MarkdownNotes

@MainActor @Observable public final class CloudBrowserState {
    public struct Column: Identifiable, Sendable {
        public let id = UUID()
        public let title: String
        public var entries: [StorageEntry]
        public var selectedID: String?
    }
    public private(set) var columns: [Column] = []
    public private(set) var loading = false
    public private(set) var error: String?
    public private(set) var location = "recent"
    public private(set) var selection: StorageEntry?
    private var task: Task<Void, Never>?
    private var generation = UUID()
    private var retryAction: (@MainActor () -> Void)?
    public init() {}
    public func cancel() {
        task?.cancel(); task = nil; generation = UUID(); loading = false
    }
    public func reset(location: String) {
        cancel(); self.location = location; columns = []; selection = nil; error = nil
    }
    public func load(location: String, using service: any StorageBrowsing) {
        reset(location: location)
        retryAction = { [weak self] in self?.load(location: location, using: service) }
        run(title: location == "sites" ? "Sites" : "OneDrive") {
            try await location == "sites" ? service.sites() : service.oneDrive()
        }
    }
    public func select(_ entry: StorageEntry, column: Int, using service: any StorageBrowsing) {
        guard columns.indices.contains(column) else { return }
        cancel(); error = nil
        columns = Array(columns.prefix(column + 1)); columns[column].selectedID = entry.id
        selection = entry.kind == .notebook ? entry : nil
        guard entry.kind != .notebook else { return }
        retryAction = { [weak self] in self?.select(entry, column: column, using: service) }
        run(title: entry.name) { try await service.children(of: entry) }
    }
    public func retry() { retryAction?() }
    private func run(title: String, load: @escaping @Sendable () async throws -> [StorageEntry]) {
        let request = UUID(); generation = request; loading = true
        task = Task { [weak self] in
            do {
                let entries = try await load(); try Task.checkCancellation()
                guard let self, self.generation == request else { return }
                self.columns.append(Column(title: title, entries: entries, selectedID: nil))
                self.loading = false; self.task = nil
            } catch {
                guard let self, self.generation == request else { return }
                self.loading = false; self.task = nil
                if !(error is CancellationError) { self.error = Self.message(error) }
            }
        }
    }
    public static func message(_ error: Error) -> String {
        if case NotesError.authenticationRequired = error { return "Sign in to browse your notebooks." }
        if case NotesError.http(403) = error { return "Storage access is needed. Connect storage or choose a different location." }
        if (error as? GraphServiceFailure)?.status == 403 { return "Storage access is needed. Connect storage or choose a different location." }
        return "This location could not be loaded. Check your connection and try again."
    }
}
