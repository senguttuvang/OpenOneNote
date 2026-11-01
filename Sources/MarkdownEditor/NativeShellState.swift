import AppKit
import Observation
import MarkdownNotes

public enum MarkdownEditorMode: String, CaseIterable, Sendable { case write = "Write", split = "Split", read = "Read" }
public enum NativeSearchScope { case section, notebook, all }
public enum NativeShellSheet: String, Identifiable { case account, storage, notebooks, settings, recovery, newNotebook; public var id: String { rawValue } }

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
    public var namingCloudSection = false
    var cloudSectionRoot: String?
    var cloudSectionNotebookID: String?
    public var sheet: NativeShellSheet?
    public var accountPopover = false
    public var syncPopover = false
    public var browserLocation = "recent"
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
    @ObservationIgnored private var cloudWindows: NativeCloudWindows?
    public func showCloud(_ surface: NativeShellSheet) {
        if cloudWindows == nil { cloudWindows = NativeCloudWindows(shell: self) }
        cloudWindows?.present(surface)
    }
    public init(session: MarkdownSession) { self.session = session; followSelection() }
    public func notebookName(_ note: NoteLedger) -> String {
        let name = note.hierarchy?.first ?? (note.identity.root == "local" ? "On My Mac" : "OneNote")
        // A local draft's saved label is not a remote notebook identity.
        let cloudNames = session.recentNotebooks.map(\.name) + [session.remoteNotebookName].compactMap { $0 }
        return note.identity.root == "local" && cloudNames.contains(name) ? name + " (on this Mac)" : name
    }
    public func sectionName(_ note: NoteLedger) -> String { (note.hierarchy?.count ?? 0) > 1 ? note.hierarchy!.dropFirst().joined(separator: " / ") : "Notes" }
    public var notebooks: [String] { Array(Set(session.notes.map(notebookName) + [session.remoteNotebookName].compactMap { $0 })).sorted { $0.localizedStandardCompare($1) == .orderedAscending } }
    public var isRemoteNotebook: Bool { session.remoteNotebookName != nil && notebook == session.remoteNotebookName }
    public var sections: [String] {
        if isRemoteNotebook { return session.sections.map(\.name) + (namingCloudSection ? [editingSectionName].compactMap { $0 } : []) }
        return Array(Set(session.notes.filter { notebookName($0) == notebook }.map(sectionName))).sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    }
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
        if let activity = session.cloudActivity { return activity }
        if session.refreshingPageID != nil { return "Checking OneNote…" }
        if session.busy { return "Working…" }
        switch session.selected?.state {
        case "synced": return "All changes synced"
        case "outbox": return "Saved on this Mac · changes waiting to sync"
        case "conflict", "external-file-conflict": return "Changes need review · both copies kept"
        case "local-only": return "Saved on this Mac"
        default: return session.selected == nil ? "Choose a page or add a new page" : "Saved on this Mac"
        }
    }
    public var syncStatusSymbol: String {
        if session.syncFailure != nil || session.selectedID.flatMap({ session.syncErrors[$0] }) != nil { return "exclamationmark.icloud" }
        guard let note = session.selected else { return "icloud" }
        if note.identity.root == "local" { return "internaldrive" }
        switch note.state {
        case "synced": return "checkmark.icloud"
        case "outbox": return "icloud.and.arrow.up"
        case "conflict", "external-file-conflict", "offline-or-inaccessible": return "exclamationmark.icloud"
        default: return "icloud"
        }
    }
    public var visibleStatus: String {
        if session.cloudActivity != nil || session.refreshingPageID != nil { return friendlyState }
        if let failure = session.syncFailure { return failure }
        if session.busy { return "Working…" }
        if let id = session.selectedID, let error = session.syncErrors[id] { return error }
        if session.message.hasPrefix("Microsoft client configured.") { return session.selected == nil ? "Ready" : friendlyState }
        if session.message == session.selected?.state || session.message.hasPrefix("Saved locally") { return friendlyState }
        return session.message
    }
    public func followSelection() {
        if let note = session.selected { notebook = notebookName(note); section = sectionName(note) }
        else {
            notebook = session.remoteNotebookName ?? notebooks.first ?? "On My Mac"
            section = session.sections.first(where: { $0.id == session.sectionID })?.name ?? sections.first ?? "Notes"
        }
    }
    public func selectNotebook(_ value: String) {
        guard !session.busy, finishSectionName(focusTitle: false), session.save() else { return }
        notebook = value; section = sections.first ?? "Notes"
        if isRemoteNotebook {
            session.selectedID = nil; session.source = ""
            session.sectionID = session.sections.first?.id; session.loadPages(); return
        }
        if let page = pages.first { session.select(page.id) }
    }
    public func selectSection(_ value: String) {
        guard !session.busy, finishSectionName(focusTitle: false), session.save() else { return }
        guard value != section else { return }
        section = value
        if isRemoteNotebook {
            session.sectionID = session.sections.first(where: { $0.name == value })?.id
            session.loadPages(); return
        }
        if let page = pages.first { session.select(page.id) }
    }
    public func createPage(notebook newNotebook: String? = nil, section newSection: String? = nil) {
        guard finishSectionName(focusTitle: false) else { return }
        if newNotebook == nil, newSection == nil,
           isRemoteNotebook || (session.selected?.identity.root != "local" && session.selected.map(notebookName) == notebook) {
            session.createCloudPage(); mode = .write; markdownVisible = false
            return
        }
        let destination = newNotebook ?? (!notebook.isEmpty ? notebook : "On My Mac")
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
