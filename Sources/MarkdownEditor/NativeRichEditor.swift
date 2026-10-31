import AppKit
import SwiftUI

@MainActor public struct NativeRichEditor: NSViewRepresentable {
    public var source: String
    public var identity: UUID?
    public var commands: MarkdownTextCommands
    public var onChange: (String) -> Void
    public var zoom = 1.0
    public var lightPaper = false
    public var onRejectedEdit: ((String) -> Void)?
    public init(source: String, identity: UUID?, commands: MarkdownTextCommands, onChange: @escaping (String) -> Void) {
        self.source = source; self.identity = identity; self.commands = commands; self.onChange = onChange
    }
    public final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NativeRichEditor
        var displayedSource: String
        var identity: UUID?
        init(_ parent: NativeRichEditor) { self.parent = parent; displayedSource = parent.source; identity = parent.identity }
        public func textDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSTextView else { return }
            displayedSource = NativeRichTextCodec.markdown(view.attributedString())
            parent.onChange(displayedSource)
        }
        public func textViewDidChangeSelection(_ notification: Notification) {
            parent.commands.selectionRevision += 1
            if let view = notification.object as? NSTextView, view.selectedRange().location == view.attributedString().length,
               view.typingAttributes[NativeRichTextCodec.raw] != nil { view.typingAttributes = NativeRichTextCodec.body }
        }
        public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            func reject() -> Bool {
                parent.onRejectedEdit?("This structure is preserved. Use the Markdown ribbon icon to edit it.")
                return false
            }
            var protected = false
            let text = textView.attributedString()
            if affectedCharRange.length > 0, NSMaxRange(affectedCharRange) < text.length,
               text.attribute(NativeRichTextCodec.raw, at: NSMaxRange(affectedCharRange), effectiveRange: nil) != nil { return reject() }
            if affectedCharRange.length > 0 {
                text.enumerateAttribute(NativeRichTextCodec.raw, in: affectedCharRange) { value, _, _ in if value != nil { protected = true } }
                text.enumerateAttribute(NativeRichTextCodec.listMarker, in: affectedCharRange) { value, _, _ in if value as? Bool == true { protected = true } }
                text.enumerateAttribute(.paragraphStyle, in: affectedCharRange) { value, range, _ in
                    if (value as? NSParagraphStyle)?.textBlocks.first is NSTextTableBlock,
                       (text.string as NSString).substring(with: range).contains("\n") { protected = true }
                }
            } else if affectedCharRange.location < text.length {
                protected = text.attribute(NativeRichTextCodec.raw, at: affectedCharRange.location, effectiveRange: nil) != nil
                    || text.attribute(NativeRichTextCodec.listMarker, at: affectedCharRange.location, effectiveRange: nil) as? Bool == true
            }
            if affectedCharRange.location < text.length,
               (text.attribute(.paragraphStyle, at: affectedCharRange.location, effectiveRange: nil) as? NSParagraphStyle)?.textBlocks.first is NSTextTableBlock {
                // Structural table commands need a separate, validated model operation.
                if replacementString?.contains(where: \.isNewline) == true { return reject() }
                if (text.string as NSString).substring(with: affectedCharRange).contains("\n") { return reject() }
            }
            return protected ? reject() : true
        }
    }
    public func makeCoordinator() -> Coordinator { Coordinator(self) }
    public func makeTextView(coordinator: Coordinator) -> NSTextView {
        let view = NativeRichTextView(); view.isRichText = true; view.importsGraphics = false; view.allowsUndo = true
        view.isVerticallyResizable = true; view.isHorizontallyResizable = false
        view.autoresizingMask = [.width]; view.textContainer?.widthTracksTextView = true
        view.textContainerInset = NSSize(width: 12, height: 12)
        view.drawsBackground = false; view.usesFindBar = true
        view.textStorage?.setAttributedString((try? NativeRichTextCodec.render(source)) ?? NSAttributedString(string: source, attributes: NativeRichTextCodec.body))
        view.typingAttributes = NativeRichTextCodec.body
        view.delegate = coordinator; view.setAccessibilityLabel("Page content")
        commands.target = view
        return view
    }
    public func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSScrollView(); scroll.hasVerticalScroller = true; scroll.drawsBackground = false
        scroll.documentView = makeTextView(coordinator: context.coordinator); return scroll
    }
    public func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let view = scroll.documentView as? NSTextView else { return }
        let coordinator = context.coordinator
        coordinator.parent = self
        scroll.appearance = NSAppearance(named: lightPaper || context.environment.colorScheme == .light ? .aqua : .darkAqua)
        scroll.allowsMagnification = true; scroll.minMagnification = 0.5; scroll.maxMagnification = 2
        if abs(scroll.magnification - zoom) > 0.001 { scroll.magnification = zoom }
        view.isEditable = context.environment.isEnabled
        if coordinator.identity != identity || coordinator.displayedSource != source {
            view.undoManager?.removeAllActions()
            view.textStorage?.setAttributedString((try? NativeRichTextCodec.render(source)) ?? NSAttributedString(string: source, attributes: NativeRichTextCodec.body))
            view.typingAttributes = NativeRichTextCodec.body
            coordinator.identity = identity; coordinator.displayedSource = source
        }
    }
}
