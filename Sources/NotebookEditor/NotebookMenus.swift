import AppKit

@MainActor public enum NotebookMenus {
    public static func install(commands: EditorCommands) {
        let root = NSMenu()
        for group in InterfaceCatalog.menus {
            let item = NSMenuItem(title: group.title, action: nil, keyEquivalent: "")
            let menu = build(group.children, title: group.title, commands: commands)
            item.submenu = menu; root.addItem(item)
            if group.title == "Window" { NSApp.windowsMenu = menu }
            if group.title == "Help" { NSApp.helpMenu = menu }
        }
        // The local store saves automatically; retain the existing explicit-save shortcut.
        let save = NSMenuItem(title: "Save", action: #selector(EditorCommands.menuAction(_:)), keyEquivalent: "s")
        save.target = commands; save.representedObject = "Save"; save.isHidden = true; save.allowsKeyEquivalentWhenHidden = true
        root.items.first(where: { $0.title == "File" })?.submenu?.addItem(save)
        NSApp.mainMenu = root
    }
    private static let native: [String: (String, String)] = [
        "About OpenOneNote": ("orderFrontStandardAboutPanel:", ""), "Hide OpenOneNote": ("hide:", "h"), "Hide Others": ("hideOtherApplications:", "h"), "Show All": ("unhideAllApplications:", ""), "Quit OpenOneNote": ("terminate:", "q"), "Close": ("performClose:", "w"), "Minimise": ("performMiniaturize:", "m"), "Zoom": ("performZoom:", ""), "Enter Full Screen": ("toggleFullScreen:", "f"), "Bring All to Front": ("arrangeInFront:", ""), "Emoji & Symbols": ("orderFrontCharacterPalette:", "")
    ]
    public static func build(_ items: [InterfaceItem], title: String, commands: EditorCommands) -> NSMenu {
        let menu = NSMenu(title: title)
        for definition in items {
            if title == "Move & Resize", ["Left", "Top Left", "Left & Right"].contains(definition.title) {
                let header = NSMenuItem(title: definition.title == "Left" ? "Halves" : definition.title == "Top Left" ? "Quarters" : "Arrange", action: nil, keyEquivalent: "")
                header.isEnabled = false; menu.addItem(header)
            }
            if definition.title == "-" { menu.addItem(.separator()); continue }
            let item = NSMenuItem(title: definition.title, action: nil, keyEquivalent: "")
            if !definition.children.isEmpty { item.submenu = build(definition.children, title: definition.title, commands: commands) }
            else if definition.title == "Services" { let services = NSMenu(title: "Services"); item.submenu = services; NSApp.servicesMenu = services }
            else if let (selector, key) = native[definition.title] {
                item.action = NSSelectorFromString(selector); item.keyEquivalent = key
                if ["Hide Others"].contains(definition.title) { item.keyEquivalentModifierMask = [.command, .option] }
                if definition.title == "Enter Full Screen" { item.keyEquivalentModifierMask = [.command, .control] }
            } else {
                let command = title == "Window" && definition.title == "Centre" ? "Window Centre" : title == "Section Groups" && definition.title == "Delete" ? "Delete Section Group" : definition.title
                item.action = #selector(EditorCommands.menuAction(_:)); item.target = commands; item.representedObject = command
                let keys = ["New Page": "n", "New Section": "t", "Undo": "z", "Redo": "z", "Cut": "x", "Copy": "c", "Paste": "v", "Select All": "a", "Bold": "b", "Italic": "i", "Underline": "u", "Search This Page": "f"]
                item.keyEquivalent = keys[definition.title] ?? ""
                if definition.title == "Redo" { item.keyEquivalentModifierMask = [.command, .shift] }
                item.isEnabled = commands.canPerform(command)
                if !item.isEnabled { item.toolTip = "This command is not available in the local editor yet." }
            }
            menu.addItem(item)
        }
        return menu
    }
    public static func inventory(_ menu: NSMenu) -> [String] {
        menu.items.flatMap { item in [item.title] + (item.submenu.map(inventory) ?? []) }
    }
}
