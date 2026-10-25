import AppKit
import Testing
import NotebookEditor

@Suite(.serialized) @MainActor struct InterfaceTests {
    private func session() -> NotebookSession {
        NSApplication.shared.setActivationPolicy(.prohibited)
        return NotebookSession(url: FileManager.default.temporaryDirectory.appendingPathComponent("OpenOneNoteInterface-\(UUID())/notebook.json"))
    }
    @Test func nativeMenusRetainObservedStructureAndUnsupportedCommands() throws {
        let commands = EditorCommands(session: session())
        NotebookMenus.install(commands: commands)
        let menu = try #require(NSApp.mainMenu)
        #expect(menu.items.map(\.title) == ["OpenOneNote", "File", "Edit", "View", "Insert", "Format", "Notebooks", "Tools", "Window", "Help"])
        let file = try #require(menu.items.first(where: { $0.title == "File" })?.submenu)
        #expect(file.items.filter { !$0.isSeparatorItem && !$0.isHidden }.map(\.title) == ["New Page", "New Section", "New Section Group", "New Notebook…", "Open Notebook…", "Open Recent…", "Open Backups", "Open Section…", "Sync This Notebook", "Sync All Notebooks", "Close This Notebook", "Quick Look", "Share", "Save as PDF", "Close", "Print…"])
        let inventory = NotebookMenus.inventory(menu)
        for title in ["Send Page as PDF", "Heading 6", "Copy Link to Page", "Protect Current Section", "Small Eraser", "Audio Recording", "Paper Style", "Insert Rows Above", "Clear Application Data"] { #expect(inventory.contains(title)) }
        #expect(inventory.count > 200)
        struct Observed: Decodable { let menus: [String: [String]] }
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let observed = try JSONDecoder().decode(Observed.self, from: Data(contentsOf: root.appendingPathComponent("specs/observed-menu-labels.json")))
        for (name, labels) in observed.menus {
            let submenu = try #require(menu.items.first(where: { $0.title == name })?.submenu)
            let actual = NotebookMenus.inventory(submenu)
            for label in labels { #expect(actual.contains(label), "Missing observed menu: \(name) > \(label)") }
        }
        #expect(!commands.canPerform("Sync This Notebook"))
        #expect(!commands.canPerform("Clear Application Data"))
        #expect(file.items.first(where: { $0.title == "Sync This Notebook" })?.isHidden == false)
        #expect(file.items.first(where: { $0.title == "Sync This Notebook" })?.target === commands)
    }
    @Test func viewCommandsDoNotRewriteNotebookGeometryOrContent() throws {
        let model = session(); let commands = EditorCommands(session: model)
        let before = model.notebook
        for title in ["Ribbon", "Hide Section and Page Lists", "Hide Page Title", "Switch Background", "Zoom In", "Wide Ruled"] { commands.perform(title) }
        #expect(commands.ribbonCollapsed && commands.navigationHidden && commands.hidePageTitle && commands.lightCanvas)
        #expect(commands.zoom > 1 && commands.paperStyle == "Wide Ruled")
        #expect(model.notebook == before)
        commands.perform("New Page")
        #expect(model.selectedSection?.pages.count == 2)
    }
    @Test func sharedMenuCommandsReachRealNativeSelectionAndUndo() throws {
        let model = session(); let commands = EditorCommands(session: model)
        let page = try #require(model.selectedPage); let block = try #require(page.blocks.first)
        let editor = RichTextEditor(text: "First paragraph\nSecond paragraph", richText: nil, undoManager: model.undoManager,
            onChange: { model.editText(pageID: page.id, blockID: block.id, text: $0, richText: $1) }, onError: { Issue.record("\($0)") })
        let coordinator = editor.makeCoordinator(); let view = try #require(editor.makeTextView(coordinator: coordinator) as? NotebookTextView)
        view.formatting = commands.formatting; commands.formatting.attach(view)
        view.setSelectedRange(NSRange(location: 0, length: 5))
        model.undoManager.beginUndoGrouping(); commands.perform("Strikethrough"); model.undoManager.endUndoGrouping()
        #expect(view.attributedString().attribute(.strikethroughStyle, at: 0, effectiveRange: nil) as? Int == 1)
        model.undoManager.beginUndoGrouping(); commands.perform("Strikethrough"); model.undoManager.endUndoGrouping()
        #expect(view.attributedString().attribute(.strikethroughStyle, at: 0, effectiveRange: nil) as? Int == 0)
        model.undoManager.beginUndoGrouping(); commands.perform("Increase Indent"); model.undoManager.endUndoGrouping()
        #expect((view.attributedString().attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)?.headIndent == 24)
        model.undoManager.beginUndoGrouping(); commands.perform("Important"); model.undoManager.endUndoGrouping()
        #expect(view.string.hasPrefix("★ "))
        model.undoManager.undo(); #expect(!view.string.hasPrefix("★ "))
        view.setSelectedRange(NSRange(location: view.string.utf16.count, length: 0))
        model.undoManager.beginUndoGrouping(); commands.perform("Table"); model.undoManager.endUndoGrouping()
        view.setSelectedRange(NSRange(location: 0, length: view.string.utf16.count))
        model.undoManager.beginUndoGrouping(); commands.perform("Clear All Formatting"); model.undoManager.endUndoGrouping()
        var tableCells = 0
        view.attributedString().enumerateAttribute(.paragraphStyle, in: view.selectedRange()) { value, _, _ in tableCells += (value as? NSParagraphStyle)?.textBlocks.count ?? 0 }
        #expect(tableCells >= 6)
        withExtendedLifetime(coordinator) {}
    }
}
