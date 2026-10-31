import AppKit
import SwiftUI
import Testing
import MarkdownNotes
import MarkdownEditor

@Test @MainActor func richProjectionRetainsPortableSemantics() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let codec = MarkdownConversion()
    for source in [
        "Ordinary தமிழ் 📝 text with **bold**, *italic*, ~~strike~~ and [link](https://example.com).\n",
        "# Heading\n\nParagraph with `code`.\n\n## Second\n",
        "# Heading **bold** and *italic*\n\n**Bold with *nested italic* and more**\n",
        "- First\n- Second with **bold**\n\n3. Third\n4. Fourth\n",
        "- \n",
        "- First\n\n| Name | Role |\n| --- | --- |\n| Avery | Author |\n\n- Last\n",
        "| Name | Role |\n| --- | --- |\n| Avery | Author |\n",
        "Before\n\n```mermaid\nflowchart LR\n A --> B\n```\n\nAfter\n",
        "```swift\nlet a = 1\n```\n\n```swift\nlet a = 1\n```\n",
        "Line one  \nLine two\n",
        "- Parent\n  - Nested\n\nAfter\n"
    ] {
        let rich = try NativeRichTextCodec.render(source)
        let restored = NativeRichTextCodec.markdown(rich)
        #expect(try codec.parse(restored).blocks == codec.parse(source).blocks, "Roundtrip: \(source) became \(restored)")
    }
}

@Test @MainActor func nativeRichTableInsertionAndCellEditPersist() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root)); session.newLocal(); session.edit("")
    let commands = MarkdownTextCommands()
    let editor = NativeRichEditor(source: session.source, identity: session.selectedID, commands: commands, onChange: session.edit)
    let coordinator = editor.makeCoordinator(); let view = editor.makeTextView(coordinator: coordinator)
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = view; window.makeFirstResponder(view)
    commands.insertTable(rows: 3, columns: 2)
    #expect(session.source.contains("| Column 1 | Column 2 |"))
    #expect(!view.string.contains("|"))
    let cell = (view.string as NSString).range(of: "Cell")
    #expect(cell.location != NSNotFound)
    view.insertText("தமிழ்", replacementRange: cell)
    #expect(session.source.contains("| தமிழ் | Cell |"))
    #expect(try MarkdownConversion().parse(session.source).blocks.contains { if case .element("table", _, _) = $0 { true } else { false } })
    #expect(!window.isVisible)
}

@Test @MainActor func protectedRichStructuresRejectDestructiveEdits() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let source = "Before\n\n```mermaid\nflowchart LR\n A --> B\n```\n\nAfter\n"
    var saved = source
    let commands = MarkdownTextCommands()
    let editor = NativeRichEditor(source: source, identity: UUID(), commands: commands, onChange: { saved = $0 })
    let coordinator = editor.makeCoordinator(); let view = editor.makeTextView(coordinator: coordinator)
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = view; window.makeFirstResponder(view)
    let protected = (view.string as NSString).range(of: "flowchart")
    view.insertText("changed", replacementRange: protected)
    #expect(saved == source)
    view.setSelectedRange(protected); commands.perform("Bold")
    #expect(saved == source)
    view.insertText("Changed before", replacementRange: (view.string as NSString).range(of: "Before"))
    #expect(saved.contains("```mermaid\nflowchart LR\n A --> B\n```"))
    #expect(saved.contains("Changed before"))
    #expect(!window.isVisible)
}

@Test @MainActor func nativeListReturnContinuesAndNormalRemovesListFormatting() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    var saved = "- First\n"
    let commands = MarkdownTextCommands()
    let editor = NativeRichEditor(source: saved, identity: UUID(), commands: commands, onChange: { saved = $0 })
    let coordinator = editor.makeCoordinator(); let view = editor.makeTextView(coordinator: coordinator)
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = view; window.makeFirstResponder(view)
    #expect(view.string.hasPrefix("•\tFirst"))
    view.setSelectedRange(NSRange(location: view.string.utf16.count - 1, length: 0))
    view.insertNewline(nil); view.insertText("Second", replacementRange: view.selectedRange())
    #expect(view.string.contains("•\tSecond"))
    let document = try MarkdownConversion().parse(saved)
    #expect(document.blocks.first?.text.contains("FirstSecond") == true)
    if case .element("ul", _, let children) = document.blocks.first { #expect(children.count == 2) }
    else { Issue.record("Return did not preserve a two-item list: \(saved)") }
    commands.perform("Normal")
    #expect(view.string.contains("Second"))
    #expect(!window.isVisible)
}

@Test @MainActor func newPageFocusesInlineTitleWithoutANameDialog() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root))
    let shell = NativeShellState(session: session)
    let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
    shell.window = window; window.contentView = host; host.frame = window.contentLayoutRect
    host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    shell.createPage()
    host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    #expect(shell.sheet == nil)
    let field = try #require(window.firstResponder as? NSTextView)
    #expect(field.isFieldEditor)
    field.insertText("Inline title", replacementRange: NSRange(location: 0, length: field.string.utf16.count))
    window.makeFirstResponder(shell.richCommands.target)
    #expect(session.selected?.title == "Inline title")
    #expect(session.source.isEmpty)
    #expect(!window.isVisible)
}

@Test @MainActor func richEditsFormatUndoAndReopenWithoutMarkdownMarkers() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root))
    let shell = NativeShellState(session: session)
    #expect(!shell.markdownVisible)
    shell.createPage(notebook: "Synthetic notebook", section: "Section")
    #expect(session.source.isEmpty)
    #expect(session.selected?.title == "Untitled Page")
    #expect(shell.titleFocusRequest == 1)
    session.renameSelected("Synthetic title")
    session.edit("தமிழ் 📝 ordinary text\n")
    let editor = NativeRichEditor(source: session.source, identity: session.selectedID, commands: shell.richCommands, onChange: session.edit)
    let coordinator = editor.makeCoordinator()
    let view = editor.makeTextView(coordinator: coordinator)
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = view; window.makeFirstResponder(view)
    let range = (view.string as NSString).range(of: "தமிழ் 📝")
    view.setSelectedRange(range); shell.format("Bold")
    #expect(session.source.contains("**தமிழ் 📝**"))
    #expect(!view.string.contains("**"))
    #expect(view.selectedRange() == range)
    view.undoManager?.undo()
    #expect(!session.source.contains("**"))
    view.undoManager?.redo()
    #expect(session.source.contains("**தமிழ் 📝**"))
    let reopened = try MarkdownSession(vault: session.vault)
    reopened.select(try #require(session.selectedID))
    #expect(reopened.source == session.source)
    #expect(reopened.selected?.title == "Synthetic title")
    #expect(!window.isVisible)
}

@Test @MainActor func richAndSourceToggleRetainsNativeViewsSelectionAndUndo() throws {
    NSApplication.shared.setActivationPolicy(.prohibited)
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let session = try MarkdownSession(vault: MarkdownVault(root: root)); session.newLocal()
    session.edit("Synthetic ordinary text\n")
    let shell = NativeShellState(session: session)
    let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
    window.contentView = host; host.frame = window.contentLayoutRect
    host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.1))
    let rich = try #require(shell.richCommands.target)
    let source = try #require(shell.sourceCommands.target)
    rich.setSelectedRange(NSRange(location: 0, length: 9)); shell.format("Bold")
    let selection = rich.selectedRange()
    for visible in [true, false, true, false] {
        shell.markdownVisible = visible
        host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        #expect(shell.richCommands.target === rich)
        #expect(shell.sourceCommands.target === source)
        #expect(rich.selectedRange() == selection)
        #expect(rich.undoManager?.canUndo == true)
    }
    rich.undoManager?.undo()
    #expect(!session.source.contains("**"))
    #expect(!window.isVisible)
}
