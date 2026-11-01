import AppKit
import Foundation
import Testing
import MarkdownNotes
import MarkdownEditor

@Test @MainActor func markdownFormattingUsesUTF16SelectionAndNativeUndo() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root)); session.newLocal()
    let original = "தமிழ் 📝 text\nsecond\n"
    session.edit(original)
    let commands = MarkdownTextCommands()
    var editor = MarkdownSourceEditor(source: original, identity: session.selectedID, onChange: session.edit)
    editor.commands = commands
    let coordinator = editor.makeCoordinator(); let view = editor.makeTextView(coordinator: coordinator)
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 600, height: 400), styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = view; window.makeFirstResponder(view)
    let range = (original as NSString).range(of: "தமிழ் 📝")
    view.setSelectedRange(range); commands.perform("Bold")
    RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    #expect(session.source == "**தமிழ் 📝** text\nsecond\n")
    #expect((view.string as NSString).substring(with: view.selectedRange()) == "தமிழ் 📝")
    commands.perform("Bold")
    RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    #expect(session.source == original)
    view.undoManager?.undo()
    #expect(view.string == "**தமிழ் 📝** text\nsecond\n")
    view.undoManager?.redo()
    #expect(view.string == original)
    view.setSelectedRange(NSRange(location: 0, length: 0)); commands.perform("Heading 2")
    #expect(session.source == "## தமிழ் 📝 text\nsecond\n")
    commands.perform("Normal")
    #expect(session.source == original)
    let reopened = try MarkdownSession(vault: session.vault); reopened.select(try #require(session.selectedID))
    #expect(reopened.source == original)
    view.setSelectedRange(NSRange(location: view.string.utf16.count, length: 0))
    commands.insertTable(rows: 8, columns: 10)
    func rows(_ node: NoteNode) -> Int {
        guard case .element(let tag, _, let children) = node else { return 0 }
        return tag == "tr" ? 1 : children.reduce(0) { $0 + rows($1) }
    }
    let document = try MarkdownConversion().parse(session.source)
    #expect(document.blocks.reduce(0) { $0 + rows($1) } == 8)
    let tableSource = session.source
    commands.insertTable(rows: 9, columns: 10)
    #expect(session.source == tableSource)
    #expect(!window.isVisible)
}

@Test @MainActor func nativeShellModesAndNavigationPreserveLocalDocuments() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root))
    let shell = NativeShellState(session: session)
    shell.createPage(notebook: "Synthetic notebook", section: "First section")
    let first = try #require(session.selectedID)
    session.edit("# First synthetic page\n")
    let saved = try session.vault.markdown(try #require(session.selected))
    for mode in MarkdownEditorMode.allCases { shell.mode = mode; #expect(session.source == saved) }
    shell.createPage(notebook: "Synthetic notebook", section: "Second section")
    #expect(shell.notebooks == ["Synthetic notebook"])
    #expect(shell.sections == ["First section", "Second section"])
    shell.selectSection("First section")
    #expect(session.selectedID == first)
    #expect(session.source == saved)
    session.busy = true; shell.selectSection("Second section")
    #expect(shell.section == "First section")
    #expect(session.selectedID == first)
    session.busy = false
    #expect(shell.friendlyState == "Saved on this Mac")
    session.message = "The file could not be saved."
    #expect(shell.visibleStatus == "The file could not be saved.")
    #expect(!shell.canPerform("Sync This Notebook"))
    #expect(!shell.canPerform("Delete Page"))
    #expect(!shell.canPerform("Delete Section Group"))
    let reopened = try MarkdownSession(vault: session.vault); reopened.select(first)
    #expect(reopened.selected?.hierarchy == ["Synthetic notebook", "First section"])
    #expect(reopened.source == saved)
}

@Test @MainActor func nativeMenuFamiliesRetainObservedLabelsWithoutDestructiveSubstitution() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let shell = NativeShellState(session: try MarkdownSession(vault: MarkdownVault(root: root)))
    let previous = NSApp.mainMenu; defer { NSApp.mainMenu = previous }
    NativeShellMenus.install(shell: shell)
    let menu = try #require(NSApp.mainMenu)
    let project = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let fixture = try JSONSerialization.jsonObject(with: Data(contentsOf: project.appendingPathComponent("specs/observed-menu-labels.json"))) as! [String: Any]
    let families = fixture["menus"] as! [String: [String]]
    for (name, labels) in families {
        let family = try #require(menu.items.first { $0.title == name }?.submenu)
        let actual = NativeShellMenus.inventory(family)
        for label in labels { #expect(actual.contains(label), "Missing \(name) → \(label)") }
    }
    let file = try #require(menu.items.first { $0.title == "File" }?.submenu)
    #expect(file.items.first { $0.title == "Open Notebook…" }?.keyEquivalent == "o")
    #expect(file.items.first { $0.title == "Open local Markdown…" }?.keyEquivalent == "o")
    #expect(file.items.first { $0.title == "Open local Markdown…" }?.keyEquivalentModifierMask == [.command, .shift])
    let notebooks = try #require(menu.items.first { $0.title == "Notebooks" }?.submenu)
    let groups = try #require(notebooks.items.first { $0.title == "Section Groups" }?.submenu)
    #expect(groups.items.first { $0.title == "Delete" }?.representedObject as? String == "Delete Section Group")
}

@Test @MainActor func cloudBrowserAndStorageWindowsStayHiddenDuringVerificationAndReuseIdentity() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    session.newLocal(); session.edit("Preserved synthetic note\n")
    let id = session.selectedID
    let before = Set(NSApp.windows.map(ObjectIdentifier.init))
    let shell = NativeShellState(session: session)
    shell.showCloud(.notebooks); shell.showCloud(.notebooks); shell.showCloud(.storage)
    let owned = NSApp.windows.filter { !before.contains(ObjectIdentifier($0)) }
    defer { owned.forEach { $0.close() } }
    #expect(owned.count == 2)
    #expect(Set(owned.map(\.title)) == ["Open Notebook", "Storage Accounts"])
    #expect(owned.allSatisfy { !$0.isVisible })
    #expect(session.selectedID == id && session.source == "Preserved synthetic note\n")
    #expect(shell.sheet == nil)
}
