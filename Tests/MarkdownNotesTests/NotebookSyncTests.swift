import Foundation
import Testing
import MarkdownNotes
@testable import MarkdownEditor
import OneNoteGraph

private struct NotebookAuthorization: GraphAuthorization {
    func accessToken() async throws -> String { "synthetic" }
    func identityKey() async throws -> String { "account-a" }
}
private actor NotebookTransport: GraphTransport {
    var slow = false
    var failure = false
    private(set) var requests: [URLRequest] = []
    func setSlow(_ value: Bool) { slow = value }
    func setFailure(_ value: Bool) { failure = value }
    func send(_ request: URLRequest) async throws -> GraphResponse {
        requests.append(request)
        if slow { try await Task.sleep(for: .seconds(60)) }
        if failure { return GraphResponse(data: Data(), status: 403) }
        let path = try #require(request.url).path
        let body: String
        if path.hasSuffix("/notebooks/book-a/sections") { body = #"{"value":[{"id":"section-a","displayName":"Section"}]}"# }
        else if path.hasSuffix("/notebooks/book-a/sectionGroups") { body = #"{"value":[]}"# }
        else if path.hasSuffix("/sections/section-a/pages") { body = #"{"value":[{"id":"page-a","title":"Cloud page"}]}"# }
        else if path.hasSuffix("/pages/page-a/content") { body = "<body><p id='p'>Cloud content</p></body>" }
        else if path.hasSuffix("/pages/page-a") { body = #"{"id":"page-a","title":"Cloud page"}"# }
        else { throw NotesError.invalid("Sync left the selected notebook/account: \(path)") }
        return GraphResponse(data: Data(body.utf8), status: 200)
    }
}
@MainActor private func notebookFixture(_ directory: URL, _ transport: NotebookTransport) throws -> (MarkdownSession, NativeShellState) {
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    session.graph = GraphClient(authorization: NotebookAuthorization(), transport: transport)
    session.root = "sites/fixture"; session.remoteNotebookName = "Cloud"
    session.remoteAccountKey = "account-a"
    session.notebooks = [GraphItem(id: "book-a", displayName: "Cloud")]; session.notebookID = "book-a"
    session.sections = [GraphItem(id: "section-a", displayName: "Section")]; session.sectionID = "section-a"
    return (session, NativeShellState(session: session))
}
@MainActor private func finishNotebookSync(_ session: MarkdownSession) async throws {
    for _ in 0..<5000 { if !session.busy { return }; try await Task.sleep(for: .milliseconds(1)) }
    Issue.record("Notebook sync did not settle")
}

@Test @MainActor func notebookSyncUsesRemoteIDsAndPreservesLocalDraftsWithSameLabel() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = NotebookTransport()
    let (session, shell) = try notebookFixture(directory, transport)
    var local = try session.vault.createLocal(); local.hierarchy = ["Cloud", "Section"]
    try session.vault.saveLedger(local); session.replace(local); session.select(local.id)
    session.edit("Offline user draft\n")
    shell.notebook = "Cloud"
    #expect(shell.canPerform("Sync This Notebook"))
    #expect(shell.canPerform("Sync All Notebooks"))
    shell.perform("Sync This Notebook")
    #expect(session.cloudActivity != nil)
    #expect(!shell.canPerform("Sync This Notebook"))
    #expect(shell.canPerform("Cancel Sync"))
    try await finishNotebookSync(session)
    #expect(session.notes.count == 2)
    #expect(session.selectedID == local.id)
    #expect(session.source == "Offline user draft\n")
    #expect(try session.vault.markdown(local) == "Offline user draft\n")
    let cloud = try #require(session.notes.first { $0.identity.pageID == "page-a" })
    #expect(cloud.identity.accountKey == "account-a")
    #expect(cloud.lastSyncedAt != nil)
    #expect(cloud.hierarchy == ["Cloud", "Section"])
    #expect(session.lastSyncAt != nil)
    #expect(session.cloudActivity == nil)
    #expect(await transport.requests.allSatisfy { $0.httpMethod == "GET" })
}

@Test @MainActor func allNotebookSyncExcludesOtherAccountsAndFailsClosedOnAccountChange() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = NotebookTransport()
    let (session, _) = try notebookFixture(directory, transport)
    session.recentNotebooks = [RecentNotebook(root: "sites/other", notebookID: "private-other-account", name: "Cloud", accountKey: "account-b", openedAt: Date())]
    session.syncNotebooks(all: true); try await finishNotebookSync(session)
    #expect(session.lastSyncAt != nil)
    #expect(await transport.requests.allSatisfy { $0.url?.path.contains("sites/fixture/") == true })
    let count = await transport.requests.count
    session.remoteAccountKey = "account-b"
    session.syncNotebooks(all: true); try await finishNotebookSync(session)
    #expect(await transport.requests.count == count)
    #expect(session.syncFailure != nil)
}

@Test @MainActor func slowNotebookSyncShowsRealPendingStateAndCancellationPreservesNotes() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = NotebookTransport(); await transport.setSlow(true)
    let (session, shell) = try notebookFixture(directory, transport)
    shell.perform("Sync This Notebook")
    for _ in 0..<1000 { if await !transport.requests.isEmpty { break }; try await Task.sleep(for: .milliseconds(1)) }
    #expect(session.busy)
    #expect(shell.visibleStatus.contains("Syncing"))
    #expect(session.lastSyncAt == nil)
    session.cancel(); try await finishNotebookSync(session)
    #expect(!session.busy)
    #expect(session.cloudActivity == nil)
    #expect(session.lastSyncAt == nil)
    #expect(session.message.contains("Cancelled"))
    #expect(session.notes.isEmpty)
    await transport.setSlow(false)
    session.syncNotebooks(all: false); try await finishNotebookSync(session)
    #expect(session.lastSyncAt != nil)
}

@Test @MainActor func notebookFailureDoesNotInventSuccessAndCanRetry() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = NotebookTransport(); await transport.setFailure(true)
    let (session, _) = try notebookFixture(directory, transport)
    session.syncNotebooks(all: false); try await finishNotebookSync(session)
    #expect(session.lastSyncAt == nil)
    #expect(session.syncFailure != nil)
    #expect(!session.busy)
    await transport.setFailure(false)
    session.syncNotebooks(all: false); try await finishNotebookSync(session)
    #expect(session.syncFailure == nil)
    #expect(session.lastSyncAt != nil)
}
