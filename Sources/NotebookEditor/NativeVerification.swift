import AppKit
import SwiftUI

public enum EditorVerificationError: Error { case failed(String) }

@MainActor public enum NativeVerification {
    public static func exerciseEditor(at url: URL) throws {
        let session = NotebookSession(url: url)
        guard let page = session.selectedPage, let block = page.blocks.first else { throw EditorVerificationError.failed("No initial page") }
        var failure: Error?
        let editor = RichTextEditor(text: block.text, richText: nil, undoManager: session.undoManager,
            onChange: { session.editText(pageID: page.id, blockID: block.id, text: $0, richText: $1) }, onError: { failure = $0 })
        let coordinator = editor.makeCoordinator()
        let view = editor.makeTextView(coordinator: coordinator)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = view
        window.makeFirstResponder(view)
        let previous = view.string
        session.undoManager.beginUndoGrouping()
        view.insertText("தமிழ் — Native editing 👋", replacementRange: NSRange(location: 0, length: view.string.utf16.count))
        session.undoManager.endUndoGrouping()
        guard failure == nil, view.string == "தமிழ் — Native editing 👋", session.selectedPage?.blocks.first?.text == view.string else {
            throw EditorVerificationError.failed("Native edit did not reach the model: \(String(describing: failure))")
        }
        session.undoManager.undo()
        guard view.string == previous else { throw EditorVerificationError.failed("Native text undo failed") }
        session.undoManager.redo()
        let bold = NSSelectorFromString("toggleBoldface:")
        guard view.responds(to: bold), view.responds(to: NSSelectorFromString("toggleItalics:")) else {
            throw EditorVerificationError.failed("Native format actions unavailable")
        }
        view.setSelectedRange(NSRange(location: 0, length: view.string.utf16.count))
        view.perform(bold, with: nil)
        guard let encoded = session.selectedPage?.blocks.first?.richText,
              let font = try RichTextCodec.decode(encoded).attribute(.font, at: 0, effectiveRange: nil) as? NSFont,
              NSFontManager.shared.traits(of: font).contains(.boldFontMask) else {
            throw EditorVerificationError.failed("Native bold action was not persisted")
        }
        guard session.saveNow() else { throw EditorVerificationError.failed("Save failed") }
        let reopened = NotebookSession(url: url)
        guard reopened.notebook == session.notebook else { throw EditorVerificationError.failed("Reopen changed the notebook") }
        withExtendedLifetime(coordinator) {}
    }

    public static func render(session: NotebookSession, to url: URL, width: Double, height: Double) throws {
        guard width.isFinite, height.isFinite, width >= 960, width <= 2560, height >= 600, height <= 2000 else {
            throw EditorVerificationError.failed("Preview dimensions are outside the supported window range")
        }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: width, height: height), styleMask: [.borderless], backing: .buffered, defer: false)
        let host = NSHostingView(rootView: EditorView(session: session))
        host.frame = NSRect(x: 0, y: 0, width: width, height: height)
        window.contentView = host
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        window.display()
        guard let bitmap = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { throw EditorVerificationError.failed("Cannot allocate native preview") }
        host.cacheDisplay(in: host.bounds, to: bitmap)
        guard let png = bitmap.representation(using: .png, properties: [:]) else { throw EditorVerificationError.failed("Cannot encode native preview") }
        try png.write(to: url, options: .atomic)
    }
}
