import AppKit
import Combine

/// Keeps the text selection available while a ribbon control owns keyboard focus.
@MainActor public final class EditorFormatting: ObservableObject {
    public init() {}
    public weak var target: NotebookTextView?
    @Published public private(set) var fontName = "Calibri"
    @Published public private(set) var fontSize = 18.0
    @Published public private(set) var bold = false
    @Published public private(set) var italic = false
    @Published public private(set) var underline = false
    @Published public private(set) var available = false

    public func attach(_ view: NotebookTextView) { target = view; refresh(view) }
    public func clear() { target = nil; available = false }
    public func refresh(_ view: NotebookTextView) {
        guard target === view else { return }
        available = true
        let attributes = view.selectedRange().length > 0 && view.selectedRange().location < view.attributedString().length
            ? view.attributedString().attributes(at: view.selectedRange().location, effectiveRange: nil) : view.typingAttributes
        let font = attributes[.font] as? NSFont ?? EditorTheme.bodyFont
        fontName = font.familyName ?? "System"; fontSize = font.pointSize
        bold = NSFontManager.shared.traits(of: font).contains(.boldFontMask)
        italic = NSFontManager.shared.traits(of: font).contains(.italicFontMask)
        underline = (attributes[.underlineStyle] as? Int ?? 0) != 0
    }
    public func perform(_ action: String) {
        guard let target else { return }
        target.window?.makeFirstResponder(target)
        _ = target.tryToPerform(NSSelectorFromString(action), with: nil)
        refresh(target)
    }
    public func font(name: String? = nil, size: Double? = nil) {
        guard let target else { return }
        let family = name ?? fontName
        let points = min(96, max(8, size ?? fontSize))
        target.formatSelection(action: "Font") { attributes in
            let current = attributes[.font] as? NSFont ?? EditorTheme.bodyFont
            let base = NSFont(name: family, size: points) ?? NSFont.systemFont(ofSize: points)
            attributes[.font] = NSFontManager.shared.convert(base, toHaveTrait: NSFontManager.shared.traits(of: current))
        }
        refresh(target)
    }
    public func attribute(_ key: NSAttributedString.Key, value: Any, action: String) {
        guard let target else { return }
        target.formatSelection(action: action) { $0[key] = value }
        refresh(target)
    }
    public func heading(_ level: Int) {
        guard let target else { return }
        target.formatSelection(action: "Heading", paragraphs: true) { attributes in
            attributes[.font] = NSFont.systemFont(ofSize: level == 1 ? 20 : 18, weight: .medium)
            attributes[.foregroundColor] = EditorTheme.link
            let style = (attributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
            style.paragraphSpacingBefore = 10; style.paragraphSpacing = 4
            attributes[.paragraphStyle] = style
        }
        refresh(target)
    }
    public func list(numbered: Bool) {
        target?.toggleList(numbered: numbered)
    }
    public func link(_ value: String) {
        guard let url = URL(string: value), ["https", "http", "mailto", "onenote"].contains(url.scheme?.lowercased() ?? "") else { return }
        attribute(.link, value: url, action: "Link")
    }
    public func table() { target?.insertTable() }
}

@MainActor public enum EditorTheme {
    public static let background = NSColor(srgbRed: 32/255, green: 32/255, blue: 32/255, alpha: 1)
    public static let foreground = NSColor(srgbRed: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    public static let link = NSColor(srgbRed: 100/255, green: 174/255, blue: 229/255, alpha: 1)
    public static var bodyFont: NSFont { NSFont(name: "Calibri", size: 18) ?? .systemFont(ofSize: 18) }
}
