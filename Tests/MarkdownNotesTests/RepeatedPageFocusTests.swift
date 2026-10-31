import AppKit
import SwiftUI
import Testing
import MarkdownNotes
import MarkdownEditor

@Test @MainActor func repeatedPageCreationRefocusesTitleAfterFooterTakesFocus() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root))
    let shell = NativeShellState(session: session)
    let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
    shell.window = window; window.contentView = host; host.frame = window.contentLayoutRect
    func settle() { host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.1)) }
    settle(); shell.createPage(); settle()
    #expect((window.firstResponder as? NSTextView)?.isFieldEditor == true)
    for number in 1...3 {
        // The live footer click relinquishes the field before issuing the next request.
        window.makeFirstResponder(nil)
        shell.createPage(); settle()
        let title = try #require(window.firstResponder as? NSTextView)
        #expect(title.isFieldEditor)
        title.insertText("Synthetic page \(number)", replacementRange: NSRange(location: 0, length: title.string.utf16.count))
        window.makeFirstResponder(nil)
        #expect(session.selected?.title == "Synthetic page \(number)")
    }
    #expect(session.notes.count == 4)
    #expect(!window.isVisible)
}
