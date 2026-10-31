import AppKit

/// Each projection owns its undo history. Refreshing the hidden source view must
/// never erase rich-editor undo through a shared window undo manager.
@MainActor class NativeDocumentTextView: NSTextView {
    private let documentUndo = UndoManager()
    override var undoManager: UndoManager? { documentUndo }
    override var acceptsFirstResponder: Bool { isEditable && super.acceptsFirstResponder }
}
