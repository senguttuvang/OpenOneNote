import AppKit
import Foundation
import Testing
import NotebookCore
import NotebookEditor
import NotebookPersistence

@Suite(.serialized) @MainActor
struct EditorTests {
    private func location() -> URL {
        NSApplication.shared.setActivationPolicy(.prohibited)
        return FileManager.default.temporaryDirectory.appendingPathComponent("OpenOneNoteTests-\(UUID())/notebook.json")
    }

    @Test func realNativeTextViewEditUndoRedoAndReopen() throws {
        let url = location()
        try NativeVerification.exerciseEditor(at: url)
    }

    @Test func boldUnicodeRichTextSurvivesSaveAndReopen() throws {
        let url = location()
        let session = NotebookSession(url: url)
        let page = try #require(session.selectedPage)
        let block = try #require(page.blocks.first)
        let value = NSAttributedString(string: "தமிழ் — Bold 👋", attributes: [.font: NSFont.boldSystemFont(ofSize: 18)])
        let encoded = try RichTextCodec.encode(value)
        session.editText(pageID: page.id, blockID: block.id, text: value.string, richText: encoded)
        #expect(session.saveNow())
        let reopened = NotebookSession(url: url)
        #expect(reopened.notebook == session.notebook)
        let decoded = try RichTextCodec.decode(try #require(reopened.selectedPage?.blocks.first?.richText))
        #expect(decoded.string == value.string)
        let font = try #require(decoded.attribute(.font, at: 0, effectiveRange: nil) as? NSFont)
        #expect(NSFontManager.shared.traits(of: font).contains(.boldFontMask))
    }

    @Test func sectionAndGeometryCommandsSupportUndoAndPersist() throws {
        let url = location()
        let session = NotebookSession(url: url)
        session.undoManager.groupsByEvent = false
        let before = session.notebook
        session.undoManager.beginUndoGrouping(); session.addSection(); session.undoManager.endUndoGrouping()
        #expect(session.notebook?.sections.count == 2)
        session.undoManager.undo()
        #expect(session.notebook == before)
        session.undoManager.redo()
        #expect(session.notebook?.sections.count == 2)
        let page = try #require(session.selectedPage)
        let block = try #require(page.blocks.first)
        session.undoManager.beginUndoGrouping()
        session.setGeometry(pageID: page.id, blockID: block.id, x: -20, y: 220, width: 100, height: 400)
        session.undoManager.endUndoGrouping()
        let moved = try #require(session.selectedPage?.blocks.first)
        #expect(moved.x == 0 && moved.y == 220 && moved.width == 240 && moved.height == 400)
        session.undoManager.undo()
        #expect(session.selectedPage?.blocks.first == block)
        #expect(session.saveNow())
        #expect(NotebookSession(url: url).notebook == session.notebook)
    }

    @Test func corruptNotebookCannotBeReplacedOnOpenOrSave() throws {
        let url = location()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let original = Data("not a notebook".utf8)
        try original.write(to: url)
        let session = NotebookSession(url: url)
        #expect(session.notebook == nil)
        #expect(session.errorMessage != nil)
        #expect(!session.saveNow())
        #expect(try Data(contentsOf: url) == original)
    }

    @Test func saveFailureRetainsInMemoryEditsForRetry() throws {
        let url = location()
        let session = NotebookSession(url: url)
        let page = try #require(session.selectedPage)
        let block = try #require(page.blocks.first)
        let rtf = try RichTextCodec.encode(NSAttributedString(string: "Keep this edit"))
        let preserved = url.deletingLastPathComponent().appendingPathComponent("original.json")
        try FileManager.default.moveItem(at: url, to: preserved)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
        session.editText(pageID: page.id, blockID: block.id, text: "Keep this edit", richText: rtf)
        #expect(!session.saveNow())
        #expect(session.selectedPage?.blocks.first?.text == "Keep this edit")
        #expect(session.errorMessage != nil)
        #expect(try JSONNotebookRepository(url: preserved).load().title == "My Notebook")
        try FileManager.default.moveItem(at: url, to: url.deletingLastPathComponent().appendingPathComponent("obstruction"))
        #expect(session.saveNow())
        #expect(NotebookSession(url: url).notebook == session.notebook)
    }

    @Test func invalidRichTextDoesNotOverwriteAValidNotebookContainer() throws {
        let url = location()
        let session = NotebookSession(url: url)
        var value = try #require(session.notebook)
        value.sections[0].pages[0].blocks[0].richText = Data("broken rich text".utf8)
        try JSONNotebookRepository(url: url).save(value)
        let original = try Data(contentsOf: url)
        let reopened = NotebookSession(url: url)
        #expect(reopened.notebook == nil)
        #expect(reopened.errorMessage != nil)
        #expect(!reopened.saveNow())
        #expect(try Data(contentsOf: url) == original)
    }

    @Test func navigatingToAnotherPageClearsInvisibleTextUndoTargets() throws {
        let session = NotebookSession(url: location())
        session.undoManager.beginUndoGrouping(); session.addPage(); session.undoManager.endUndoGrouping()
        #expect(session.undoManager.canUndo)
        session.selectSection(try #require(session.selectedSectionID))
        session.selectPage(try #require(session.selectedPageID))
        #expect(session.undoManager.canUndo)
        let first = try #require(session.selectedSection?.pages.first)
        session.selectPage(first.id)
        #expect(!session.undoManager.canUndo)
        #expect(session.selectedPageID == first.id)
    }
}
