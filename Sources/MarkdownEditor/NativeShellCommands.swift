import AppKit

extension NativeShellState {
    private var activeTextTarget: NSTextView? {
        if let field = window?.firstResponder as? NSTextView, field.isFieldEditor { return field }
        return editor.target
    }
    static let textActions = ["Cut": "cut:", "Copy": "copy:", "Paste": "paste:", "Keep Source Formatting": "paste:", "Match Formatting": "pasteAsPlainText:", "Keep Text Only": "pasteAsPlainText:", "Paste and Match Formatting": "pasteAsPlainText:", "Paste and Keep Text Only": "pasteAsPlainText:", "Delete": "delete:", "Select All": "selectAll:"]
    static let markdownActions = ["Bold", "Italic", "Strikethrough", "Code", "Quote", "Citation", "Bulletpoints", "Numbering", "To Do", "Important", "Normal", "Increase Indent", "Table"] + (1...6).map { "Heading \($0)" }
    public func canPerform(_ title: String) -> Bool {
        if ["About OpenOneNote", "Increase Navigation Pane Width", "Decrease Navigation Pane Width"].contains(title) { return true }
        if title == "Undo" { return !session.busy && activeTextTarget?.undoManager?.canUndo == true }
        if title == "Redo" { return !session.busy && activeTextTarget?.undoManager?.canRedo == true }
        if title == "New Window" { return newWindow != nil }
        if ["New Page", "New Section", "New Notebook…", "Open Notebook…", "Open local Markdown…", "Preferences…", "Microsoft account", "Ribbon", "Hide Section and Page Lists", "Switch Background", "Zoom In", "Zoom Out", "Reset Zoom", "Zoom to Page Width", "Search This Page", "Search This Section", "Search This Notebook", "Search All Notebooks", "Find Next", "Find Previous", "Find and Replace", "Save", "Write", "Split", "Read", "Markdown", "Close", "Minimise", "Zoom", "Enter Full Screen", "Bring All to Front"].contains(title) { return !session.busy }
        if title == "Sync This Page" || title == "Sync page" { return !session.busy && session.selected != nil && session.selected?.identity.root != "local" && session.graph != nil }
        if Self.markdownActions.contains(title), !markdownVisible {
            if activeTextTarget?.isFieldEditor == true { return false }
            if tableContext && (["Table", "Bulletpoints", "Numbering"].contains(title) || title.hasPrefix("Heading ")) { return false }
            return session.selectedID != nil && !session.busy && (["Bold", "Italic", "Strikethrough", "Code", "Normal", "Bulletpoints", "Numbering", "Table"].contains(title) || title.hasPrefix("Heading "))
        }
        if Self.textActions[title] != nil || Self.markdownActions.contains(title) || ["Date", "Date & Time", "File…", "Picture…", "Link…"].contains(title) { return session.selectedID != nil && !session.busy && (markdownVisible || !["Link…"].contains(title)) }
        return false
    }
    public func perform(_ title: String) {
        guard canPerform(title) else { return }
        if let selector = Self.textActions[title] {
            if let field = activeTextTarget, field.isFieldEditor {
                _ = field.tryToPerform(NSSelectorFromString(selector), with: nil); return
            }
            if title == "Copy", NSApp.sendAction(NSSelectorFromString(selector), to: nil, from: nil) { return }
            if title != "Copy" { mode = .write; editor.target?.isEditable = true }
            editor.native(selector); return
        }
        if Self.markdownActions.contains(title) { format(title); return }
        switch title {
        case "About OpenOneNote": NSApp.orderFrontStandardAboutPanel(nil)
        case "Increase Navigation Pane Width": sectionWidth = min(360, sectionWidth + 20); pageWidth = min(400, pageWidth + 20)
        case "Decrease Navigation Pane Width": sectionWidth = max(140, sectionWidth - 20); pageWidth = max(160, pageWidth - 20)
        case "Undo": activeTextTarget?.undoManager?.undo()
        case "Redo": activeTextTarget?.undoManager?.redo()
        case "New Page": createPage()
        case "New Section": createSection()
        case "New Notebook…": sheet = .newNotebook
        case "Open Notebook…": sheet = .notebooks
        case "Open local Markdown…": session.openLocal(); followSelection()
        case "Preferences…": sheet = .settings
        case "Microsoft account": sheet = .account
        case "Save": _ = session.save()
        case "Sync This Page", "Sync page": session.sync()
        case "Ribbon": ribbonCollapsed.toggle()
        case "Hide Section and Page Lists": navigationHidden.toggle()
        case "Switch Background": lightPaper.toggle()
        case "Zoom In": zoom = min(2, zoom + 0.1)
        case "Zoom Out": zoom = max(0.5, zoom - 0.1)
        case "Reset Zoom", "Zoom to Page Width": zoom = 1
        case "Markdown": markdownVisible.toggle(); mode = .write
        case "Write": mode = .write
        case "Split": markdownVisible = true; mode = .split
        case "Read": markdownVisible = true; mode = .read
        case "Search This Section": searchScope = .section; searching = true
        case "Search This Notebook": searchScope = .notebook; searching = true
        case "Search All Notebooks": searchScope = .all; searching = true
        case "Search This Page": mode = .write; editor.find(.showFindInterface)
        case "Find and Replace": mode = .write; editor.find(.showReplaceInterface)
        case "Find Next": mode = .write; editor.find(.nextMatch)
        case "Find Previous": mode = .write; editor.find(.previousMatch)
        case "Date", "Date & Time": insert(Date().formatted(date: .abbreviated, time: title == "Date" ? .omitted : .shortened), action: title)
        case "File…", "Picture…": session.attachFile()
        case "Link…": insert("[link text](https://example.com)", action: "Insert Link")
        case "Close": window?.performClose(nil)
        case "Minimise": window?.performMiniaturize(nil)
        case "Zoom": window?.performZoom(nil)
        case "Enter Full Screen": window?.toggleFullScreen(nil)
        case "Bring All to Front": NSApp.arrangeInFront(nil)
        default: break
        }
    }
}

@MainActor public enum NativeShellMenus {
    public static func install(shell: NativeShellState) {
        let target = ShellMenuTarget(shell: shell); shell.menuTarget = target
        let bar = NSMenu()
        for family in InterfaceCatalog.menus {
            let root = NSMenuItem(); root.title = family.title
            let menu = NSMenu(title: family.title)
            populate(family.children, menu: menu, target: target, parent: family.title)
            if family.title == "File" {
                menu.addItem(.separator())
                add("Open local Markdown…", menu: menu, target: target, key: "o", modifiers: [.command, .shift])
                add("Save", menu: menu, target: target, key: "s")
                add("Sync This Page", menu: menu, target: target)
            }
            if family.title == "Edit" { menu.addItem(.separator()); add("Find and Replace", menu: menu, target: target) }
            if family.title == "View" {
                menu.addItem(.separator())
                for mode in MarkdownEditorMode.allCases { add(mode.rawValue, menu: menu, target: target) }
                add("Markdown", menu: menu, target: target, key: "m", modifiers: [.command, .option])
            }
            root.submenu = menu; bar.addItem(root)
        }
        NSApp.mainMenu = bar
        NSApp.windowsMenu = bar.items.first { $0.title == "Window" }?.submenu
    }
    private static func populate(_ items: [InterfaceItem], menu: NSMenu, target: ShellMenuTarget, parent: String) {
        for item in items {
            if item.title == "-" { menu.addItem(.separator()); continue }
            if !item.children.isEmpty {
                let root = NSMenuItem(title: item.title, action: nil, keyEquivalent: ""); let child = NSMenu(title: item.title)
                populate(item.children, menu: child, target: target, parent: item.title); root.submenu = child; menu.addItem(root)
            } else {
                let key = ["New Page": "n", "New Section": "t", "Open Notebook…": "o", "Print…": "p", "Undo": "z", "Redo": "z", "Cut": "x", "Copy": "c", "Paste": "v", "Select All": "a", "Bold": "b", "Italic": "i", "Search This Page": "f", "Preferences…": ",", "Close": "w", "Minimise": "m"][item.title] ?? ""
                let command = parent == "Section Groups" && item.title == "Delete" ? "Delete Section Group" : item.title
                add(item.title, menu: menu, target: target, key: key, modifiers: item.title == "Redo" ? [.command, .shift] : [.command], command: command)
            }
        }
    }
    private static func add(_ title: String, menu: NSMenu, target: ShellMenuTarget, key: String = "", modifiers: NSEvent.ModifierFlags = [.command], command: String? = nil) {
        let item = NSMenuItem(title: title, action: #selector(ShellMenuTarget.invoke(_:)), keyEquivalent: key)
        item.keyEquivalentModifierMask = modifiers; item.target = target; item.representedObject = command ?? title
        if title == "Quit OpenOneNote" { item.action = #selector(NSApplication.terminate(_:)); item.target = NSApp; item.keyEquivalent = "q" }
        if title == "Hide OpenOneNote" { item.action = #selector(NSApplication.hide(_:)); item.target = NSApp; item.keyEquivalent = "h" }
        if title == "Services" { let services = NSMenu(title: "Services"); item.submenu = services; NSApp.servicesMenu = services }
        menu.addItem(item)
    }
    public static func inventory(_ menu: NSMenu) -> [String] { menu.items.flatMap { [$0.title] + ($0.submenu.map(inventory) ?? []) } }
}

@MainActor private final class ShellMenuTarget: NSObject, NSMenuItemValidation {
    weak var shell: NativeShellState?
    init(shell: NativeShellState) { self.shell = shell }
    @objc func invoke(_ sender: NSMenuItem) { shell?.perform(sender.representedObject as? String ?? sender.title) }
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool { shell?.canPerform(menuItem.representedObject as? String ?? menuItem.title) == true }
}
