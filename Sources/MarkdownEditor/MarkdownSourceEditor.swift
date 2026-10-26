import AppKit
import SwiftUI

public struct MarkdownSourceEditor: NSViewRepresentable {
    public var source: String
    public var identity: UUID?
    public var onChange: (String) -> Void
    public init(source: String, identity: UUID?, onChange: @escaping (String) -> Void) {
        self.source = source; self.identity = identity; self.onChange = onChange
    }
    public final class Coordinator: NSObject, NSTextViewDelegate {
        var onChange: (String) -> Void
        var identity: UUID?
        init(onChange: @escaping (String) -> Void, identity: UUID?) { self.onChange = onChange; self.identity = identity }
        public func textDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSTextView else { return }
            onChange(view.string)
        }
    }
    public func makeCoordinator() -> Coordinator { Coordinator(onChange: onChange, identity: identity) }
    public func makeTextView(coordinator: Coordinator) -> NSTextView {
        let view = NSTextView()
        view.isRichText = false; view.allowsUndo = true; view.isAutomaticQuoteSubstitutionEnabled = false
        view.isAutomaticDashSubstitutionEnabled = false; view.isAutomaticTextReplacementEnabled = false
        view.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
        view.textContainerInset = NSSize(width: 10, height: 12)
        view.isVerticallyResizable = true; view.isHorizontallyResizable = false
        view.autoresizingMask = [.width]; view.textContainer?.widthTracksTextView = true
        view.string = source; view.delegate = coordinator
        view.setAccessibilityLabel("Markdown source")
        return view
    }
    public func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSScrollView(); scroll.hasVerticalScroller = true; scroll.borderType = .noBorder
        scroll.documentView = makeTextView(coordinator: context.coordinator)
        return scroll
    }
    public func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let view = scroll.documentView as? NSTextView else { return }
        context.coordinator.onChange = onChange
        if context.coordinator.identity != identity { view.undoManager?.removeAllActions(); context.coordinator.identity = identity }
        if view.string != source { view.undoManager?.removeAllActions(); view.string = source }
    }
}
