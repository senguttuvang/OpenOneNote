import Foundation
import Testing
import NotebookCore
import NotebookPersistence

private func temporaryURL() throws -> URL {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory.appendingPathComponent("notebook.json")
}

@Test func preservesIdentityUnicodeAndGeometryAcrossSaveAndReload() throws {
    let url = try temporaryURL()
    defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
    let notebook = Notebook(title: "Research", sections: [NoteSection(title: "Notes", pages: [
        NotePage(title: "தமிழ்", blocks: [NoteBlock(x: 84.5, y: 240, width: 901, text: "செங்கூ\nHello 👋")])
    ])])
    let repository = JSONNotebookRepository(url: url)
    try repository.save(notebook)
    #expect(try repository.load() == notebook)
    var edited = notebook
    edited.sections[0].pages[0].blocks[0].text = "Changed"
    try repository.save(edited)
    #expect(try repository.load() == edited)
}

@Test func duplicateIDsAreRejectedAcrossHierarchy() throws {
    let identity = UUID()
    let notebook = Notebook(id: identity, title: "Invalid", sections: [NoteSection(id: identity, title: "Duplicate")])
    #expect(throws: NotebookError.duplicateIdentity(identity)) { try notebook.validate() }
}

@Test func invalidGeometryCannotOverwriteExistingNotebook() throws {
    let url = try temporaryURL()
    defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
    let repository = JSONNotebookRepository(url: url)
    let original = Notebook(title: "Keep this")
    try repository.save(original)
    for width in [0.0, -1.0, .infinity, .nan] {
        let block = NoteBlock(width: width)
        let invalid = Notebook(title: "Invalid", sections: [NoteSection(title: "Section", pages: [NotePage(title: "Page", blocks: [block])])])
        #expect(throws: NotebookError.invalidGeometry(block.id)) { try repository.save(invalid) }
        #expect(try repository.load() == original)
    }
}

@Test func corruptMissingAndFutureFilesFailWithoutReplacement() throws {
    let url = try temporaryURL()
    defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
    let repository = JSONNotebookRepository(url: url)
    #expect(throws: (any Error).self) { try repository.load() }
    #expect(!FileManager.default.fileExists(atPath: url.path))
    let corrupt = Data("broken notebook".utf8)
    try corrupt.write(to: url)
    #expect(throws: (any Error).self) { try repository.load() }
    #expect(try Data(contentsOf: url) == corrupt)
    let future = Data("{\"schemaVersion\":99}".utf8)
    try future.write(to: url)
    #expect(throws: NotebookError.unsupportedSchema(99)) { try repository.load() }
    #expect(try Data(contentsOf: url) == future)
}

@Test func invalidCoordinatesAreRejected() throws {
    for position in [-1.0, .infinity, .nan] {
        for block in [NoteBlock(x: position), NoteBlock(y: position)] {
            let notebook = Notebook(title: "Invalid", sections: [NoteSection(title: "Section", pages: [NotePage(title: "Page", blocks: [block])])])
            #expect(throws: NotebookError.invalidGeometry(block.id)) { try notebook.validate() }
        }
    }
}

@Test func plainFoundationNotebookRemainsReadableWithoutRichTextFields() throws {
    let block = "{\"id\":\"00000000-0000-0000-0000-000000000004\",\"x\":48,\"y\":32,\"width\":600,\"text\":\"Legacy text\"}"
    let json = "{\"id\":\"00000000-0000-0000-0000-000000000001\",\"title\":\"Original\",\"sections\":[{\"id\":\"00000000-0000-0000-0000-000000000002\",\"title\":\"Notes\",\"pages\":[{\"id\":\"00000000-0000-0000-0000-000000000003\",\"title\":\"Page\",\"blocks\":[\(block)]}]}]}"
    let notebook = try JSONDecoder().decode(Notebook.self, from: Data(json.utf8))
    try notebook.validate()
    #expect(notebook.sections[0].pages[0].blocks[0].text == "Legacy text")
    #expect(notebook.sections[0].pages[0].blocks[0].richText == nil)
    #expect(notebook.sections[0].pages[0].blocks[0].height == nil)
}

@Test func invalidContainerHeightIsRejected() throws {
    for height in [0.0, -1.0, .infinity, .nan] {
        let block = NoteBlock(height: height)
        let value = Notebook(title: "Invalid", sections: [NoteSection(title: "Section", pages: [NotePage(title: "Page", blocks: [block])])])
        #expect(throws: NotebookError.invalidGeometry(block.id)) { try value.validate() }
    }
}
