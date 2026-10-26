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
    private var operation: Task<Void, Never>?
    private var refreshLoop: Task<Void, Never>?
    private var loadedFileHash: String?
    public init(vault: MarkdownVault) throws {
        self.vault = vault; notes = try vault.ledgers().sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        let config = try vault.safeURL(".o2n/config/microsoft-client.json")
        if FileManager.default.fileExists(atPath: config.path) {
            let value = try JSONDecoder().decode(MicrosoftConfiguration.self, from: Data(contentsOf: config))
            configure(clientID: value.clientID, tenant: value.tenant, redirect: value.redirectURI, persist: false)
        }
    }
    public var selected: NoteLedger? { notes.first { $0.id == selectedID } }
    @discardableResult public func save() -> Bool {
        guard let id = selectedID else { return true }
        do {
            var ledger = try vault.load(id)
            if ledger.externalRecoveryMarkdown != nil {
                ledger.pendingMarkdown = source; try vault.saveLedger(ledger); replace(ledger); throw NotesError.conflict
            }
            let disk = try vault.markdown(ledger)
            if let loadedFileHash, MarkdownVault.hash(disk) != loadedFileHash, disk != source {
                if MarkdownVault.hash(source) == loadedFileHash { try display(ledger) }
                else {
                    ledger.externalRecoveryMarkdown = disk; ledger.pendingMarkdown = source; ledger.state = "external-file-conflict"
                    try vault.saveLedger(ledger); replace(ledger); throw NotesError.conflict
                }
            }
            if ledger.identity.root == "local", let heading = preview.blocks.first, case .element("h1", _, _) = heading, !heading.text.isEmpty {
                ledger.title = heading.text
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
        do {
            let value = MicrosoftConfiguration(clientID: clientID, tenant: tenant, redirectURI: redirect)
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
            message = ((failure.userInfo["MSALErrorDescriptionKey"] as? String) ?? error.localizedDescription) + codes
        }
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
        let sync = NoteSync(vault: vault, remote: graph, diagrams: MermaidRenderer())
        perform {
            let identity = PageIdentity(root: root, pageID: pageID, accountKey: try await graph.authorization.identityKey())
            var ledger = try await sync.open(identity); ledger.hierarchy = hierarchy
            try self.vault.saveLedger(ledger); try self.display(ledger)
            self.message = "Cloud page opened as local Markdown."
        }
    }
    public func sync() {
        guard let graph, let id = selectedID, selected?.identity.root != "local", save() else { return }
        let sync = NoteSync(vault: vault, remote: graph, diagrams: MermaidRenderer())
        perform {
            let ledger = try await sync.sync(id); self.replace(ledger)
            guard self.selectedID == id else { return }
            self.source = try self.vault.markdown(ledger); self.preview = try MarkdownConversion().parse(self.source)
            self.preview.warnings += ledger.baseline.warnings
            self.loadedFileHash = MarkdownVault.hash(self.source)
            self.message = "Same-page sync verified by Graph readback."
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
                do { try await Task.sleep(for: .seconds(120)) } catch { return }
                guard let self, !self.busy, let graph = self.graph, let id = self.selectedID, self.selected?.identity.root != "local" else { continue }
                let sync = NoteSync(vault: self.vault, remote: graph, diagrams: MermaidRenderer())
                self.perform {
                    let ledger = try await sync.sync(id, allowPush: false)
                    self.replace(ledger)
                    if ledger.state == "synced", self.selectedID == id {
                        self.source = try self.vault.markdown(ledger)
                        self.loadedFileHash = MarkdownVault.hash(self.source)
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
