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
