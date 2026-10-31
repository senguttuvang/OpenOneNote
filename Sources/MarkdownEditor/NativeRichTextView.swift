import AppKit

@MainActor final class NativeRichTextView: NativeDocumentTextView {
    func format(_ title: String) {
        var range = selectedRange()
        let list = title == "Bulletpoints" || title == "Numbering"
        let paragraph = title == "Normal" || title.hasPrefix("Heading ") || list
        if paragraph { range = (string as NSString).paragraphRange(for: range) }
        var protected = false
        attributedString().enumerateAttribute(NativeRichTextCodec.raw, in: range) { value, _, _ in if value != nil { protected = true } }
        guard !protected else { return }
        let updated = NSMutableAttributedString(attributedString: attributedString())
        func change(_ attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
            var next = attributes
            let font = attributes[.font] as? NSFont ?? NSFont.systemFont(ofSize: 18)
            if title == "Bold" || title == "Italic" {
                let trait: NSFontTraitMask = title == "Bold" ? .boldFontMask : .italicFontMask
                let manager = NSFontManager.shared
                next[.font] = manager.traits(of: font).contains(trait) ? manager.convert(font, toNotHaveTrait: trait) : manager.convert(font, toHaveTrait: trait)
                if title == "Bold" { next[NativeRichTextCodec.bold] = !manager.traits(of: font).contains(trait) }
            } else if title == "Strikethrough" {
                next[.strikethroughStyle] = (attributes[.strikethroughStyle] as? Int ?? 0) == 0 ? 1 : 0
            } else if title == "Code" {
                let enabled = attributes[NativeRichTextCodec.code] as? Bool != true
                next[NativeRichTextCodec.code] = enabled
                next[.font] = enabled ? NSFont.monospacedSystemFont(ofSize: 16, weight: .regular) : NativeRichTextCodec.body[.font]
            } else if paragraph {
                let level = Int(title.suffix(1))
                next[NativeRichTextCodec.block] = level.map { "h\($0)" } ?? "p"
                next[.font] = level.map { NSFont.systemFont(ofSize: CGFloat(30 - $0 * 2), weight: .semibold) } ?? NativeRichTextCodec.body[.font]
                next[.foregroundColor] = level == nil ? NSColor.textColor : NSColor.systemBlue
                let style = (attributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
                if list {
                    next[NativeRichTextCodec.listPrefix] = title == "Numbering" ? "1. " : "- "
                    style.textLists = [NSTextList(markerFormat: title == "Numbering" ? .decimal : .disc, options: 0)]
                    style.headIndent = 24; style.firstLineHeadIndent = 8
                } else {
                    next.removeValue(forKey: NativeRichTextCodec.listPrefix)
                    style.textLists = []; style.headIndent = 0; style.firstLineHeadIndent = 0
                }
                next[.paragraphStyle] = style
            }
            return next
        }
        if range.length == 0 {
            let attributes = change(typingAttributes)
            if list {
                var marker = attributes; marker[NativeRichTextCodec.listMarker] = true
                insertText(NSAttributedString(string: title == "Numbering" ? "1.\t" : "•\t", attributes: marker), replacementRange: selectedRange())
            }
            typingAttributes = attributes; return
        }
        var spans = [range]
        if !paragraph {
            spans = []; let text = string as NSString; var position = range.location
            func whitespace(_ index: Int) -> Bool { UnicodeScalar(text.character(at: index)).map(CharacterSet.whitespacesAndNewlines.contains) ?? false }
            while position < NSMaxRange(range) {
                let line = text.paragraphRange(for: NSRange(location: position, length: 0))
                var span = NSIntersectionRange(line, range)
                while span.length > 0 && whitespace(span.location) { span.location += 1; span.length -= 1 }
                while span.length > 0 && whitespace(NSMaxRange(span) - 1) { span.length -= 1 }
                if span.length > 0 { spans.append(span) }
                position = NSMaxRange(line)
            }
        }
        for span in spans {
            attributedString().enumerateAttributes(in: span) { attributes, range, _ in updated.setAttributes(change(attributes), range: range) }
        }
        if paragraph {
            var markers: [NSRange] = []
            updated.enumerateAttribute(NativeRichTextCodec.listMarker, in: range) { value, span, _ in if value as? Bool == true { markers.append(span) } }
            for marker in markers.reversed() { updated.deleteCharacters(in: marker); range.length -= marker.length }
            if list {
                var positions: [Int] = []; var position = range.location
                while position < NSMaxRange(range) {
                    positions.append(position)
                    position = NSMaxRange((updated.string as NSString).paragraphRange(for: NSRange(location: position, length: 0)))
                }
                for (index, position) in positions.enumerated().reversed() {
                    var attributes = updated.attributes(at: position, effectiveRange: nil); attributes[NativeRichTextCodec.listMarker] = true
                    updated.insert(NSAttributedString(string: title == "Numbering" ? "\(index + 1).\t" : "•\t", attributes: attributes), at: position)
                }
            }
        }
        replace(updated, selection: selectedRange())
        undoManager?.setActionName(title)
    }
    override func insertNewline(_ sender: Any?) {
        if let prefix = typingAttributes[NativeRichTextCodec.listPrefix] as? String {
            let paragraph = (string as NSString).paragraphRange(for: selectedRange())
            let text = (string as NSString).substring(with: paragraph).trimmingCharacters(in: .whitespacesAndNewlines)
            if text == "•" || text == prefix.trimmingCharacters(in: .whitespaces) {
                format("Normal"); typingAttributes = NativeRichTextCodec.body; return
            }
            var attributes = typingAttributes; attributes.removeValue(forKey: NativeRichTextCodec.listMarker)
            let number = Int(prefix.split(separator: ".").first ?? "")
            let nextPrefix = number.map { "\($0 + 1). " } ?? "- "
            attributes[NativeRichTextCodec.listPrefix] = nextPrefix
            var marker = attributes; marker[NativeRichTextCodec.listMarker] = true
            let content = NSMutableAttributedString(string: "\n", attributes: attributes)
            content.append(NSAttributedString(string: number.map { "\($0 + 1).\t" } ?? "•\t", attributes: marker))
            insertText(content, replacementRange: selectedRange()); typingAttributes = attributes; return
        }
        let heading = (typingAttributes[NativeRichTextCodec.block] as? String)?.hasPrefix("h") == true
        super.insertNewline(sender)
        if heading { typingAttributes = NativeRichTextCodec.body }
    }
    private func replace(_ value: NSAttributedString, selection: NSRange) {
        let previous = NSAttributedString(attributedString: attributedString())
        let previousSelection = selectedRange()
        undoManager?.registerUndo(withTarget: self) { view in
            MainActor.assumeIsolated { view.replace(previous, selection: previousSelection) }
        }
        textStorage?.setAttributedString(value)
        let location = min(selection.location, value.length)
        setSelectedRange(NSRange(location: location, length: min(selection.length, value.length - location))); didChangeText()
    }
}
