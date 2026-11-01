import AppKit
import SwiftUI
import Testing
import MarkdownNotes
import MarkdownEditor
import OneNoteGraph

private struct NavigationAuthorization: GraphAuthorization {
    func accessToken() async throws -> String { "synthetic" }
    func identityKey() async throws -> String { "synthetic" }
}
private actor DelayedNavigationTransport: GraphTransport {
    private var pending: CheckedContinuation<GraphResponse, Never>?
    private(set) var started = false
    func send(_ request: URLRequest) async throws -> GraphResponse {
        started = true
        return await withCheckedContinuation { pending = $0 }
    }
    func finish(_ response: GraphResponse = GraphResponse(data: Data(), status: 401)) {
        pending?.resume(returning: response); pending = nil
    }
}

private actor DelayedReadRemote: OneNoteRemote {
    private var continuation: CheckedContinuation<RemotePage, Never>?
    var delay = false
    private(set) var started = false
    func enableDelay() { delay = true }
    func fetch(_ identity: PageIdentity) async throws -> RemotePage {
        if delay { started = true; return await withCheckedContinuation { continuation = $0 } }
        return RemotePage(id: identity.pageID, title: "Synthetic", html: "<body><p id='p'>Original</p></body>")
    }
    func finish() {
        continuation?.resume(returning: RemotePage(id: "synthetic", title: "Synthetic", html: "<body><p id='p'>Remote update</p></body>"))
        continuation = nil
    }
    func resource(_ url: URL) throws -> Data { throw NotesError.invalid("Unexpected resource") }
    func update(_ identity: PageIdentity, commands: [PageCommand], parts: [BinaryPart]) throws { throw NotesError.invalid("Read-only refresh must not write") }
}

@Test func delayedReadOnlyRefreshPreservesNewerOfflineEdit() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory), remote = DelayedReadRemote()
    let sync = NoteSync(vault: vault, remote: remote)
    let note = try await sync.open(PageIdentity(pageID: "synthetic"))
    await remote.enableDelay()
    let read = Task { try await sync.sync(note.id, allowPush: false) }
    for _ in 0..<2000 { if await remote.started { break }; try await Task.sleep(for: .milliseconds(1)) }
    #expect(await remote.started)
    _ = try await sync.save(note.id, markdown: "New offline edit\n")
    await remote.finish()
    let result = try await read.value
    #expect(result.state == "outbox")
    #expect(try vault.markdown(result) == "New offline edit\n")
    #expect(try vault.load(note.id).pendingMarkdown == result.pendingMarkdown)
}

@Test func cancelledReadOnlyRefreshLeavesLedgerAndSourceUntouched() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory), remote = DelayedReadRemote()
    let sync = NoteSync(vault: vault, remote: remote)
    let note = try await sync.open(PageIdentity(pageID: "synthetic"))
    let originalLedger = try Data(contentsOf: vault.safeURL(".o2n/\(note.id.uuidString).json"))
    await remote.enableDelay()
    let read = Task { try await sync.sync(note.id, allowPush: false) }
    for _ in 0..<2000 { if await remote.started { break }; try await Task.sleep(for: .milliseconds(1)) }
    #expect(await remote.started)
    read.cancel(); await remote.finish()
    do { _ = try await read.value; Issue.record("Cancelled refresh unexpectedly committed") }
    catch { #expect(error is CancellationError) }
    #expect(try vault.markdown(note) == note.baselineMarkdown)
    #expect(try Data(contentsOf: vault.safeURL(".o2n/\(note.id.uuidString).json")) == originalLedger)
}

@Test @MainActor func backgroundRefreshDoesNotDisableOrStealNavigation() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    var cloud = try vault.createLocal(); cloud.identity = PageIdentity(pageID: "synthetic-cloud", accountKey: "synthetic")
    cloud.hierarchy = ["Cloud", "First"]; try vault.saveLedger(cloud)
    let local = try vault.createLocal()
    let session = try MarkdownSession(vault: vault); session.select(cloud.id)
    let transport = DelayedNavigationTransport()
    session.graph = GraphClient(authorization: NavigationAuthorization(), transport: transport)
    session.refreshSelectedPage(forceContent: false)
    for _ in 0..<2000 { if await transport.started { break }; try await Task.sleep(for: .milliseconds(1)) }
    #expect(await transport.started)
    #expect(!session.busy)
    session.select(local.id)
    #expect(session.selectedID == local.id)
    session.edit("Local edit while remote request is delayed\n")
    await transport.finish()
    for _ in 0..<100 { await Task.yield() }
    #expect(session.selectedID == local.id)
    #expect(session.source == "Local edit while remote request is delayed\n")
    #expect(try vault.markdown(local) == session.source)
    #expect(session.syncErrors[local.id] == nil)
    session.stopBackgroundRefresh()
}

@Test @MainActor func splitEditorSettlesWithoutSelectionNotificationFeedback() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = try MarkdownSession(vault: MarkdownVault(root: directory)); session.newLocal(); session.edit("Text\n")
    let shell = NativeShellState(session: session); shell.markdownVisible = true; shell.mode = .split
    let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
    host.frame = NSRect(x: 0, y: 0, width: 1280, height: 800)
    let window = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = host
    defer { window.contentView = nil }
    host.layoutSubtreeIfNeeded()
    RunLoop.main.run(until: Date().addingTimeInterval(0.15))
    let revision = shell.sourceCommands.selectionRevision
    for _ in 0..<5 {
        shell.search = shell.search.isEmpty ? "Text" : ""
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.03))
    }
    #expect(shell.sourceCommands.selectionRevision == revision)
    #expect(session.source == "Text\n")
}

@Test @MainActor func remoteSectionNavigationClearsOldPageAndKeepsRequestedSection() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    var note = try vault.createLocal(); note.hierarchy = ["Synthetic cloud", "First"]
    note.identity = PageIdentity(pageID: "old-page", accountKey: "synthetic"); try vault.saveLedger(note)
    let session = try MarkdownSession(vault: vault); session.select(note.id)
    session.remoteNotebookName = "Synthetic cloud"
    session.sections = [GraphItem(id: "first", displayName: "First"), GraphItem(id: "second", displayName: "Second")]
    session.sectionID = "first"
    let transport = DelayedNavigationTransport()
    session.graph = GraphClient(authorization: NavigationAuthorization(), transport: transport)
    let shell = NativeShellState(session: session)
    shell.selectSection("Second")
    #expect(session.selectedID == nil)
    #expect(session.source.isEmpty)
    #expect(session.pages.isEmpty)
    shell.followSelection()
    #expect(shell.section == "Second")
    for _ in 0..<2000 { if await transport.started { break }; try await Task.sleep(for: .milliseconds(1)) }
    await transport.finish(GraphResponse(data: Data(#"{"value":[{"id":"second-page","title":"Page in second section"}]}"#.utf8), status: 200))
    for _ in 0..<2000 { if !session.busy { break }; try await Task.sleep(for: .milliseconds(1)) }
    #expect(!session.busy)
    #expect(session.pages.map(\.id) == ["second-page"])
    #expect(shell.section == "Second")
    #expect(session.selectedID == nil)
    #expect(try vault.markdown(note) == note.baselineMarkdown)
}
