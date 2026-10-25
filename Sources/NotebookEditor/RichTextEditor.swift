import AppKit
import SwiftUI

public struct RichTextEditor: NSViewRepresentable {
    public var text: String
    public var richText: Data?
    public let undoManager: UndoManager
    public let onChange: (String, Data) -> Void
    public let onError: (Error) -> Void

    public init(text: String, richText: Data?, undoManager: UndoManager, onChange: @escaping (String, Data) -> Void, onError: @escaping (Error) -> Void) {
        self.text = text; self.richText = richText; self.undoManager = undoManager; self.onChange = onChange; self.onError = onError
    }

    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    public func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSScrollView()
        scroll.borderType = .noBorder; scroll.hasVerticalScroller = true; scroll.autohidesScrollers = true
        scroll.drawsBackground = true; scroll.backgroundColor = .white
        scroll.documentView = makeTextView(coordinator: context.coordinator)
        return scroll
    }

    public func makeTextView(coordinator: Coordinator) -> NSTextView {
        let view = NotebookTextView(frame: .zero)
        view.onFormattingError = onError
        view.isRichText = true; view.isEditable = true; view.isSelectable = true; view.allowsUndo = true
        view.isAutomaticQuoteSubstitutionEnabled = true; view.isAutomaticSpellingCorrectionEnabled = true
        view.isVerticallyResizable = true; view.isHorizontallyResizable = false
        view.autoresizingMask = [.width]
        view.textContainer?.widthTracksTextView = true
        view.textContainerInset = NSSize(width: 12, height: 12)
        view.minSize = .zero; view.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        view.font = .systemFont(ofSize: 18); view.textColor = NSColor(red: 0.094, green: 0.196, blue: 0.31, alpha: 1)
        view.backgroundColor = .white; view.setAccessibilityLabel("Note text")
        view.delegate = coordinator
        coordinator.install(in: view, from: self)
        return view
    }

    public func updateNSView(_ scroll: NSScrollView, context: Context) {
        context.coordinator.parent = self
        guard let view = scroll.documentView as? NSTextView, !view.hasMarkedText() else { return }
        if context.coordinator.lastText != text || context.coordinator.lastRichText != richText {
            context.coordinator.install(in: view, from: self)
        }
    }

    @MainActor public final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var lastText: String?
        var lastRichText: Data?
        init(_ parent: RichTextEditor) { self.parent = parent }

        func install(in view: NSTextView, from value: RichTextEditor) {
            do {
                if let data = value.richText { view.textStorage?.setAttributedString(try RichTextCodec.decode(data)) }
                else { view.textStorage?.setAttributedString(NSAttributedString(string: value.text, attributes: [.font: NSFont.systemFont(ofSize: 18), .foregroundColor: NSColor.textColor])) }
                lastText = value.text; lastRichText = value.richText
            } catch { value.onError(error) }
        }

        public func textDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSTextView else { return }
            do {
                let data = try RichTextCodec.encode(view.attributedString())
                lastText = view.string; lastRichText = data
                parent.onChange(view.string, data)
            } catch { parent.onError(error) }
        }

        public func undoManager(for view: NSTextView) -> UndoManager? { parent.undoManager }
    }
}
