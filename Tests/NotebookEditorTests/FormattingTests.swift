import AppKit
import Testing
import NotebookEditor

@Suite(.serialized) @MainActor struct FormattingTests {
    @Test func ribbonCommandsRetainSelectionAndPersistRichStructures() throws {
        NSApplication.shared.setActivationPolicy(.prohibited)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("OpenOneNoteFormat-\(UUID())/notebook.json")
        let session = NotebookSession(url: url)
        let page = try #require(session.selectedPage)
        let block = try #require(page.blocks.first)
        let editor = RichTextEditor(text: "Alpha\nBeta\n", richText: nil, undoManager: session.undoManager,
            onChange: { session.editText(pageID: page.id, blockID: block.id, text: $0, richText: $1) }, onError: { Issue.record("\($0)") })
        let coordinator = editor.makeCoordinator()
        let view = try #require(editor.makeTextView(coordinator: coordinator) as? NotebookTextView)
        let formatting = EditorFormatting(); view.formatting = formatting; formatting.attach(view)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 500), styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = view; window.makeFirstResponder(view)
        view.setSelectedRange(NSRange(location: 0, length: 5))
        session.undoManager.beginUndoGrouping()
        formatting.font(name: "Helvetica", size: 24)
        formatting.attribute(.underlineStyle, value: 1, action: "Underline")
        formatting.link("https://example.com/notes")
        session.undoManager.endUndoGrouping()
        let first = view.attributedString().attributes(at: 0, effectiveRange: nil)
        #expect((first[.font] as? NSFont)?.pointSize == 24)
        #expect((first[.underlineStyle] as? Int) == 1)
        #expect(first[.link] != nil)
        #expect(view.selectedRange() == NSRange(location: 0, length: 5))
        session.undoManager.undo()
        #expect(view.attributedString().attribute(.link, at: 0, effectiveRange: nil) == nil)
        session.undoManager.redo()
        session.undoManager.beginUndoGrouping()
        formatting.list(numbered: false)
        session.undoManager.endUndoGrouping()
        #expect((view.attributedString().attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)?.textLists.count == 1)
        session.undoManager.beginUndoGrouping(); formatting.list(numbered: true); session.undoManager.endUndoGrouping()
        #expect((view.attributedString().attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)?.textLists.first?.markerFormat == .decimal)
        session.undoManager.beginUndoGrouping(); formatting.list(numbered: true); session.undoManager.endUndoGrouping()
        #expect((view.attributedString().attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle)?.textLists.isEmpty == true)
        session.undoManager.beginUndoGrouping()
        formatting.heading(1)
        session.undoManager.endUndoGrouping()
        #expect((view.attributedString().attribute(.font, at: 0, effectiveRange: nil) as? NSFont)?.pointSize == 20)
        view.setSelectedRange(NSRange(location: view.string.utf16.count, length: 0))
        session.undoManager.beginUndoGrouping(); formatting.table(); session.undoManager.endUndoGrouping()
        #expect(view.string.contains("Column 1"))
        #expect(session.saveNow())
        let reopened = NotebookSession(url: url)
        let decoded = try RichTextCodec.decode(try #require(reopened.selectedPage?.blocks.first?.richText))
        #expect(decoded.string == view.string)
        var tables = 0
        decoded.enumerateAttribute(.paragraphStyle, in: NSRange(location: 0, length: decoded.length)) { value, _, _ in
            tables += (value as? NSParagraphStyle)?.textBlocks.count ?? 0
        }
        #expect(tables >= 6)
        session.undoManager.undo()
        #expect(!view.string.contains("Column 1"))
        formatting.clear(); #expect(!formatting.available)
        view.setSelectedRange(NSRange(location: 1, length: 0)); formatting.attach(view)
        formatting.font(size: 24)
        #expect(formatting.fontSize == 24)
        formatting.font(name: "Helvetica")
        #expect((view.typingAttributes[.font] as? NSFont)?.pointSize == 24)
        formatting.perform("toggleBoldface:")
        #expect(formatting.bold)
        formatting.attribute(.underlineStyle, value: 1, action: "Underline")
        #expect(formatting.underline)
        withExtendedLifetime(coordinator) {}
    }
}
