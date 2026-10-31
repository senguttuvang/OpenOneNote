import AppKit
import SwiftUI
import MarkdownNotes

/// Packaged-binary acceptance in hidden synthetic windows, separate from live auth.
@MainActor enum NativeRichVerification {
    static func exercise(at directory: URL) throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Rich verification requires prohibited activation") }
        let session = try MarkdownSession(vault: MarkdownVault(root: directory))
        let shell = NativeShellState(session: session)
        let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
        shell.window = window; window.contentView = host; host.frame = window.contentLayoutRect
        func settle() { host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.1)) }
        settle(); shell.createPage(notebook: "Synthetic Notebook", section: "Native Editing"); settle()
        guard shell.sheet == nil, session.source.isEmpty, let title = window.firstResponder as? NSTextView, title.isFieldEditor else {
            throw NotesError.invalid("Add page did not create a blank page and focus its inline title")
        }
        try MarkdownVerification.render(session: session, to: directory.appendingPathComponent("new-page.png"), width: 1728)
        window.makeFirstResponder(nil); shell.createPage(); settle()
        guard let repeatedTitle = window.firstResponder as? NSTextView, repeatedTitle.isFieldEditor else {
            throw NotesError.invalid("Repeated Add page did not restore title focus")
        }
        repeatedTitle.insertText("Synthetic rich page", replacementRange: NSRange(location: 0, length: repeatedTitle.string.utf16.count))
        guard let rich = shell.richCommands.target, let source = shell.sourceCommands.target else { throw NotesError.invalid("Native projections did not mount") }
        window.makeFirstResponder(rich)
        rich.insertText("தமிழ் 📝 ordinary editing", replacementRange: NSRange(location: 0, length: 0))
        let range = (rich.string as NSString).range(of: "தமிழ் 📝")
        rich.setSelectedRange(range); shell.format("Bold"); settle()
        guard session.source.contains("**தமிழ் 📝**"), !rich.string.contains("**"), session.selected?.title == "Synthetic rich page" else {
            throw NotesError.invalid("Rich typing/title/format persistence failed")
        }
        for visible in [true, false, true, false] {
            shell.markdownVisible = visible; settle()
            guard shell.richCommands.target === rich, shell.sourceCommands.target === source,
                  rich.selectedRange() == range, rich.undoManager?.canUndo == true else { throw NotesError.invalid("Projection toggle lost native view/selection/undo") }
        }
        rich.undoManager?.undo()
        guard !session.source.contains("**") else { throw NotesError.invalid("Rich undo failed") }
        rich.undoManager?.redo()
        rich.setSelectedRange(NSRange(location: rich.string.utf16.count, length: 0)); shell.richCommands.insertTable(rows: 3, columns: 2)
        let cell = (rich.string as NSString).range(of: "Cell")
        guard cell.location != NSNotFound else { throw NotesError.invalid("Native rich table did not insert") }
        rich.insertText("Avery", replacementRange: cell); settle()
        guard session.source.contains("| Avery | Cell |"), let id = session.selectedID else { throw NotesError.invalid("Native table edit did not persist") }
        let reopened = try MarkdownSession(vault: session.vault); reopened.select(id)
        guard reopened.source == session.source, reopened.selected?.title == "Synthetic rich page", !window.isVisible else { throw NotesError.invalid("Rich reopen/focus preservation failed") }
        try MarkdownVerification.render(session: session, to: directory.appendingPathComponent("rich-edit.png"), width: 1280)
    }
}
