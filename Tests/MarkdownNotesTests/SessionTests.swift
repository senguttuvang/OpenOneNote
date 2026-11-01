import Foundation
import Testing
import MarkdownNotes
import MarkdownEditor

@Test @MainActor func busySyncPreventsNavigationFromCrossingNoteIdentity() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let first = NoteLedger(identity: PageIdentity(pageID: "synthetic-first"), title: "First", baseline: try MarkdownConversion().parse("First\n"), markdown: "First\n", htmlHash: "base", assets: [])
    let second = NoteLedger(identity: PageIdentity(pageID: "synthetic-second"), title: "Second", baseline: try MarkdownConversion().parse("Second\n"), markdown: "Second\n", htmlHash: "base", assets: [])
    try vault.create(first); try vault.create(second)
    let session = try MarkdownSession(vault: vault)
    session.select(first.id); session.busy = true; session.select(second.id)
    #expect(session.selectedID == first.id)
    #expect(session.source == "First\n")
    #expect(try vault.markdown(second) == "Second\n")
}

@Test @MainActor func externalFileEditsArePreservedUntilExplicitResolution() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let ledger = try vault.createLocal()
    let session = try MarkdownSession(vault: vault); session.select(ledger.id)
    try vault.writeMarkdown("External edit\n", ledger: ledger)
    session.edit("Native edit\n")
    #expect(try vault.markdown(ledger) == "External edit\n")
    #expect(session.selected?.externalRecoveryMarkdown == "External edit\n")
    #expect(session.selected?.pendingMarkdown == "Native edit\n")
    session.resolveExternal(keepEdited: false)
    #expect(session.source == "External edit\n")
    #expect(session.selected?.recoveryVersions?.last?.localMarkdown == "Native edit\n")
    try vault.writeMarkdown("Another external edit\n", ledger: ledger)
    session.edit("Chosen native edit\n")
    session.resolveExternal(keepEdited: true)
    #expect(try vault.markdown(ledger) == "Chosen native edit\n")
    #expect(session.selected?.state == "local-only")
}

@Test @MainActor func interruptedSaveShowsPendingSourceAndNeverAutoOverwritesExternalFile() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    var ledger = try vault.createLocal()
    ledger.pendingMarkdown = "Pending native source\n"; ledger.state = "local-only"
    try vault.saveLedger(ledger)
    let session = try MarkdownSession(vault: vault); session.select(ledger.id)
    #expect(session.source == "Pending native source\n")
    #expect(session.selected?.externalRecoveryMarkdown != nil)
    #expect(!session.save())
    #expect(try vault.markdown(ledger).contains("Untitled note"))
    session.resolveExternal(keepEdited: true)
    #expect(try vault.markdown(ledger) == "Pending native source\n")
}

@Test @MainActor func sourceEditsKeepRemoteProtectionWarningsVisible() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    var ledger = try vault.createLocal()
    ledger.baseline.warnings = ["Diagram source is stale; image and attachment retained"]
    try vault.saveLedger(ledger)
    let session = try MarkdownSession(vault: vault); session.select(ledger.id)
    session.edit("# Editing safely\n")
    #expect(session.preview.warnings == ledger.baseline.warnings)
}

@Test @MainActor func unchangedSyncedPageSaveDoesNotCreateOutboxOrInventSyncTime() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    var note = try vault.createLocal()
    note.identity = PageIdentity(root: "sites/synthetic", pageID: "page", accountKey: "account")
    note.state = "synced"; note.pendingMarkdown = nil; note.lastSyncedAt = Date(timeIntervalSince1970: 100)
    try vault.saveLedger(note)
    let session = try MarkdownSession(vault: vault); session.select(note.id)
    #expect(session.save())
    #expect(session.selected?.state == "synced")
    #expect(session.selected?.pendingMarkdown == nil)
    #expect(session.selected?.lastSyncedAt == Date(timeIntervalSince1970: 100))
    session.edit("Changed\n")
    #expect(session.selected?.state == "outbox")
    #expect(session.selected?.lastSyncedAt == Date(timeIntervalSince1970: 100))
}

@Test @MainActor func normalWorkspaceReusesSharedPublicRegistrationWithoutCopyingNotesOrConfig() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let shared = directory.appendingPathComponent("shared")
    let workspace = directory.appendingPathComponent("workspace")
    let sharedVault = try MarkdownVault(root: shared)
    try FileManager.default.createDirectory(at: sharedVault.safeURL(".o2n/config"), withIntermediateDirectories: true)
    let metadata = #"{"clientID":"11111111-1111-1111-1111-111111111111","tenant":"22222222-2222-2222-2222-222222222222","redirectURI":"msauth.dev.senguttuvang.OpenOneNote://auth","graphRoot":"sites/synthetic"}"#
    try Data(metadata.utf8).write(to: sharedVault.safeURL(".o2n/config/microsoft-client.json"))
    let app = try MarkdownApplication(vault: workspace, sharedMicrosoftWorkspace: shared)
    #expect(app.session.microsoftConfiguration?.clientID == "11111111-1111-1111-1111-111111111111")
    #expect(app.session.root == "sites/synthetic")
    #expect(app.session.account == nil)
    #expect(app.session.notes.isEmpty)
    #expect(!FileManager.default.fileExists(atPath: try app.session.vault.safeURL(".o2n/config/microsoft-client.json").path))
}
