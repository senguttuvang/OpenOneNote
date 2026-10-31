import AppKit
import Foundation
import Testing
import MarkdownNotes
@testable import MarkdownEditor

@Test @MainActor func newSectionUsesNativeInlineNameEntryWithoutASheet() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    try NativeSectionVerification.exercise(at: root)
}

@Test @MainActor func sectionCreationPreservesUniqueNamesCancellationAndExistingNotes() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root))
    let shell = NativeShellState(session: session)
    shell.createPage(notebook: "Synthetic Notebook", section: "Existing")
    session.edit("Keep this content unchanged\n")
    let original = try #require(session.selected)
    shell.createSection()
    #expect(shell.section == "New Section 1")
    #expect(shell.sheet == nil)
    #expect(session.source.isEmpty)
    shell.cancelSectionName()
    shell.perform("New Section")
    #expect(shell.section == "New Section 2")
    shell.sectionNameDraft = "Existing"
    #expect(!shell.finishSectionName())
    #expect(shell.section == "New Section 2")
    #expect(shell.editingSectionID != nil)
    shell.sectionNameDraft = "தமிழ் section"
    #expect(shell.finishSectionName())
    #expect(shell.sections == ["Existing", "New Section 1", "தமிழ் section"])
    #expect(try session.vault.markdown(original) == "Keep this content unchanged\n")
    session.busy = true
    let count = session.notes.count; shell.createSection()
    #expect(session.notes.count == count)
    #expect(shell.sheet == nil)
}

@Test @MainActor func addingAPageCommitsInlineSectionNameFirst() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root))
    let shell = NativeShellState(session: session)
    shell.createSection()
    shell.sectionNameDraft = "Research"
    shell.createPage()
    #expect(shell.editingSectionID == nil)
    #expect(shell.section == "Research")
    #expect(session.notes.count == 2)
    #expect(session.notes.allSatisfy { $0.hierarchy == ["On My Mac", "Research"] })
    #expect(shell.sheet == nil)
}
