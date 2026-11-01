import Foundation
import Testing
import MarkdownNotes
import MarkdownEditor
@testable import OneNoteGraph

private struct BrowseAuthorization: GraphAuthorization {
    func accessToken() async throws -> String { "synthetic" }
    func identityKey() async throws -> String { "synthetic-account" }
}
private actor BrowseTransport: GraphTransport {
    var responses: [GraphResponse]
    var paths: [String] = []
    init(_ bodies: [String]) { responses = bodies.map { GraphResponse(data: Data($0.utf8), status: 200) } }
    func send(_ request: URLRequest) throws -> GraphResponse {
        #expect(request.httpMethod == "GET")
        paths.append(request.url!.path)
        guard !responses.isEmpty else { throw NotesError.invalid("Unexpected browse request") }
        return responses.removeFirst()
    }
}

@Test func storageSitesLibrariesFoldersAndNotebookPackagesRetainRoot() async throws {
    let transport = BrowseTransport([
        #"{"value":[{"id":"site","displayName":"Synthetic site","webUrl":"https://example.sharepoint.com/sites/test"}]}"#,
        #"{"value":[{"id":"drive","name":"Documents"}]}"#,
        #"{"value":[{"id":"folder","name":"Folder","folder":{}},{"id":"book","name":"Book","package":{"type":"oneNote"}},{"id":"file","name":"ignore.txt"}]}"#,
        #"{"value":[]}"#
    ])
    let client = GraphClient(authorization: BrowseAuthorization(), transport: transport)
    let site = try #require(try await client.sites().first)
    let library = try #require(try await client.children(of: site).first)
    let entries = try await client.children(of: library)
    #expect(entries.map(\.kind) == [.notebook, .folder])
    #expect(entries.allSatisfy { $0.root == "sites/site" && $0.driveID == "drive" })
    let folder = try #require(entries.first { $0.kind == .folder })
    #expect(try await client.children(of: folder).isEmpty)
    #expect(await transport.paths == ["/v1.0/sites", "/v1.0/sites/site/drives", "/v1.0/drives/drive/root/children", "/v1.0/drives/drive/items/folder/children"])
}

@Test func storagePaginationCannotCrossFolderOrHost() async throws {
    for link in ["https://evil.example/v1.0/me/drives", "https://graph.microsoft.com/v1.0/users/other/drives"] {
        let data = try JSONSerialization.data(withJSONObject: ["value": [], "@odata.nextLink": link])
        let transport = BrowseTransport([String(decoding: data, as: UTF8.self)])
        let client = GraphClient(authorization: BrowseAuthorization(), transport: transport)
        await #expect(throws: NotesError.self) { try await client.oneDrive() }
        #expect(await transport.paths.count == 1)
    }
}

@Test func notebookPackageResolutionUsesExactURLInsteadOfDisplayName() async throws {
    let transport = BrowseTransport([#"{"value":[{"id":"wrong","displayName":"Book","links":{"oneNoteClientUrl":{"href":"onenote:https://example.sharepoint.com/sites/test/Other/Book"}}},{"id":"correct","displayName":"Book","links":{"oneNoteClientUrl":{"href":"onenote:https://example.sharepoint.com/sites/test/Shared%20Documents/Book"}}}]}"#])
    let client = GraphClient(authorization: BrowseAuthorization(), transport: transport)
    let entry = StorageEntry(id: "package", name: "Book", kind: .notebook, root: "sites/site", driveID: "drive", webURL: URL(string: "https://example.sharepoint.com/sites/test/Shared%20Documents/Book")!)
    #expect(try await client.notebook(for: entry).id == "correct")
}

@Test func ambiguousNotebookPackageNeverOpensByName() async throws {
    let transport = BrowseTransport([#"{"value":[{"id":"one","displayName":"Book"},{"id":"two","displayName":"Book"}]}"#])
    let client = GraphClient(authorization: BrowseAuthorization(), transport: transport)
    let entry = StorageEntry(id: "package", name: "Book", kind: .notebook, root: "me")
    await #expect(throws: NotesError.self) { try await client.notebook(for: entry) }
}

private actor DelayedBrowse: StorageBrowsing {
    var pending: CheckedContinuation<[StorageEntry], Never>?
    var started: CheckedContinuation<Void, Never>?
    func sites() async -> [StorageEntry] {
        await withCheckedContinuation { continuation in pending = continuation; started?.resume(); started = nil }
    }
    func waitForSites() async { if pending == nil { await withCheckedContinuation { started = $0 } } }
    func finishSites() { pending?.resume(returning: [StorageEntry(id: "stale", name: "Stale", kind: .site, root: "sites/stale")]); pending = nil }
    func oneDrive() async -> [StorageEntry] { [StorageEntry(id: "drive", name: "Current drive", kind: .library, root: "me", driveID: "drive")] }
    func children(of entry: StorageEntry) async -> [StorageEntry] { [] }
    func notebook(for entry: StorageEntry) async throws -> GraphItem { throw NotesError.invalid("Not a test operation") }
}
@Test @MainActor func lateSiteResponseCannotOverwriteNewLocation() async throws {
    let service = DelayedBrowse(); let state = CloudBrowserState()
    state.load(location: "sites", using: service)
    await service.waitForSites()
    state.load(location: "drive", using: service)
    await service.finishSites()
    for _ in 0..<100 where state.loading { await Task.yield() }
    #expect(state.location == "drive")
    #expect(state.columns.flatMap(\.entries).map(\.id) == ["drive"])
    #expect(state.selection == nil)
    #expect(state.error == nil)
}

@Test @MainActor func changingParentClearsNotebookSelectionAndDescendants() async throws {
    let service = DelayedBrowse(); let state = CloudBrowserState()
    state.load(location: "drive", using: service)
    for _ in 0..<100 where state.loading { await Task.yield() }
    let drive = try #require(state.columns.first?.entries.first)
    state.select(drive, column: 0, using: service)
    for _ in 0..<100 where state.loading { await Task.yield() }
    #expect(state.columns.count == 2)
    #expect(state.columns[1].entries.isEmpty)
    state.reset(location: "recent")
    #expect(state.columns.isEmpty && state.selection == nil && !state.loading)
}

@Test @MainActor func notebookOpenLoadsHierarchyWithoutFetchingPageBodiesAndScopesRecents() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    session.newLocal(); session.edit("Preserve original local note\n")
    let original = try #require(session.selected)
    let transport = BrowseTransport([
        #"{"value":[{"id":"section","displayName":"Section"}]}"#,
        #"{"value":[]}"#,
        #"{"value":[{"id":"page","title":"Page"}]}"#
    ])
    session.graph = GraphClient(authorization: BrowseAuthorization(), transport: transport)
    #expect(await session.openNotebook(root: "sites/synthetic", notebook: GraphItem(id: "book", displayName: "Synthetic notebook")))
    #expect(session.remoteNotebookName == "Synthetic notebook")
    #expect(session.sections.map(\.id) == ["section"] && session.pages.map(\.id) == ["page"])
    #expect(session.selectedID == nil)
    #expect(try session.vault.markdown(original) == "Preserve original local note\n")
    #expect(await transport.paths.allSatisfy { !$0.hasSuffix("/content") })
    let reopened = try MarkdownSession(vault: session.vault)
    #expect(reopened.recentNotebooks.count == 1)
    #expect(reopened.recentNotebooks.first?.accountKey == "synthetic-account")
    #expect(reopened.recentNotebooks.first?.root == "sites/synthetic")
}

@Test @MainActor func failedNotebookOpenPreservesCurrentSelectionSourceAndHierarchy() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    session.newLocal(); session.edit("Keep this note\n")
    let id = session.selectedID; let root = session.root
    session.graph = GraphClient(authorization: BrowseAuthorization(), transport: BrowseTransport([]))
    #expect(await session.openNotebook(root: "sites/fails", notebook: GraphItem(id: "fails", displayName: "Unavailable")) == false)
    #expect(session.selectedID == id && session.source == "Keep this note\n" && session.root == root)
    #expect(session.recentNotebooks.isEmpty && !session.busy)
}

@Test func notebookPackageURLDoesNotDoubleDecodeDistinctFolderNames() async throws {
    let transport = BrowseTransport([#"{"value":[{"id":"wrong","displayName":"Same name","links":{"oneNoteClientUrl":{"href":"onenote:https://example.sharepoint.com/Documents/Book%2Fother"}}}]}"#])
    let client = GraphClient(authorization: BrowseAuthorization(), transport: transport)
    let entry = StorageEntry(id: "package", name: "Same name", kind: .notebook, root: "me", webURL: URL(string: "https://example.sharepoint.com/Documents/Book%252Fother")!)
    await #expect(throws: NotesError.self) { try await client.notebook(for: entry) }
}
