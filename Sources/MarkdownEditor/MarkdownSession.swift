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
    public var microsoftConfiguration: MicrosoftConfiguration?
    public var account: MicrosoftAccount?
    public var accountError: String?
    public var connectedServices: [String] = []
    public var servicesLoading = false
    public var servicesError: String?
    public var remoteNotebookName: String?
    public var syncingPageID: UUID?
    public var syncErrors: [UUID: String] = [:]
    public var recentNotebooks: [RecentNotebook] = []
    public var recentNotebooksError: String?
    private var operation: Task<Void, Never>?
    private var refreshLoop: Task<Void, Never>?
    private var loadedFileHash: String?
    private var refreshPolicy = RemoteRefreshPolicy()
    private var refreshIdentity: UUID?
    private var servicesRequest = UUID()
    public init(vault: MarkdownVault) throws {
        self.vault = vault; notes = try vault.ledgers().sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        let recents = try vault.safeURL(".o2n/config/recent-notebooks.json")
        if FileManager.default.fileExists(atPath: recents.path) {
            do { recentNotebooks = try JSONDecoder().decode([RecentNotebook].self, from: Data(contentsOf: recents)) }
            catch { recentNotebooksError = "Recent folders couldn’t be loaded. Your notes are still available on this Mac." }
        }
        let config = try vault.safeURL(".o2n/config/microsoft-client.json")
        if FileManager.default.fileExists(atPath: config.path) {
            let value = try JSONDecoder().decode(MicrosoftConfiguration.self, from: Data(contentsOf: config))
            root = value.graphRoot ?? "me"
            configure(clientID: value.clientID, tenant: value.tenant, redirect: value.redirectURI, persist: false)
        }
    }
    public var selected: NoteLedger? { notes.first { $0.id == selectedID } }
    public func renameSelected(_ title: String) {
        guard !busy, selected?.identity.root == "local", save(), var note = selected else { return }
        note.title = title.isEmpty ? "Untitled Page" : title
        do { try vault.saveLedger(note); replace(note) }
        catch { message = error.localizedDescription }
    }
    @discardableResult public func save() -> Bool {
        guard let id = selectedID else { return true }
        do {
            var ledger = try vault.load(id)
            if ledger.externalRecoveryMarkdown != nil {
                ledger.pendingMarkdown = source; try vault.saveLedger(ledger); replace(ledger); throw NotesError.conflict
            }
            let disk = try vault.markdown(ledger)
            if disk == source, ledger.state == "synced" {
                loadedFileHash = MarkdownVault.hash(source); return true
            }
            if let loadedFileHash, MarkdownVault.hash(disk) != loadedFileHash, disk != source {
                if MarkdownVault.hash(source) == loadedFileHash { try display(ledger) }
                else {
                    ledger.externalRecoveryMarkdown = disk; ledger.pendingMarkdown = source; ledger.state = "external-file-conflict"
                    try vault.saveLedger(ledger); replace(ledger); throw NotesError.conflict
                }
            }
            try vault.saveOffline(source, ledger: &ledger)
            loadedFileHash = MarkdownVault.hash(source)
            replace(ledger); message = ledger.identity.root == "local" ? "Saved locally · local-only note" : "Saved locally · pending sync"; return true
        } catch { message = error.localizedDescription; return false }
    }
    public func edit(_ source: String) {
        self.source = source
        do { preview = try MarkdownConversion().parse(source) }
        catch { preview = NoteDocument(blocks: [.element("pre", [:], [.text(source)])], warnings: [error.localizedDescription]) }
        preview.warnings += selected?.baseline.warnings ?? []
        _ = save()
    }
    public func select(_ id: UUID) {
        guard !busy, selectedID != id, save() else { return }
        do {
            var ledger = try vault.load(id); try vault.recover(&ledger)
            try display(ledger)
            refreshSelectedPage()
        } catch {
            if let ledger = try? vault.load(id), ledger.externalRecoveryMarkdown != nil { try? display(ledger) }
            message = error.localizedDescription
        }
    }
    private func display(_ ledger: NoteLedger) throws {
        let disk = try vault.markdown(ledger)
        let text = ledger.externalRecoveryMarkdown != nil ? (ledger.pendingMarkdown ?? disk) : disk
        selectedID = ledger.id; source = text; replace(ledger)
        loadedFileHash = MarkdownVault.hash(disk)
        preview = (try? MarkdownConversion().parse(text)) ?? NoteDocument(blocks: [.element("pre", [:], [.text(text)])])
        preview.warnings += ledger.baseline.warnings; message = ledger.state
    }
    public func replace(_ ledger: NoteLedger) {
        if let index = notes.firstIndex(where: { $0.id == ledger.id }) { notes[index] = ledger }
        else { notes.append(ledger) }
    }
    public func configure(clientID: String, tenant: String, redirect: String, persist: Bool = true) {
        servicesRequest = UUID(); servicesLoading = false; connectedServices = []
        account = nil; accountError = nil
        do {
            let value = MicrosoftConfiguration(clientID: clientID, tenant: tenant, redirectURI: redirect, graphRoot: root)
            microsoftConfiguration = value
            let auth = try MicrosoftSignIn(clientID: clientID, tenant: tenant, redirectURI: redirect)
            if persist {
                let directory = try vault.safeURL(".o2n/config")
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                try JSONEncoder().encode(value).write(to: vault.safeURL(".o2n/config/microsoft-client.json"), options: .atomic)
            }
            signIn = auth; graph = GraphClient(authorization: auth); message = "Microsoft client configured. Sign in or load notebooks using the cached account."
        } catch {
            let failure = error as NSError
            let underlying = failure.userInfo[NSUnderlyingErrorKey] as? NSError
            let codes = " [\(failure.domain):\(failure.code)" + (underlying.map { ", \($0.domain):\($0.code)" } ?? "") + "]"
            message = error.localizedDescription + codes
        }
    }
    public func restoreAccount() async {
        guard let signIn else { account = nil; return }
        do { account = try await signIn.account(); accountError = nil; await refreshConnectedServices() }
        catch { account = nil; accountError = "Sign in to connect your Microsoft account." }
    }
    public func refreshConnectedServices() async {
        let request = UUID(); servicesRequest = request
        connectedServices = []; servicesError = nil
        guard let graph, let account else { return }
        servicesLoading = true; defer { if servicesRequest == request { servicesLoading = false } }
        var connected: [String] = []
        var failure: String?
        do {
            guard try await graph.authorization.identityKey() == account.key else { throw NotesError.authenticationRequired }
            if account.storageConnected {
                do { _ = try await graph.oneDrive(); connected.append("OneDrive") }
                catch { failure = "OneDrive couldn’t be reached. Try refreshing its location." }
                do { _ = try await graph.sites(); connected.append("SharePoint") }
                catch { failure = "SharePoint couldn’t be reached. Try refreshing its location." }
            } else {
                let location = microsoftConfiguration?.graphRoot ?? root
                _ = try await graph.list(root: location, path: "notebooks?$top=1")
                connected = [location.hasPrefix("sites/") ? "SharePoint" : location == "me" ? "OneDrive" : "OneNote"]
            }
        } catch { failure = "Your account is signed in, but notebooks couldn’t be reached. Try again." }
        guard servicesRequest == request, self.account?.key == account.key else { return }
        connectedServices = connected; servicesError = failure
    }
    public func signOut() {
        guard !busy, save(), let signIn else { return }
        do {
            try signIn.signOut(); stopBackgroundRefresh(); account = nil; accountError = nil; connectedServices = []
            servicesRequest = UUID(); servicesLoading = false
            remoteNotebookName = nil; notebooks = []; sections = []; pages = []
            notebookID = nil; sectionID = nil; pageID = nil
            message = "Signed out. Notes saved on this Mac are preserved."
        } catch { accountError = "Couldn’t sign out. Your account and notes were preserved." }
    }
    public func login(controller: NSViewController, connectStorage: Bool = false) {
        guard let signIn else { message = "Configure the sanctioned Microsoft public client first."; return }
        perform {
            do {
                try await signIn.signIn(presenting: controller, connectStorage: connectStorage)
                await self.restoreAccount(); self.startBackgroundRefresh(); self.message = "Microsoft account connected."
            } catch {
                self.accountError = "Microsoft couldn’t connect this account. Try again, or ask your organization to allow storage access."
                throw error
            }
        }
    }
    @discardableResult public func openNotebook(root: String, notebook: GraphItem) async -> Bool {
        guard !busy, let graph, save() else { return false }
        busy = true; defer { busy = false }
        do {
            let sections = try await graph.sections(root: root, notebookID: notebook.id)
            let pages: [GraphItem]
            if let first = sections.first {
                pages = try await graph.list(root: root, path: "sections/\(GraphClient.component(first.id))/pages?$select=id,title&$top=100")
            } else { pages = [] }
            try Task.checkCancellation()
            let accountKey = try await graph.authorization.identityKey()
            let recent = RecentNotebook(root: root, notebookID: notebook.id, name: notebook.name, accountKey: accountKey, openedAt: Date())
            let recents = [recent] + self.recentNotebooks.filter { $0.id != recent.id }.prefix(19)
            let directory = try vault.safeURL(".o2n/config")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try JSONEncoder().encode(recents).write(to: vault.safeURL(".o2n/config/recent-notebooks.json"), options: .atomic)
            self.recentNotebooks = recents
            self.root = root; self.notebooks = [notebook]; self.notebookID = notebook.id
            self.sections = sections; self.sectionID = sections.first?.id; self.pages = pages; self.pageID = nil
            self.selectedID = nil; self.source = ""; self.preview = NoteDocument(blocks: [])
            self.remoteNotebookName = notebook.name; self.message = pages.isEmpty ? "No pages in this section." : "Choose a page."
            return true
        } catch {
            self.message = "This notebook could not be opened. Your current notes are preserved."
            return false
        }
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
        perform { self.pages = try await graph.list(root: root, path: "sections/\(GraphClient.component(sectionID))/pages?$select=id,title&$top=100"); self.pageID = nil; self.message = "Choose a page." }
    }
    public func openPage() {
        guard let graph, let pageID, save() else { return }
        let root = root
        let hierarchy = [notebooks.first(where: { $0.id == notebookID })?.name,
                         sections.first(where: { $0.id == sectionID })?.name].compactMap { $0 }
        let sync = NoteSync(vault: vault, remote: graph, diagrams: MermaidRenderer())
        perform {
            let identity = PageIdentity(root: root, pageID: pageID, accountKey: try await graph.authorization.identityKey())
            var ledger = try await sync.open(identity)
            ledger = try await sync.sync(ledger.id, allowPush: false); ledger.hierarchy = hierarchy
            try self.vault.saveLedger(ledger); try self.display(ledger)
            self.syncErrors[ledger.id] = nil; self.message = "Page opened."
        }
    }
    public func sync() {
        guard !busy, let graph, let id = selectedID, selected?.identity.root != "local", save() else { return }
        syncingPageID = id; syncErrors[id] = nil
        let sync = NoteSync(vault: vault, remote: graph, diagrams: MermaidRenderer())
        perform {
            let ledger = try await sync.sync(id); self.replace(ledger)
            guard self.selectedID == id else { return }
            self.source = try self.vault.markdown(ledger); self.preview = try MarkdownConversion().parse(self.source)
            self.preview.warnings += ledger.baseline.warnings
            self.loadedFileHash = MarkdownVault.hash(self.source)
            self.message = "Page saved."
        }
    }
    public func cancel() { operation?.cancel(); signIn?.cancel() }
    public func relink(_ id: UUID) {
        guard !busy else { return }
        if selectedID != id, !save() { return }
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowsMultipleSelection = false
        panel.directoryURL = vault.root; panel.message = "Choose the moved Markdown file inside this vault. Previous recovery content will be retained."
        guard panel.runModal() == .OK, let file = panel.url else { return }
        do {
            let prefix = vault.root.path + "/"
            guard file.standardizedFileURL.path.hasPrefix(prefix) else { throw NotesError.invalid("The chosen file is outside this vault") }
            var ledger = try vault.load(id)
            try vault.relink(&ledger, path: String(file.standardizedFileURL.path.dropFirst(prefix.count)), preservedLocal: selectedID == id ? source : nil)
            replace(ledger); selectedID = id; source = try vault.markdown(ledger)
            loadedFileHash = MarkdownVault.hash(source)
            preview = try MarkdownConversion().parse(source)
            message = "Moved Markdown relinked. Identity and recovery history preserved; sync explicitly when ready."
        } catch { message = error.localizedDescription }
    }
    public func startBackgroundRefresh() {
        guard refreshLoop == nil else { return }
        refreshLoop = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(for: .seconds(5)) } catch { return }
                self?.refreshSelectedPage(forceContent: false)
            }
        }
    }
    public func refreshSelectedPage(forceContent: Bool = true) {
        guard !busy, let graph, let id = selectedID, let selected, selected.identity.root != "local" else { return }
        if refreshIdentity != id { refreshIdentity = id; refreshPolicy.selectedPageChanged() }
        // Focus/resume requests also honor a provider's outstanding Retry-After.
        guard refreshPolicy.canRefresh(now: Date(), force: forceContent) else { return }
        let sync = NoteSync(vault: vault, remote: graph, diagrams: MermaidRenderer())
        syncingPageID = id
        perform {
            do {
                let hint = try await graph.modificationHint(selected.identity)
                let content = self.refreshPolicy.needsContent(hint: hint, now: Date(), force: forceContent)
                var changed = false
                if content {
                    let ledger = try await sync.sync(id, allowPush: false)
                    changed = ledger.remoteHTMLHash != selected.remoteHTMLHash
                    self.replace(ledger)
                    if ledger.state == "synced" { self.syncErrors[id] = nil }
                    if ledger.state == "synced", self.selectedID == id { try self.display(ledger) }
                    self.message = ledger.state == "synced" ? "Remote refresh complete." : "Local edits pending explicit sync."
                }
                self.refreshPolicy.succeeded(hint: hint, contentChecked: content, changed: changed, now: Date())
            } catch {
                self.refreshPolicy.failed(now: Date(), retryAfter: (error as? GraphRetryRequired)?.delay)
                throw error
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
    public func resolveExternal(keepEdited: Bool) {
        guard var ledger = selected, !busy else { return }
        do {
            try vault.resolveExternal(&ledger, editedMarkdown: source, keepEdited: keepEdited)
            try display(ledger); message = "External-file conflict resolved locally. Both prior copies are retained in recovery history."
        } catch { message = error.localizedDescription }
    }
    public func newLocal() {
        guard !busy, save() else { return }
        do { try display(vault.createLocal()); message = "Local Markdown note created. Cloud pages are opened separately through Microsoft connection." }
        catch { message = error.localizedDescription }
    }
    public func openLocal() {
        guard !busy, save() else { return }
        let panel = NSOpenPanel(); panel.canChooseDirectories = false; panel.allowsMultipleSelection = false
        panel.directoryURL = vault.root; panel.message = "Open a UTF-8 Markdown file inside this vault. Its contents will be preserved."
        guard panel.runModal() == .OK, let file = panel.url else { return }
        do {
            let prefix = vault.root.path + "/"
            guard file.standardizedFileURL.path.hasPrefix(prefix) else { throw NotesError.invalid("Choose a file inside the current vault, or launch O2N with --vault for another vault") }
            try display(vault.adoptMarkdown(path: String(file.standardizedFileURL.path.dropFirst(prefix.count))))
        } catch { message = error.localizedDescription }
    }
    private func perform(_ action: @escaping @MainActor () async throws -> Void) {
        guard !busy else { return }
        busy = true
        operation = Task {
            defer { busy = false; operation = nil; syncingPageID = nil }
            do { try await action() }
            catch is CancellationError { message = "Cancelled. Local content retained." }
            catch {
                if let id = syncingPageID { syncErrors[id] = "We couldn’t sync this page. Your changes are saved on this Mac." }
                if let id = self.selectedID, let ledger = try? self.vault.load(id) { self.replace(ledger) }
                message = error.localizedDescription
            }
        }
    }
}
