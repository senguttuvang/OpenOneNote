import AppKit
import SwiftUI
import MarkdownNotes

@MainActor enum NativeSectionVerification {
    static func exercise(at directory: URL) throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Section verification requires hidden windows") }
        let session = try MarkdownSession(vault: MarkdownVault(root: directory))
        let shell = NativeShellState(session: session)
        shell.createPage(notebook: "Synthetic Notebook", section: "Existing section")
        session.edit("Existing synthetic content — தமிழ் 📝\n")
        guard let original = session.selected else { throw NotesError.invalid("Missing original fixture") }
        let preserved = try session.vault.markdown(original)
        let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
        shell.window = window; window.contentView = host; host.frame = window.contentLayoutRect
        func settle() { host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.15)) }
        settle(); shell.perform("New Section"); settle()
        guard shell.sheet == nil, window.sheets.isEmpty, session.source.isEmpty,
              shell.section == "New Section 1", let field = window.firstResponder as? NSTextView,
              field.isFieldEditor, field.string == "New Section 1",
              field.selectedRange() == NSRange(location: 0, length: "New Section 1".utf16.count) else {
            throw NotesError.invalid("New Section did not immediately create/select and focus its inline name")
        }
        field.insertText("Synthetic inline section", replacementRange: NSRange(location: 0, length: field.string.utf16.count))
        field.doCommand(by: NSSelectorFromString("insertNewline:")); settle()
        guard shell.editingSectionID == nil, shell.section == "Synthetic inline section", let created = session.selected,
              created.hierarchy == ["Synthetic Notebook", "Synthetic inline section"],
              try session.vault.markdown(original) == preserved else {
            throw NotesError.invalid("Inline section rename failed (editing: \(shell.editingSectionID != nil), selected name matched: \(shell.section == "Synthetic inline section")) or changed existing content")
        }
        guard let pageTitle = window.firstResponder as? NSTextView, pageTitle.isFieldEditor, pageTitle.string.isEmpty else {
            throw NotesError.invalid("Return did not move from the inline section name to the page title")
        }
        let reopened = try MarkdownSession(vault: session.vault); reopened.select(created.id)
        guard reopened.selected?.hierarchy == created.hierarchy, reopened.source.isEmpty,
              !window.isVisible, NSApp.activationPolicy() == .prohibited else {
            throw NotesError.invalid("Inline section reopen/focus preservation failed")
        }
        shell.createSection(); settle()
        guard let cancelledName = shell.editingSectionName, let cancelField = window.firstResponder as? NSTextView else {
            throw NotesError.invalid("Repeated section creation did not focus its name")
        }
        cancelField.doCommand(by: NSSelectorFromString("cancelOperation:")); settle()
        guard shell.editingSectionID == nil, shell.section == cancelledName else {
            throw NotesError.invalid("Escape did not keep the generated section without a naming dialog")
        }
        shell.createSection(); settle()
        try MarkdownVerification.capture(MarkdownEditorView(session: session, presentation: shell),
                                         to: directory.appendingPathComponent("inline-section.png"), width: 1280, height: 800)
    }
}
