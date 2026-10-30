import AppKit
import SwiftUI

public struct MarkdownSourceEditor: NSViewRepresentable {
    public var source: String
    public var identity: UUID?
    public var onChange: (String) -> Void
    public var commands: MarkdownTextCommands?
    public var pointSize = 18.6666667
    public var fontName = "System"
    public var lightPaper = false
    public init(source: String, identity: UUID?, onChange: @escaping (String) -> Void) {
        self.source = source; self.identity = identity; self.onChange = onChange
    }
    public final class Coordinator: NSObject, NSTextViewDelegate {
        var onChange: (String) -> Void
        var identity: UUID?
        weak var commands: MarkdownTextCommands?
        init(onChange: @escaping (String) -> Void, identity: UUID?) { self.onChange = onChange; self.identity = identity }
        public func textDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSTextView else { return }
            onChange(view.string)
        }
        public func textViewDidChangeSelection(_ notification: Notification) { commands?.selectionRevision += 1 }
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
        coordinator.commands = commands
        view.setAccessibilityLabel("Markdown source")
        view.usesFindBar = true; view.isIncrementalSearchingEnabled = true
        commands?.target = view
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
        context.coordinator.commands = commands
        commands?.target = view
        view.isEditable = context.environment.isEnabled
        view.font = NSFont(name: fontName, size: pointSize) ?? .monospacedSystemFont(ofSize: pointSize, weight: .regular)
        view.textColor = lightPaper ? .black : .textColor
        view.backgroundColor = lightPaper ? .white : .textBackgroundColor
        view.insertionPointColor = lightPaper ? .black : .textColor
        if context.coordinator.identity != identity { view.undoManager?.removeAllActions(); context.coordinator.identity = identity }
        if view.string != source { view.undoManager?.removeAllActions(); view.string = source }
    }
}
