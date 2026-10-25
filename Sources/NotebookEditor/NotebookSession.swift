import AppKit
import Combine
import NotebookCore
import NotebookPersistence

@MainActor
public final class NotebookSession: ObservableObject {
    @Published public private(set) var notebook: Notebook?
    @Published public var selectedSectionID: UUID?
    @Published public var selectedPageID: UUID?
    @Published public private(set) var status = "Opening…"
    @Published public private(set) var errorMessage: String?
    public let url: URL
    public let undoManager = UndoManager()
    private let repository: JSONNotebookRepository
    private var pendingSave: Task<Void, Never>?

    public init(url: URL) {
        self.url = url
        repository = JSONNotebookRepository(url: url)
        undoManager.levelsOfUndo = 100
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                let loaded = try repository.load()
                for section in loaded.sections {
                    for page in section.pages {
                        for block in page.blocks {
                            if let data = block.richText { _ = try RichTextCodec.decode(data) }
                        }
                    }
                }
                notebook = loaded
            } else {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
                notebook = Notebook(title: "My Notebook", sections: [NoteSection(title: "Notes", pages: [
                    NotePage(title: "Welcome", blocks: [NoteBlock(x: 48, y: 32, width: 600,
                        text: "A place for your thoughts\n\nStart writing here. Select text to make it bold or italic. Add another text container to put notes anywhere on the page.", height: 300)])
                ])])
                try repository.save(notebook!)
            }
            normalizeSelection()
            status = "Saved on this Mac"
        } catch {
            notebook = nil
            status = "Couldn’t open notebook"
            errorMessage = error.localizedDescription
        }
    }

    public var selectedSection: NoteSection? { notebook?.sections.first { $0.id == selectedSectionID } }
    public var selectedPage: NotePage? { selectedSection?.pages.first { $0.id == selectedPageID } }

    public func selectSection(_ id: UUID) {
        guard selectedSectionID != id else { return }
        undoManager.removeAllActions()
        selectedSectionID = id
        selectedPageID = selectedSection?.pages.first?.id
    }

    public func selectPage(_ id: UUID) {
        guard selectedPageID != id else { return }
        undoManager.removeAllActions()
        selectedPageID = id
    }

    public func renameNotebook(_ title: String) {
        guard var value = notebook else { return }
        value.title = title; notebook = value; scheduleSave()
    }

    public func renamePage(_ title: String, pageID: UUID) {
        guard var value = notebook, let (section, page) = location(pageID, in: value) else { return }
        value.sections[section].pages[page].title = title; notebook = value; scheduleSave()
    }

    public func renameSection(_ title: String) {
        guard var value = notebook, let index = value.sections.firstIndex(where: { $0.id == selectedSectionID }) else { return }
        value.sections[index].title = title; notebook = value; scheduleSave()
    }

    public func addSection() {
        guard var value = notebook else { return }
        let section = NoteSection(title: "Section \(value.sections.count + 1)", pages: [NotePage(title: "Untitled page")])
        value.sections.append(section)
        replaceNotebook(value, action: "New Section")
        selectedSectionID = section.id; selectedPageID = section.pages[0].id
    }

    public func addPage() {
        guard var value = notebook, let section = value.sections.firstIndex(where: { $0.id == selectedSectionID }) else { return }
        let page = NotePage(title: "Untitled page", blocks: [NoteBlock(x: 48, y: 32, width: 600, height: 300)])
        value.sections[section].pages.append(page)
        replaceNotebook(value, action: "New Page")
        selectedPageID = page.id
    }

    public func addContainer() {
        guard var value = notebook, let id = selectedPageID, let (section, page) = location(id, in: value) else { return }
        let bottom = value.sections[section].pages[page].blocks.map { $0.y + ($0.height ?? 260) }.max() ?? 0
        value.sections[section].pages[page].blocks.append(NoteBlock(x: 48, y: bottom + 32, width: 600, height: 260))
        replaceNotebook(value, action: "New Text Container")
    }

    public func editText(pageID: UUID, blockID: UUID, text: String, richText: Data) {
        updateBlock(pageID: pageID, blockID: blockID) { $0.text = text; $0.richText = richText }
    }

    public func setGeometry(pageID: UUID, blockID: UUID, x: Double, y: Double, width: Double, height: Double) {
        guard var value = notebook, let (section, page) = location(pageID, in: value),
              let block = value.sections[section].pages[page].blocks.firstIndex(where: { $0.id == blockID }) else { return }
        value.sections[section].pages[page].blocks[block].x = max(0, x)
        value.sections[section].pages[page].blocks[block].y = max(0, y)
        value.sections[section].pages[page].blocks[block].width = min(1800, max(240, width))
        value.sections[section].pages[page].blocks[block].height = min(1400, max(140, height))
        replaceNotebook(value, action: "Resize or Move Text Container")
    }

    public func reportError(_ error: Error) { errorMessage = error.localizedDescription; status = "Changes need attention" }

    @discardableResult public func saveNow() -> Bool {
        pendingSave?.cancel(); pendingSave = nil
        guard let notebook else { return false }
        do {
            try repository.save(notebook)
            status = "Saved on this Mac"; errorMessage = nil
            return true
        } catch { reportError(error); return false }
    }

    private func updateBlock(pageID: UUID, blockID: UUID, change: (inout NoteBlock) -> Void) {
        guard var value = notebook, let (section, page) = location(pageID, in: value),
              let block = value.sections[section].pages[page].blocks.firstIndex(where: { $0.id == blockID }) else { return }
        change(&value.sections[section].pages[page].blocks[block])
        notebook = value; scheduleSave()
    }

    private func replaceNotebook(_ value: Notebook, action: String) {
        if let old = notebook {
            undoManager.registerUndo(withTarget: self) { target in
                MainActor.assumeIsolated { target.replaceNotebook(old, action: action) }
            }
            undoManager.setActionName(action)
        }
        notebook = value; normalizeSelection(); scheduleSave()
    }

    private func normalizeSelection() {
        if notebook?.sections.contains(where: { $0.id == selectedSectionID }) != true { selectedSectionID = notebook?.sections.first?.id }
        if selectedSection?.pages.contains(where: { $0.id == selectedPageID }) != true { selectedPageID = selectedSection?.pages.first?.id }
    }

    private func location(_ id: UUID, in value: Notebook) -> (Int, Int)? {
        for (section, item) in value.sections.enumerated() {
            if let page = item.pages.firstIndex(where: { $0.id == id }) { return (section, page) }
        }
        return nil
    }

    private func scheduleSave() {
        status = "Saving…"; pendingSave?.cancel()
        pendingSave = Task { [weak self] in
            do { try await Task.sleep(for: .milliseconds(300)) } catch { return }
            self?.saveNow()
        }
    }
}
