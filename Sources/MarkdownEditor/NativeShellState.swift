import AppKit
import Observation
import MarkdownNotes

public enum MarkdownEditorMode: String, CaseIterable, Sendable { case write = "Write", split = "Split", read = "Read" }
public enum NativeSearchScope { case section, notebook, all }
public enum NativeShellSheet: String, Identifiable { case account, notebooks, settings, recovery, newNotebook; public var id: String { rawValue } }

/// Presentation state only. Auth, Graph and document recovery stay in MarkdownSession.
@MainActor @Observable public final class NativeShellState {
    public let session: MarkdownSession
    public let sourceCommands = MarkdownTextCommands()
    public let richCommands = MarkdownTextCommands()
    public var editor: MarkdownTextCommands { markdownVisible ? sourceCommands : richCommands }
    public var tab = "Home"
    public var mode: MarkdownEditorMode = .write
    public var markdownVisible = false
    public var titleFocusRequest = 0
    public var editingSectionID: UUID?
    public var editingSectionName: String?
    public var sectionNameDraft = ""
    public var sheet: NativeShellSheet?
    public var navigationHidden = false
    public var ribbonCollapsed = false
    public var searching = false
    public var search = ""
    public var searchScope: NativeSearchScope = .section
    public var notebook = ""
    public var section = ""
    public var lightPaper = false
    public var zoom = 1.0
    public var sectionWidth = 300.0
    public var pageWidth = 250.0
    public var newWindow: (() -> Void)?
    public weak var window: NSWindow?
    var menuTarget: NSObject?
    public init(session: MarkdownSession) { self.session = session; followSelection() }
    public func notebookName(_ note: NoteLedger) -> String { note.hierarchy?.first ?? (note.identity.root == "local" ? "On My Mac" : "OneNote") }
    public func sectionName(_ note: NoteLedger) -> String { (note.hierarchy?.count ?? 0) > 1 ? note.hierarchy!.dropFirst().joined(separator: " / ") : "Notes" }
    public var notebooks: [String] { Array(Set(session.notes.map(notebookName))).sorted { $0.localizedStandardCompare($1) == .orderedAscending } }
    public var sections: [String] { Array(Set(session.notes.filter { notebookName($0) == notebook }.map(sectionName))).sorted { $0.localizedStandardCompare($1) == .orderedAscending } }
    public var pages: [NoteLedger] {
        session.notes.filter {
            let scopeMatches = searching && !search.isEmpty
                ? (searchScope == .all || notebookName($0) == notebook && (searchScope == .notebook || sectionName($0) == section))
                : notebookName($0) == notebook && sectionName($0) == section
            return scopeMatches && (search.isEmpty || $0.title.localizedCaseInsensitiveContains(search))
        }
    }
    public func pagePreview(_ note: NoteLedger) -> String {
        let document = note.id == session.selectedID ? session.preview : (try? MarkdownConversion().parse(String((note.pendingMarkdown ?? note.baselineMarkdown).prefix(512))))
        let text = document?.blocks.map(\.text).joined(separator: " ").replacingOccurrences(of: "\n", with: " ") ?? ""
        return text.isEmpty ? "No additional text" : text
    }
    public var tableContext: Bool {
        _ = editor.selectionRevision
        guard mode != .read, let view = editor.target else { return false }
        if !markdownVisible, view.attributedString().length > 0 {
            let index = min(view.selectedRange().location, view.attributedString().length - 1)
            return (view.attributedString().attribute(.paragraphStyle, at: index, effectiveRange: nil) as? NSParagraphStyle)?.textBlocks.first is NSTextTableBlock
        }
        let text = view.string as NSString
        let range = text.paragraphRange(for: view.selectedRange())
        return text.substring(with: range).contains("|") && view.string.contains("---")
    }
    public var friendlyState: String {
        if session.busy { return "Working…" }
        switch session.selected?.state {
        case "synced": return "All changes synced"
        case "outbox": return "Saved on this Mac · changes waiting to sync"
        case "conflict", "external-file-conflict": return "Changes need review · both copies kept"
        case "local-only": return "Saved on this Mac"
        default: return session.selected == nil ? "Choose a page or add a new page" : "Saved on this Mac"
        }
    }
    public var visibleStatus: String {
        if session.busy { return "Working…" }
        if session.message == session.selected?.state || session.message.hasPrefix("Saved locally") { return friendlyState }
        return session.message
    }
    public func followSelection() {
        if let note = session.selected { notebook = notebookName(note); section = sectionName(note) }
        else { notebook = notebooks.first ?? "On My Mac"; section = sections.first ?? "Notes" }
    }
    public func selectNotebook(_ value: String) {
        guard !session.busy, finishSectionName(focusTitle: false), session.save() else { return }
        notebook = value; section = sections.first ?? "Notes"
        if let page = pages.first { session.select(page.id) }
    }
    public func selectSection(_ value: String) {
        guard !session.busy, finishSectionName(focusTitle: false), session.save() else { return }
        section = value
        if let page = pages.first { session.select(page.id) }
    }
    public func createPage(notebook newNotebook: String? = nil, section newSection: String? = nil) {
        guard finishSectionName(focusTitle: false) else { return }
        let destination = newNotebook ?? (session.selected?.identity.root == "local" && !notebook.isEmpty ? notebook : "On My Mac")
        let destinationSection = newSection ?? (destination == notebook && !section.isEmpty ? section : "Notes")
        let old = session.selectedID
        session.newLocal()
        guard session.selectedID != old, var note = session.selected else { return }
        note.hierarchy = [destination, destinationSection]
        do {
            note.title = "Untitled Page"
            try session.vault.saveLedger(note); session.replace(note)
            session.edit("")
            followSelection(); mode = .write; markdownVisible = false
            titleFocusRequest += 1
        }
        catch { session.message = error.localizedDescription }
    }
    public func insert(_ value: String, action: String) { mode = .write; editor.insert(value, action: action) }
    public func format(_ title: String) { mode = .write; editor.perform(title) }
}
