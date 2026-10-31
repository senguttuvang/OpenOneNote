import AppKit
import Observation

/// Selection-aware Markdown operations on the real AppKit editor; no RTF/source conversion.
@MainActor @Observable public final class MarkdownTextCommands {
    public weak var target: NSTextView?
    public var fontSize = 18.6666667
    public var fontName = "Menlo"
    public var selectionRevision = 0
    public init() {}
    public func insert(_ text: String, action: String) {
        guard let view = target else { return }
        view.isEditable = true
        view.window?.makeFirstResponder(view)
        view.breakUndoCoalescing()
        view.undoManager?.beginUndoGrouping()
        view.insertText(text, replacementRange: view.selectedRange())
        view.undoManager?.endUndoGrouping(); view.undoManager?.setActionName(action)
        view.breakUndoCoalescing()
    }
    public func wrap(_ marker: String, placeholder: String = "text") {
        guard let view = target else { return }
        let range = view.selectedRange(); let source = view.string as NSString
        let count = marker.utf16.count
        if range.location >= count, NSMaxRange(range) + count <= source.length,
           source.substring(with: NSRange(location: range.location - count, length: count)) == marker,
           source.substring(with: NSRange(location: NSMaxRange(range), length: count)) == marker {
            view.setSelectedRange(NSRange(location: range.location - count, length: range.length + count * 2))
            insert(source.substring(with: range), action: "Remove formatting")
            view.setSelectedRange(NSRange(location: range.location - count, length: range.length))
        } else {
            let selected = range.length == 0 ? placeholder : source.substring(with: range)
            insert(marker + selected + marker, action: "Markdown formatting")
            view.setSelectedRange(NSRange(location: range.location + count, length: selected.utf16.count))
        }
    }
    public func paragraphs(prefix: String, removeHeading: Bool = false) {
        guard let view = target else { return }
        let range = (view.string as NSString).paragraphRange(for: view.selectedRange())
        let original = (view.string as NSString).substring(with: range)
        var lines = original.components(separatedBy: "\n")
        let trailing = lines.last == ""; if trailing { lines.removeLast() }
        let edited = lines.map { line -> String in
            var text = line
            if removeHeading {
                let hashes = text.prefix(while: { $0 == "#" }).count
                if (1...6).contains(hashes), text.dropFirst(hashes).first == " " { text = String(text.dropFirst(hashes + 1)) }
            }
            return prefix + text
        }.joined(separator: "\n") + (trailing ? "\n" : "")
        view.setSelectedRange(range); insert(edited, action: "Paragraph format")
        view.setSelectedRange(NSRange(location: range.location, length: edited.utf16.count))
    }
    public func perform(_ title: String) {
        if let rich = target as? NativeRichTextView {
            if title == "Table" { insertTable(rows: 3, columns: 2) }
            else { rich.format(title) }
            return
        }
        switch title {
        case "Bold": wrap("**")
        case "Italic": wrap("*")
        case "Strikethrough": wrap("~~")
        case "Code": wrap("`")
        case "Quote", "Citation": paragraphs(prefix: "> ")
        case "Bulletpoints": paragraphs(prefix: "- ")
        case "Numbering": paragraphs(prefix: "1. ")
        case "To Do": paragraphs(prefix: "- [ ] ")
        case "Important": paragraphs(prefix: "★ ")
        case "Normal": paragraphs(prefix: "", removeHeading: true)
        case "Increase Indent": paragraphs(prefix: "    ")
        case "Table": insert("\n\n| Column 1 | Column 2 |\n| --- | --- |\n| Cell | Cell |\n", action: "Insert Table")
        default:
            if title.hasPrefix("Heading "), let level = Int(title.suffix(1)), (1...6).contains(level) { paragraphs(prefix: String(repeating: "#", count: level) + " ", removeHeading: true) }
        }
    }
    public func native(_ selector: String) {
        guard let view = target else { return }
        view.window?.makeFirstResponder(view)
        _ = view.tryToPerform(NSSelectorFromString(selector), with: nil)
    }
    public func insertTable(rows: Int, columns: Int) {
        guard (1...8).contains(rows), (1...10).contains(columns) else { return }
        let header = "| " + (1...columns).map { "Column \($0)" }.joined(separator: " | ") + " |\n"
        let divider = "| " + Array(repeating: "---", count: columns).joined(separator: " | ") + " |\n"
        let row = "| " + Array(repeating: "Cell", count: columns).joined(separator: " | ") + " |\n"
        let source = header + divider + String(repeating: row, count: max(0, rows - 1))
        if let view = target as? NativeRichTextView, let table = try? NativeRichTextCodec.render(source) {
            view.window?.makeFirstResponder(view)
            view.breakUndoCoalescing()
            let content = NSMutableAttributedString()
            if view.selectedRange().location > 0, (view.string as NSString).character(at: view.selectedRange().location - 1) != 10 {
                content.append(NSAttributedString(string: "\n", attributes: NativeRichTextCodec.body))
            }
            content.append(table)
            content.append(NSAttributedString(string: "\n", attributes: NativeRichTextCodec.body))
            view.insertText(content, replacementRange: view.selectedRange())
            view.undoManager?.setActionName("Insert Table")
        } else { insert("\n\n" + source, action: "Insert Table") }
    }
    public func find(_ action: NSTextFinder.Action) {
        guard let view = target else { return }
        view.window?.makeFirstResponder(view)
        let sender = NSMenuItem(); sender.tag = action.rawValue
        view.performFindPanelAction(sender)
    }
}
