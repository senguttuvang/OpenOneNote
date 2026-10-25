import AppKit

/// Native text editing plus explicit format actions, shared by menu and toolbar.
@MainActor public final class NotebookTextView: NSTextView {
    public weak var formatting: EditorFormatting?
    public override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result { formatting?.attach(self) }
        return result
    }
    public var onFormattingError: ((Error) -> Void)?
    @objc public func toggleBoldface(_ sender: Any?) { toggle(.boldFontMask) }
    @objc public func toggleItalics(_ sender: Any?) { toggle(.italicFontMask) }

    private func toggle(_ trait: NSFontTraitMask) {
        let range = selectedRange()
        let manager = NSFontManager.shared
        let current = range.length > 0 && range.location < attributedString().length
            ? attributedString().attribute(.font, at: range.location, effectiveRange: nil) as? NSFont
            : typingAttributes[.font] as? NSFont
        let font = current ?? .systemFont(ofSize: 18)
        let removing = manager.traits(of: font).contains(trait)
        func convert(_ value: NSFont) -> NSFont {
            removing ? manager.convert(value, toNotHaveTrait: trait) : manager.convert(value, toHaveTrait: trait)
        }
        if range.length == 0 {
            var attributes = typingAttributes; attributes[.font] = convert(font); typingAttributes = attributes
            return
        }
        let updated = NSMutableAttributedString(attributedString: attributedString())
        updated.enumerateAttribute(.font, in: range) { value, span, _ in
            updated.addAttribute(.font, value: convert(value as? NSFont ?? font), range: span)
        }
        replaceRichText(updated, selection: range)
        undoManager?.setActionName(trait == .boldFontMask ? "Bold" : "Italic")
    }

    public func formatSelection(action: String, paragraphs: Bool = false, change: (inout [NSAttributedString.Key: Any]) -> Void) {
        var range = selectedRange()
        if paragraphs { range = (string as NSString).paragraphRange(for: range) }
        if range.length == 0 {
            var attributes = typingAttributes; change(&attributes); typingAttributes = attributes
        } else {
            let updated = NSMutableAttributedString(attributedString: attributedString())
            attributedString().enumerateAttributes(in: range) { attributes, span, _ in
                var next = attributes; change(&next); updated.setAttributes(next, range: span)
            }
            replaceRichText(updated, selection: selectedRange())
            undoManager?.setActionName(action)
        }
        formatting?.refresh(self)
    }

    public func insertTable() {
        let table = NSTextTable(); table.numberOfColumns = 2
        let content = NSMutableAttributedString()
        for row in 0..<3 {
            for column in 0..<2 {
                let cell = NSTextTableBlock(table: table, startingRow: row, rowSpan: 1, startingColumn: column, columnSpan: 1)
                cell.setBorderColor(.gray); cell.setWidth(0.5, type: .absoluteValueType, for: .border)
                cell.setWidth(5, type: .absoluteValueType, for: .padding)
                cell.setContentWidth(220, type: .absoluteValueType)
                let style = NSMutableParagraphStyle(); style.textBlocks = [cell]
                content.append(NSAttributedString(string: row == 0 ? "Column \(column + 1)\n" : "Cell\n", attributes: [
                    .font: EditorTheme.bodyFont, .foregroundColor: EditorTheme.foreground, .paragraphStyle: style
                ]))
            }
        }
        let updated = NSMutableAttributedString(attributedString: attributedString())
        let range = selectedRange(); updated.replaceCharacters(in: range, with: content)
        replaceRichText(updated, selection: NSRange(location: range.location, length: content.length))
        undoManager?.setActionName("Insert Table")
    }

    public func toggleList(numbered: Bool) {
        let list = NSTextList(markerFormat: numbered ? .decimal : .disc, options: 0)
        formatSelection(action: "List", paragraphs: true) { attributes in
            let style = (attributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            style.textLists = style.textLists.first?.markerFormat == list.markerFormat ? [] : [list]
            style.headIndent = style.textLists.isEmpty ? 0 : 24
            style.firstLineHeadIndent = 0
            attributes[.paragraphStyle] = style
        }
    }

    private func replaceRichText(_ value: NSAttributedString, selection: NSRange) {
        do {
            let previous = try RichTextCodec.encode(attributedString())
            let previousSelection = selectedRange()
            undoManager?.registerUndo(withTarget: self) { target in
                MainActor.assumeIsolated {
                    do { target.replaceRichText(try RichTextCodec.decode(previous), selection: previousSelection) }
                    catch { target.report(error) }
                }
            }
            textStorage?.setAttributedString(value)
            setSelectedRange(selection)
            didChangeText()
            formatting?.refresh(self)
        } catch { report(error) }
    }

    private func report(_ error: Error) {
        if let onFormattingError { onFormattingError(error) } else { presentError(error) }
    }
}
