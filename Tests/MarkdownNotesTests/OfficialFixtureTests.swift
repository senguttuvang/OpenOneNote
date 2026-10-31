import AppKit
import Foundation
import Testing
import MarkdownNotes
@testable import MarkdownEditor

@Test @MainActor func officialFixtureUsesDefaultRichEditorAndRibbonWithoutChangingSavedSource() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let session = try MarkdownSession(vault: vault)
    session.newLocal(); session.edit("Synthetic acceptance base\n")
    let image = try vault.storeAsset(CloudVerification.fixturePNG(), resourceURL: "", extension: "png")
    let diagram = "flowchart LR\n O2N-->Official\n"
    let window = try CloudVerification.editRoundtripFixture(session: session, outgoing: "SYNTHETIC-OUTGOING", imagePath: image.path, diagramSource: diagram)
    defer { withExtendedLifetime(window) {} }
    let ledger = try #require(session.selected)
    #expect(session.source.contains("Synthetic acceptance base"))
    #expect(session.source.contains("**SYNTHETIC-OUTGOING**"))
    #expect(session.source.contains("| O2N native |"))
    #expect(session.source.contains("![Synthetic blue square](\(image.path))"))
    #expect(session.source.contains("```mermaid\n" + diagram + "```"))
    #expect(try vault.markdown(ledger) == session.source)
    #expect(!window.isVisible)
    let reopened = try MarkdownSession(vault: vault)
    reopened.select(ledger.id)
    #expect(reopened.source == session.source)
}
