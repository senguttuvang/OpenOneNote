import Foundation
import AppKit
import SwiftUI
import Testing
import MarkdownNotes
@testable import MarkdownEditor
import OneNoteGraph

@Test @MainActor func newSectionInCloudDoesNotCreateLocalNoteUnderCloudLabel() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    session.remoteNotebookName = "Cloud notebook"
    session.notebooks = [GraphItem(id: "book", displayName: "Cloud notebook")]
    session.notebookID = "book"
    session.sections = [GraphItem(id: "section", displayName: "Existing")]
    session.sectionID = "section"
    let shell = NativeShellState(session: session)
    shell.createSection()
    #expect(session.notes.isEmpty, "New Section must not create a local note under a cloud notebook label")
    #expect(shell.notebook == "Cloud notebook")
}

private struct SectionAuthorization: GraphAuthorization {
    func accessToken() async throws -> String { "synthetic" }
    func identityKey() async throws -> String { "synthetic-account" }
}
private actor SectionTransport: GraphTransport {
    var responses: [GraphResponse]
    private(set) var requests: [URLRequest] = []
    var slow = false
    var offline = false
    init(_ responses: [GraphResponse]) { self.responses = responses }
    func setSlow(_ value: Bool) { slow = value }
    func setOffline(_ value: Bool) { offline = value }
    func send(_ request: URLRequest) async throws -> GraphResponse {
        requests.append(request)
        if slow { try await Task.sleep(for: .seconds(60)) }
        if offline { throw URLError(.notConnectedToInternet) }
        guard !responses.isEmpty else { throw NotesError.invalid("Unexpected request") }
        return responses.removeFirst()
    }
}
@MainActor private func connectedSectionSession(at directory: URL, transport: SectionTransport) throws -> (MarkdownSession, NativeShellState) {
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    session.graph = GraphClient(authorization: SectionAuthorization(), transport: transport)
    session.root = "sites/synthetic"; session.remoteNotebookName = "Cloud notebook"
    session.notebooks = [GraphItem(id: "book", displayName: "Cloud notebook")]; session.notebookID = "book"
    session.sections = [GraphItem(id: "old-section", displayName: "Existing")]; session.sectionID = "old-section"
    return (session, NativeShellState(session: session))
}
@MainActor private func waitForSectionOperation(_ session: MarkdownSession) async throws {
    for _ in 0..<5000 {
        if !session.busy { return }
        try await Task.sleep(for: .milliseconds(1))
    }
    Issue.record("Cloud operation did not finish")
}

@Test @MainActor func inlineCloudSectionCreatesRealSectionAndPageInSameNotebook() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([
        GraphResponse(data: Data(#"{"id":"created-section","displayName":"Research தமிழ்"}"#.utf8), status: 201),
        GraphResponse(data: Data(#"{"id":"created-page","title":"Untitled Page"}"#.utf8), status: 201),
        GraphResponse(data: Data(#"{"id":"created-page","title":"Untitled Page"}"#.utf8), status: 200),
        GraphResponse(data: Data("<body><p id='empty'></p></body>".utf8), status: 200)
    ])
    let (session, shell) = try connectedSectionSession(at: directory, transport: transport)
    shell.createSection()
    #expect(shell.namingCloudSection)
    #expect(session.notes.isEmpty)
    #expect(shell.sections.contains("New Section 1"))
    shell.sectionNameDraft = "Research தமிழ்"
    _ = shell.finishSectionName()
    #expect(session.busy)
    try await waitForSectionOperation(session)
    shell.followSelection()
    let note = try #require(session.selected)
    #expect(note.identity == PageIdentity(root: "sites/synthetic", pageID: "created-page", accountKey: "synthetic-account"))
    #expect(note.hierarchy == ["Cloud notebook", "Research தமிழ்"])
    #expect(session.sectionID == "created-section")
    #expect(shell.section == "Research தமிழ்")
    #expect(session.notes.count == 1)
    let writes = await transport.requests.filter { $0.httpMethod == "POST" }
    #expect(writes.count == 2)
    #expect(writes.first?.url?.path.hasSuffix("/notebooks/book/sections") == true)
    #expect(writes.last?.url?.path.hasSuffix("/sections/created-section/pages") == true)
    #expect(try JSONDecoder().decode([String: String].self, from: #require(writes.first?.httpBody)) == ["displayName": "Research தமிழ்"])
    let reopened = try MarkdownSession(vault: session.vault)
    #expect(reopened.notes.first?.identity == note.identity)
    #expect(session.cloudActivity == nil)
}

@Test @MainActor func failedSectionPostIsNotRepeatedAfterRetryOrReopenAndPreservesDraft() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([GraphResponse(data: Data(), status: 503)])
    let (session, shell) = try connectedSectionSession(at: directory, transport: transport)
    var draft = try session.vault.createLocal()
    draft.hierarchy = ["Cloud notebook", "test 2"]; try session.vault.saveLedger(draft)
    session.replace(draft); session.select(draft.id); session.edit("User draft remains here — தமிழ்\n")
    #expect(shell.notebookName(draft) == "Cloud notebook (on this Mac)")
    shell.notebook = "Cloud notebook"
    shell.createSection(); shell.sectionNameDraft = "Research"; _ = shell.finishSectionName()
    try await waitForSectionOperation(session)
    #expect(session.selectedID == draft.id)
    #expect(try session.vault.markdown(draft) == "User draft remains here — தமிழ்\n")
    #expect(session.createCloudSection(named: "Research"))
    try await waitForSectionOperation(session)
    #expect(await transport.requests.count == 1)
    let (reopened, _) = try connectedSectionSession(at: directory, transport: transport)
    #expect(reopened.createCloudSection(named: "Research"))
    try await waitForSectionOperation(reopened)
    #expect(await transport.requests.count == 1)
    #expect(reopened.message.contains("No duplicate"))
}

@Test @MainActor func cancellingCloudInlineNamingDoesNotWriteOrSwitchNotebook() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([])
    let (session, shell) = try connectedSectionSession(at: directory, transport: transport)
    shell.createSection(); shell.cancelSectionName()
    #expect(shell.section == "Existing")
    #expect(shell.notebook == "Cloud notebook")
    #expect(shell.sections == ["Existing"])
    #expect(session.notes.isEmpty)
    #expect(await transport.requests.isEmpty)
}

@Test @MainActor func sectionNamingCannotSilentlyChangeRemoteNotebook() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([])
    let (session, shell) = try connectedSectionSession(at: directory, transport: transport)
    shell.createSection(); session.notebookID = "different-book"
    #expect(!shell.finishSectionName())
    #expect(session.message.contains("notebook changed"))
    #expect(await transport.requests.isEmpty)
    #expect(session.notes.isEmpty)
}

@Test @MainActor func confirmedSectionRejectionCanRetryWithoutAmbiguousIntent() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([GraphResponse(data: Data(), status: 403), GraphResponse(data: Data(), status: 403)])
    let (session, _) = try connectedSectionSession(at: directory, transport: transport)
    #expect(session.createCloudSection(named: "Research")); try await waitForSectionOperation(session)
    #expect(try session.vault.creationIntents().isEmpty)
    #expect(session.createCloudSection(named: "Research")); try await waitForSectionOperation(session)
    #expect(await transport.requests.count == 2)
    #expect(session.notes.isEmpty)
}

@Test @MainActor func corruptCreationJournalKeepsExistingNotesAvailableAndRejectsNewWrites() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let note = try vault.createLocal()
    try FileManager.default.createDirectory(at: vault.safeURL(".o2n/config"), withIntermediateDirectories: true)
    try Data("invalid".utf8).write(to: vault.safeURL(".o2n/config/cloud-creation-intents.json"))
    let transport = SectionTransport([])
    let (session, _) = try connectedSectionSession(at: directory, transport: transport)
    #expect(session.creationJournalError != nil)
    session.select(note.id)
    #expect(session.source == note.baselineMarkdown)
    #expect(session.createCloudSection(named: "Research"))
    try await waitForSectionOperation(session)
    #expect(await transport.requests.isEmpty)
    #expect(session.notes.count == 1)
}

@Test @MainActor func cancelledSectionPostRetainsIntentAndNeverAutomaticallyRepeatsWrite() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([]); await transport.setSlow(true)
    let (session, _) = try connectedSectionSession(at: directory, transport: transport)
    #expect(session.createCloudSection(named: "Research"))
    for _ in 0..<1000 { if await !transport.requests.isEmpty { break }; try await Task.sleep(for: .milliseconds(1)) }
    #expect(session.busy)
    #expect(session.cloudActivity == "Creating section…")
    session.cancel(); try await waitForSectionOperation(session)
    #expect(session.message.contains("Cancelled"))
    #expect(session.cloudActivity == nil)
    #expect(session.creationReview.count == 1)
    #expect(session.createCloudSection(named: "research")); try await waitForSectionOperation(session)
    #expect(await transport.requests.count == 1)
    #expect(session.notes.isEmpty)
}

@Test @MainActor func offlineSectionCreationKeepsLocalNotesAndAllowsReconnectRetry() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([GraphResponse(data: Data(), status: 403)])
    await transport.setOffline(true)
    let (session, _) = try connectedSectionSession(at: directory, transport: transport)
    #expect(session.createCloudSection(named: "Research")); try await waitForSectionOperation(session)
    #expect(try session.vault.creationIntents().isEmpty)
    #expect(session.notes.isEmpty)
    await transport.setOffline(false)
    #expect(session.createCloudSection(named: "Research")); try await waitForSectionOperation(session)
    #expect(await transport.requests.count == 2)
    #expect(session.notes.isEmpty)
}

@Test @MainActor func cloudSectionNameUsesRealNativeInlineFieldAndRetainsInvalidDraft() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let (session, shell) = try connectedSectionSession(at: directory, transport: SectionTransport([]))
    let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
    shell.window = window; window.contentView = host; host.frame = window.contentLayoutRect
    func settle() { host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.15)) }
    settle(); shell.createSection(); settle()
    let field = try #require(window.firstResponder as? NSTextView)
    #expect(field.isFieldEditor)
    #expect(field.string == "New Section 1")
    field.insertText("Invalid/name", replacementRange: NSRange(location: 0, length: field.string.utf16.count))
    field.doCommand(by: NSSelectorFromString("insertNewline:")); settle()
    #expect(shell.sectionNameDraft == "Invalid/name")
    #expect(shell.namingCloudSection)
    #expect(!session.busy)
    #expect(session.notes.isEmpty)
    #expect(!window.isVisible)
    #expect(NSApp.activationPolicy() == .prohibited)
    shell.cancelSectionName()
}

@Test @MainActor func failedCloudSectionKeepsInlineNameForCorrectionOrRetry() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([GraphResponse(data: Data(), status: 403)])
    let (session, shell) = try connectedSectionSession(at: directory, transport: transport)
    shell.createSection(); shell.sectionNameDraft = "Keep my section name"
    _ = shell.finishSectionName(); try await waitForSectionOperation(session)
    #expect(shell.namingCloudSection)
    #expect(shell.sectionNameDraft == "Keep my section name")
    #expect(shell.editingSectionID != nil)
    #expect(session.notes.isEmpty)
    shell.cancelSectionName()
    #expect(shell.section == "Existing")
}

@Test @MainActor func confirmedCloudPageCanBeReopenedAfterFailureWithoutASecondPost() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let transport = SectionTransport([
        GraphResponse(data: Data(#"{"id":"created-page","title":"Untitled Page"}"#.utf8), status: 201),
        GraphResponse(data: Data(), status: 403),
        GraphResponse(data: Data(#"{"id":"created-page","title":"Untitled Page"}"#.utf8), status: 200),
        GraphResponse(data: Data(#"{"id":"created-page","title":"Untitled Page"}"#.utf8), status: 200),
        GraphResponse(data: Data("<body><p id='empty'></p></body>".utf8), status: 200)
    ])
    let (session, _) = try connectedSectionSession(at: directory, transport: transport)
    session.createCloudPage(); try await waitForSectionOperation(session)
    #expect(session.notes.isEmpty)
    #expect(session.pages.map(\.id) == ["created-page"])
    #expect(try session.vault.creationIntents().first?.createdID == "created-page")
    let (reopened, _) = try connectedSectionSession(at: directory, transport: transport)
    reopened.createCloudPage(); try await waitForSectionOperation(reopened)
    #expect(reopened.selected?.identity.pageID == "created-page")
    #expect(reopened.selected?.notebookID == "book")
    #expect(reopened.selected?.sectionID == "old-section")
    #expect(try reopened.vault.creationIntents().isEmpty)
    #expect(await transport.requests.filter { $0.httpMethod == "POST" }.count == 1)
}
