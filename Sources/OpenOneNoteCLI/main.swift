import Foundation
import NotebookCore
import NotebookPersistence

enum CLIError: Error { case usage, destinationExists }

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    guard arguments.count == 2 else { throw CLIError.usage }
    let url = URL(fileURLWithPath: arguments[1])
    let repository = JSONNotebookRepository(url: url)
    switch arguments[0] {
    case "create-demo":
        guard !FileManager.default.fileExists(atPath: url.path) else { throw CLIError.destinationExists }
        let notebook = Notebook(title: "OpenOneNote", sections: [
            NoteSection(title: "Getting Started", pages: [
                NotePage(title: "Welcome", blocks: [NoteBlock(text: "An independent native Swift notebook foundation.")])
            ])
        ])
        try repository.save(notebook)
        guard try repository.load() == notebook else { throw CLIError.usage }
        print("Created and verified \(url.lastPathComponent)")
    case "inspect":
        let notebook = try repository.load()
        print("\(notebook.title): \(notebook.sections.count) sections, \(notebook.sections.reduce(0) { $0 + $1.pages.count }) pages")
    default: throw CLIError.usage
    }
} catch {
    FileHandle.standardError.write(Data("OpenOneNote failed: \(error)\nUsage: openonenote <create-demo|inspect> <notebook.json>\n".utf8))
    exit(1)
}
