import AppKit
import Combine

/// Shared native-menu/ribbon commands and transient view state; never notebook/account access.
@MainActor public final class EditorCommands: NSObject, ObservableObject, NSMenuItemValidation {
    public let session: NotebookSession
    public let formatting = EditorFormatting()
    @Published public var tab = "Home"
    @Published public var ribbonCollapsed = false
    @Published public var navigationHidden = false
    @Published public var hidePageTitle = false
    @Published public var lightCanvas = false
    @Published public var hideAuthors = false
    @Published public var zoom = 1.0
    @Published public var navigationAdjustment = 0.0
    @Published public var paperStyle = "None"
    @Published public var searching = false
    @Published public var search = ""
    @Published public var searchScope = "section"
    @Published public var pageSort = "Original Order"
    public var newWindow: (() -> Void)?
    public var viewportWidth = 760.0
    private var copiedFormat: [NSAttributedString.Key: Any]?
    public init(session: NotebookSession) { self.session = session }

    public static let nativeSelectors: [String: String] = [
        "Cut": "cut:", "Copy": "copy:", "Paste": "paste:", "Paste and Match Formatting": "pasteAsPlainText:", "Paste and Keep Text Only": "pasteAsPlainText:", "Delete": "delete:", "Select All": "selectAll:", "Bold": "toggleBoldface:", "Italic": "toggleItalics:", "Underline": "underline:", "Align to Left": "alignLeft:", "Centre": "alignCenter:", "Align to Right": "alignRight:", "Spelling": "showGuessPanel:", "Look Up": "quickLookPreviewItems:"
    ]
    private var viewCommands: Set<String> { Set(["Ribbon", "Hide Section and Page Lists", "Switch Background", "Hide Page Title", "Hide Authors", "Zoom In", "Zoom Out", "Reset Zoom", "Zoom to Page Width", "Page Width", "Increase Navigation Pane Width", "Decrease Navigation Pane Width", "New Page", "New Section", "Save", "Search This Page", "Search This Section", "Search This Notebook", "Search All Notebooks", "Text Mode", "Window Centre"] + InterfaceCatalog.paperStyles) }
    public func canPerform(_ title: String) -> Bool {
        if title == "Undo" { return session.undoManager.canUndo }
        if title == "Redo" { return session.undoManager.canRedo }
        if title == "New Window" { return newWindow != nil }
        if title == "New Page" { return session.selectedSection != nil }
        if viewCommands.contains(title) { return session.notebook != nil }
        if title == "Paste Format" { return formatting.available && copiedFormat != nil }
        if let selector = Self.nativeSelectors[title] { return formatting.target?.responds(to: NSSelectorFromString(selector)) == true }
        return formatting.available && (Self.nativeSelectors[title] != nil || InterfaceCatalog.styles.contains(title) || ["Strikethrough", "Highlight", "Subscript", "Superscript", "Copy Format", "Bulletpoints", "Numbering", "Increase Indent", "Decrease Indent", "Clear Formatting", "Clear All Formatting", "Date", "Date & Time", "Table", "To Do", "Important", "Question", "Remember for later", "Definition", "Love it", "Looks good", "Critical", "Remove Tag"].contains(title))
    }
    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool { canPerform(menuItem.representedObject as? String ?? menuItem.title) }
    @objc public func menuAction(_ sender: NSMenuItem) { perform(sender.representedObject as? String ?? sender.title) }
    public func perform(_ title: String) {
        guard canPerform(title) else { return }
        if let selector = Self.nativeSelectors[title] { formatting.perform(selector); return }
        switch title {
        case "Undo": session.undoManager.undo()
        case "Redo": session.undoManager.redo()
        case "Save": session.saveNow()
        case "New Page": session.addPage()
        case "New Section": session.addSection()
        case "New Window": newWindow?()
        case "Ribbon": ribbonCollapsed.toggle()
        case "Hide Section and Page Lists": navigationHidden.toggle()
        case "Switch Background": lightCanvas.toggle()
        case "Hide Page Title": hidePageTitle.toggle()
        case "Hide Authors": hideAuthors.toggle()
        case "Zoom In": zoom = min(2, zoom + 0.1)
        case "Zoom Out": zoom = max(0.5, zoom - 0.1)
        case "Reset Zoom": zoom = 1
        case "Zoom to Page Width", "Page Width":
            let width = max(760, (session.selectedPage?.blocks.map { $0.x + $0.width }.max() ?? 0) + 48)
            zoom = min(2, max(0.25, viewportWidth / width))
        case "Increase Navigation Pane Width": navigationAdjustment = min(120, navigationAdjustment + 20)
        case "Decrease Navigation Pane Width": navigationAdjustment = max(-80, navigationAdjustment - 20)
        case "Search This Page", "Search This Section", "Search This Notebook", "Search All Notebooks": searching = true; searchScope = title == "Search This Page" ? "page" : title == "Search This Section" ? "section" : "notebook"
        case "Window Centre": NSApp.keyWindow?.center()
        case "Clear Formatting", "Clear All Formatting": formatting.target?.formatSelection(action: "Clear Formatting") { attributes in
            let paragraph = attributes[.paragraphStyle] as? NSParagraphStyle
            let link = attributes[.link]
            attributes = [.font: EditorTheme.bodyFont, .foregroundColor: EditorTheme.foreground]
            // Tables, lists and link destinations are document structure, not character styling.
            if let paragraph { attributes[.paragraphStyle] = paragraph }
            if let link { attributes[.link] = link }
        }
        case "Strikethrough": toggle(.strikethroughStyle)
        case "Highlight": formatting.attribute(.backgroundColor, value: NSColor(srgbRed: 0.3, green: 0.3, blue: 0, alpha: 1), action: title)
        case "Subscript": formatting.attribute(.baselineOffset, value: -4, action: title)
        case "Superscript": formatting.attribute(.baselineOffset, value: 6, action: title)
        case "Copy Format": copiedFormat = attributes().filter { [.font, .foregroundColor, .backgroundColor, .underlineStyle, .strikethroughStyle, .baselineOffset, .kern, .ligature].contains($0.key) }
        case "Paste Format": if let copiedFormat { formatting.target?.formatSelection(action: title) { $0.merge(copiedFormat) { _, new in new } } }
        case "Bulletpoints": formatting.list(numbered: false)
        case "Numbering": formatting.list(numbered: true)
        case "Increase Indent", "Decrease Indent":
            formatting.target?.formatSelection(action: title, paragraphs: true) { attributes in
                let style = (attributes[.paragraphStyle] as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
                style.headIndent = max(0, style.headIndent + (title == "Increase Indent" ? 24 : -24)); style.firstLineHeadIndent = style.headIndent
                attributes[.paragraphStyle] = style
            }
        case "Date", "Date & Time": formatting.target?.insertText(Date().formatted(date: .abbreviated, time: title == "Date" ? .omitted : .shortened), replacementRange: formatting.target!.selectedRange())
        case "Table": formatting.table()
        case "Text Mode": break // Already the native editor's mode.
        default:
            if InterfaceCatalog.paperStyles.contains(title) { paperStyle = title }
            else if title.hasPrefix("Heading "), let level = Int(title.suffix(1)) { formatting.heading(level) }
            else if InterfaceCatalog.styles.contains(title) { applyStyle(title) }
            else if InterfaceCatalog.tags.contains(title) || title == "Remove Tag" { tag(title) }
        }
    }
    private func attributes() -> [NSAttributedString.Key: Any] {
        guard let view = formatting.target else { return [:] }
        return view.selectedRange().length > 0 && view.selectedRange().location < view.attributedString().length ? view.attributedString().attributes(at: view.selectedRange().location, effectiveRange: nil) : view.typingAttributes
    }
    private func toggle(_ key: NSAttributedString.Key) { formatting.attribute(key, value: (attributes()[key] as? Int ?? 0) == 0 ? 1 : 0, action: "Strikethrough") }
    private func applyStyle(_ title: String) {
        formatting.target?.formatSelection(action: title, paragraphs: true) { attributes in
            attributes[.font] = title == "Code" ? NSFont.monospacedSystemFont(ofSize: 17, weight: .regular) : title == "Page Title" ? NSFont.systemFont(ofSize: 26) : EditorTheme.bodyFont
            attributes[.foregroundColor] = EditorTheme.foreground
            let style = NSMutableParagraphStyle(); style.headIndent = title == "Quote" || title == "Citation" ? 24 : 0
            style.paragraphSpacingBefore = title == "Quote" ? 8 : 0; attributes[.paragraphStyle] = style
        }
    }
    private func tag(_ title: String) {
        // A local plain-text tag marker; not Microsoft's cloud tag identity.
        guard let view = formatting.target else { return }
        let range = (view.string as NSString).paragraphRange(for: view.selectedRange())
        let markers = ["To Do": "☐", "Important": "★", "Question": "?", "Remember for later": "↗", "Definition": "≡", "Love it": "♥", "Looks good": "✓", "Critical": "!"]
        if let marker = markers[title] { view.insertText(marker + " ", replacementRange: NSRange(location: range.location, length: 0)) }
        else if range.length >= 2 { let prefix = (view.string as NSString).substring(with: NSRange(location: range.location, length: 2)); if markers.values.contains(where: { prefix == $0 + " " }) { view.insertText("", replacementRange: NSRange(location: range.location, length: 2)) } }
    }
}
