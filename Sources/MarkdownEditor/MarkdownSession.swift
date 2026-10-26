import AppKit
import Foundation
import Observation
import MarkdownNotes
import OneNoteGraph

@MainActor @Observable public final class MarkdownSession {
    public let vault: MarkdownVault
    public var notes: [NoteLedger] = []
    public var selectedID: UUID?
    public var source = ""
    public var preview = NoteDocument(blocks: [])
    public var message = "Local vault ready. Choose a cloud page or a local note."
    public var busy = false
    public var root = "me"
    public var notebooks: [GraphItem] = []
    public var sections: [GraphItem] = []
    public var pages: [GraphItem] = []
    public var notebookID: String?
    public var sectionID: String?
    public var pageID: String?
    public var graph: GraphClient?
    public var signIn: MicrosoftSignIn?
    private var operation: Task<Void, Never>?
    private var refreshLoop: Task<Void, Never>?
    public init(vault: MarkdownVault) throws {
        self.vault = vault; notes = try vault.ledgers().sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }
    public var selected: NoteLedger? { notes.first { $0.id == selectedID } }
    @discardableResult public func save() -> Bool {
        guard let id = selectedID else { return true }
        do {
            var ledger = try vault.load(id)
            try vault.saveOffline(source, ledger: &ledger)
            replace(ledger); message = "Saved locally · pending sync"; return true
        } catch { message = error.localizedDescription; return false }
    }
    public func edit(_ source: String) {
        self.source = source
        do { preview = try MarkdownConversion().parse(source) }
        catch { preview = NoteDocument(blocks: [.element("pre", [:], [.text(source)])], warnings: [error.localizedDescription]) }
        _ = save()
    }
    public func select(_ id: UUID) {
        guard selectedID != id, save() else { return }
        do {
            var ledger = try vault.load(id); try vault.recover(&ledger)
            let text = try vault.markdown(ledger)
            selectedID = id; source = text; replace(ledger)
            preview = (try? MarkdownConversion().parse(text)) ?? NoteDocument(blocks: [.element("pre", [:], [.text(text)])])
            preview.warnings += ledger.baseline.warnings
            message = ledger.state
        } catch { message = error.localizedDescription }
    }
    public func replace(_ ledger: NoteLedger) {
        if let index = notes.firstIndex(where: { $0.id == ledger.id }) { notes[index] = ledger }
        else { notes.append(ledger) }
    }
    public func configure(clientID: String, tenant: String, redirect: String) {
        do {
            let auth = try MicrosoftSignIn(clientID: clientID, tenant: tenant, redirectURI: redirect)
            signIn = auth; graph = GraphClient(authorization: auth); message = "Microsoft client configured. Sign in or load notebooks using the cached account."
        } catch { message = error.localizedDescription }
    }
    public func login(controller: NSViewController) {
        guard let signIn else { message = "Configure the sanctioned Microsoft public client first."; return }
        perform { try await signIn.signIn(presenting: controller); self.message = "Signed in. Load notebooks to verify Notes access." }
    }
    public func loadNotebooks() {
        guard let graph else { message = "Configure Microsoft sign-in first."; return }
        let root = root
        perform {
            self.notebooks = try await graph.list(root: root, path: "notebooks")
            self.sections = []; self.pages = []; self.notebookID = nil; self.sectionID = nil; self.pageID = nil
            self.message = "Choose a notebook."
        }
    }
    public func loadSections() {
        guard let graph, let notebookID else { return }
        let root = root
        perform {
            self.sections = try await graph.sections(root: root, notebookID: notebookID)
            self.pages = []; self.sectionID = nil; self.pageID = nil; self.message = "Choose a section."
        }
    }
    public func loadPages() {
        guard let graph, let sectionID else { return }
        let root = root
        perform { self.pages = try await graph.list(root: root, path: "sections/\(GraphClient.component(sectionID))/pages"); self.pageID = nil; self.message = "Choose a page." }
    }
    public func openPage() {
        guard let graph, let pageID, save() else { return }
        let root = root
        let hierarchy = [notebooks.first(where: { $0.id == notebookID })?.name,
                         sections.first(where: { $0.id == sectionID })?.name].compactMap { $0 }
        let sync = NoteSync(vault: vault, remote: graph)
        perform {
            let identity = PageIdentity(root: root, pageID: pageID, accountKey: try await graph.authorization.identityKey())
            var ledger = try await sync.open(identity); ledger.hierarchy = hierarchy
            try self.vault.saveLedger(ledger); self.replace(ledger); self.select(ledger.id)
            self.message = "Cloud page opened as local Markdown."
        }
    }
    public func sync() {
        guard let graph, let id = selectedID, save() else { return }
        let sync = NoteSync(vault: vault, remote: graph)
        perform {
            let ledger = try await sync.sync(id); self.replace(ledger)
            self.source = try self.vault.markdown(ledger); self.preview = try MarkdownConversion().parse(self.source)
            self.message = "Same-page sync verified by Graph readback."
        }
    }
    public func cancel() { operation?.cancel() }
    public func startBackgroundRefresh() {
        guard refreshLoop == nil else { return }
        refreshLoop = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(120)) } catch { return }
                guard let self, !self.busy, let graph = self.graph, let id = self.selectedID else { continue }
                let sync = NoteSync(vault: self.vault, remote: graph)
                self.perform {
                    let ledger = try await sync.sync(id, allowPush: false)
                    self.replace(ledger)
                    if ledger.state == "synced" {
                        self.source = try self.vault.markdown(ledger)
                        self.preview = try MarkdownConversion().parse(self.source)
                        self.preview.warnings += ledger.baseline.warnings
                    }
                    self.message = ledger.state == "synced" ? "Remote refresh complete." : "Local edits pending explicit sync."
                }
            }
        }
    }
    public func stopBackgroundRefresh() { refreshLoop?.cancel(); refreshLoop = nil }
    public func attachFile() {
        guard selectedID != nil, !busy else { return }
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size <= 20 * 1024 * 1024 else { throw NotesError.invalid("Attachments must be at most 20 MiB") }
            let bytes = try Data(contentsOf: url)
            let ext = url.pathExtension.lowercased()
            let suffix = ["png", "jpg", "jpeg", "gif"].contains(ext) ? (ext == "jpeg" ? "jpg" : ext) : "bin"
            let asset = try vault.storeAsset(bytes, resourceURL: "", extension: suffix)
            let node: NoteNode = suffix == "bin"
                ? .element("object", ["data": asset.path, "data-attachment": url.lastPathComponent, "type": "application/octet-stream"], [])
                : .element("img", ["src": asset.path, "alt": url.lastPathComponent], [])
            edit(source + "\n\n" + MarkdownConversion().markdown(NoteDocument(blocks: [node])))
        } catch { message = error.localizedDescription }
    }
    public func resolve() {
        guard var ledger = selected else { return }
        do {
            try vault.resolve(&ledger, editedMarkdown: source); replace(ledger)
            message = "Resolution saved locally with recovery history. Sync to recheck and update the same page."
        } catch { message = error.localizedDescription }
    }
    private func perform(_ action: @escaping @MainActor () async throws -> Void) {
        guard !busy else { return }
        busy = true
        operation = Task {
            defer { busy = false; operation = nil }
            do { try await action() }
            catch is CancellationError { message = "Cancelled. Local content retained." }
            catch {
                if let id = self.selectedID, let ledger = try? self.vault.load(id) { self.replace(ledger) }
                message = error.localizedDescription
            }
        }
    }
}
