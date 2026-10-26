import AppKit
import SwiftUI
import MarkdownNotes

@MainActor public enum MarkdownVerification {
    public static func exercise(at directory: URL) throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Native verification must prohibit activation") }
        let vault = try MarkdownVault(root: directory)
        let codec = MarkdownConversion()
        let source = "# Synthetic field notes\n\nA **formatted** local Markdown page.\n\n| Item | State |\n| --- | --- |\n| Sync | Ready |\n"
        let ledger = NoteLedger(identity: PageIdentity(pageID: "synthetic-local"), title: "Synthetic field notes", baseline: try codec.parse(source), markdown: source, htmlHash: "fixture", assets: [])
        try vault.create(ledger)
        let session = try MarkdownSession(vault: vault); session.select(ledger.id)
        let editor = MarkdownSourceEditor(source: source, identity: ledger.id, onChange: session.edit)
        let coordinator = editor.makeCoordinator(); let view = editor.makeTextView(coordinator: coordinator)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = view; window.makeFirstResponder(view)
        view.undoManager?.beginUndoGrouping()
        view.insertText("# தமிழ் — Offline edit\n", replacementRange: NSRange(location: 0, length: view.string.utf16.count))
        view.undoManager?.endUndoGrouping()
        guard session.source == view.string, try vault.markdown(ledger) == view.string else { throw NotesError.invalid("Native source edit did not persist") }
        view.undoManager?.undo()
        guard view.string == source else { throw NotesError.invalid("Markdown native undo failed") }
        view.undoManager?.redo()
        let reopened = try MarkdownSession(vault: vault); reopened.select(ledger.id)
        guard reopened.source == view.string else { throw NotesError.invalid("Markdown reopen failed") }
        let reading = try MarkdownSession(vault: vault)
        reading.select(ledger.id); reading.edit(source)
        for width in [1280.0, 960.0] { try render(session: reading, to: directory.appendingPathComponent("preview-\(Int(width)).png"), width: width) }
        guard !window.isVisible, NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Native test changed focus policy") }
    }
    public static func render(session: MarkdownSession, to url: URL, width: Double) throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Preview requires prohibited activation") }
        let host = NSHostingView(rootView: MarkdownEditorView(session: session))
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: width, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: .darkAqua)
        window.contentView = host
        host.frame = NSRect(x: 0, y: 0, width: width, height: 800)
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        window.display()
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(width), pixelsHigh: 800, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { throw NotesError.invalid("Cannot allocate Markdown preview") }
        bitmap.size = host.frame.size; host.cacheDisplay(in: host.bounds, to: bitmap)
        guard let data = bitmap.representation(using: .png, properties: [:]) else { throw NotesError.invalid("Cannot encode Markdown preview") }
        try data.write(to: url, options: .atomic)
    }
}
