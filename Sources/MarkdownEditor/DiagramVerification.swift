import AppKit
import Foundation
import MarkdownNotes

@MainActor public enum DiagramVerification {
    public static func exercise(at directory: URL) async throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Diagram tests must prohibit activation") }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let source = "flowchart LR\n A[Local Markdown] --> B[OneNote page]\n"
        let data = try await MermaidRenderer().png(source: source)
        guard let image = NSImage(data: data), image.size.width > 100, image.size.height > 50 else { throw NotesError.invalid("Diagram PNG did not decode") }
        try data.write(to: directory.appendingPathComponent("diagram.png"), options: .atomic)
        let vault = try MarkdownVault(root: directory.appendingPathComponent("vault"))
        let markdown = "# Diagram source and preview\n\n```mermaid\n" + source + "```\n"
        let ledger = NoteLedger(identity: PageIdentity(pageID: "synthetic-diagram-preview"), title: "Diagram source and preview", baseline: try MarkdownConversion().parse(markdown), markdown: markdown, htmlHash: "fixture", assets: [])
        try vault.create(ledger)
        let session = try MarkdownSession(vault: vault); session.select(ledger.id)
        try MarkdownVerification.render(session: session, to: directory.appendingPathComponent("diagram-editor.png"), width: 1280)
        do { _ = try await MermaidRenderer().png(source: "this is not valid Mermaid {}{}") }
        catch { print("Offline diagram PNG rendered; malformed source rejected; windows remained hidden"); return }
        throw NotesError.invalid("Renderer accepted malformed diagram")
    }
}
