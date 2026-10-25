import AppKit

/// Native text editing plus explicit format actions, shared by menu and toolbar.
@MainActor public final class NotebookTextView: NSTextView {
    public var onFormattingError: ((Error) -> Void)?
    @objc public func toggleBoldface(_ sender: Any?) { toggle(.boldFontMask) }
    @objc public func toggleItalics(_ sender: Any?) { toggle(.italicFontMask) }

    private func toggle(_ trait: NSFontTraitMask) {
        let range = selectedRange()
        let manager = NSFontManager.shared
        let current = range.location < attributedString().length
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
        } catch { report(error) }
    }

    private func report(_ error: Error) {
        if let onFormattingError { onFormattingError(error) } else { presentError(error) }
    }
}
