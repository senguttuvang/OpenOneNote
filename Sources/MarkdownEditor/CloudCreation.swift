import Foundation
import MarkdownNotes
import OneNoteGraph

extension MarkdownSession {
    public func refreshCurrentNotebook() {
        guard !busy, let notebookID, let notebook = notebooks.first(where: { $0.id == notebookID }) else { return }
        let root = root
        Task { _ = await openNotebook(root: root, notebook: notebook) }
    }
    /// Called only after the user checks OneNote and confirms the duplicate risk.
    public func allowAnotherCreation(_ intent: CloudCreationIntent) {
        guard !busy, let graph, intent.createdID == nil else { return }
        perform {
            guard try await graph.authorization.identityKey() == intent.account else { throw NotesError.authenticationRequired }
            var intents = try self.vault.creationIntents()
            intents.removeAll { $0 == intent }
            try self.vault.storeCreationIntents(intents)
            self.message = "Another creation is allowed. Choose New Section or Add Page when ready."
        }
    }
    private func createOnce(graph: GraphClient, root: String, parent: String, kind: String, name: String,
                            path: String, body: Data, contentType: String = "application/json") async throws -> GraphItem {
        let account = try await graph.authorization.identityKey()
        guard remoteAccountKey == nil || remoteAccountKey == account else { throw NotesError.authenticationRequired }
        if let selected, selected.identity.root != "local", let key = selected.identity.accountKey {
            guard key == account else { throw NotesError.authenticationRequired }
        }
        var intents = try vault.creationIntents()
        if let pending = intents.first(where: { $0.account == account && $0.root == root && $0.parent == parent && $0.kind == kind && ($0.name.localizedCaseInsensitiveCompare(name) == .orderedSame || kind == "page") }) {
            if let id = pending.createdID {
                // A confirmed remote object is reopened, never recreated.
                let data = try await graph.request(graph.url(root: root, path: "\(kind == "page" ? "pages" : "sections")/\(GraphClient.component(id))"))
                let item = try JSONDecoder().decode(GraphItem.self, from: data)
                guard item.id == id else { throw NotesError.invalid("Created object identity mismatch") }
                return item
            }
            throw NotesError.invalid("The previous creation may have reached OneNote. Refresh this notebook and open the existing \(kind) before trying again. No duplicate was sent.")
        }
        let index = intents.count
        intents.append(CloudCreationIntent(account: account, root: root, parent: parent, kind: kind, name: name))
        try Task.checkCancellation()
        try vault.storeCreationIntents(intents)
        let item: GraphItem
        do {
            let data = try await graph.request(graph.url(root: root, path: path), method: "POST", body: body, contentType: contentType)
            item = try JSONDecoder().decode(GraphItem.self, from: data)
            _ = try GraphClient.component(item.id)
        } catch {
            let status: Int?
            if let failure = error as? GraphServiceFailure { status = failure.status }
            else if case .http(let code) = error as? NotesError { status = code }
            else { status = nil }
            let offline = (error as? URLError).map { [.notConnectedToInternet, .cannotFindHost, .cannotConnectToHost].contains($0.code) } ?? false
            if offline || error as? NotesError == .authenticationRequired || status.map({ [400, 401, 403, 404, 409, 422, 429].contains($0) }) == true {
                // These failures establish that this POST did not create an object.
                intents.remove(at: index); try vault.storeCreationIntents(intents)
                throw error
            }
            // Even cancellation can race an accepted server write. Keep the intent.
            if error is CancellationError { throw error }
            throw NotesError.invalid("Creation wasn’t confirmed. Refresh the notebook before retrying; your notes are preserved. No automatic duplicate will be sent.")
        }
        intents[index].createdID = item.id
        try vault.storeCreationIntents(intents)
        return item
    }
    private func completeCreation(root: String, parent: String, kind: String, id: String) throws {
        var intents = try vault.creationIntents()
        intents.removeAll { $0.root == root && $0.parent == parent && $0.kind == kind && $0.createdID == id }
        try vault.storeCreationIntents(intents)
    }
    @discardableResult public func createCloudSection(named name: String, completion: (@MainActor (Bool) -> Void)? = nil) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !busy, save(), let graph, let notebookID,
              let notebook = notebooks.first(where: { $0.id == notebookID }) else {
            message = "Open this notebook from Microsoft notebooks before adding a section."
            return false
        }
        guard !name.isEmpty, name.count <= 50, !name.contains(where: { "?*/:<>|&#'\"%~".contains($0) || $0.isNewline }),
              !sections.contains(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) else {
            message = "Choose a unique section name of 1–50 characters without ? * / : < > | & # quotes % or ~."
            return false
        }
        if let selected, selected.identity.root != "local",
           selected.identity.root != root || (selected.notebookID != nil && selected.notebookID != notebookID) {
            message = "Open the intended cloud notebook before adding a section."
            return false
        }
        let root = root
        cloudActivity = "Creating section…"; syncFailure = nil
        perform {
            var confirmed = false
            defer { completion?(confirmed) }
            let item = try await self.createOnce(graph: graph, root: root, parent: notebookID, kind: "section", name: name,
                path: "notebooks/\(GraphClient.component(notebookID))/sections", body: JSONEncoder().encode(["displayName": name]))
            confirmed = true
            if !self.sections.contains(where: { $0.id == item.id }) { self.sections.append(item) }
            self.sectionID = item.id; self.pages = []; self.pageID = nil
            self.selectedID = nil; self.source = ""; self.preview = NoteDocument(blocks: [])
            try self.completeCreation(root: root, parent: notebookID, kind: "section", id: item.id)
            self.cloudActivity = "Creating page…"
            try Task.checkCancellation()
            try await self.createCloudPage(graph: graph, root: root, notebook: notebook, section: item)
            self.message = "Section and page created in OneNote."
        }
        return true
    }
    func createCloudPage(graph: GraphClient, root: String, notebook: GraphItem, section: GraphItem) async throws {
        cloudActivity = "Creating page…"; syncFailure = nil
        let accountKey = try await graph.authorization.identityKey()
        let html = "<!DOCTYPE html><html><head><title>Untitled Page</title></head><body><p></p></body></html>"
        let item = try await createOnce(graph: graph, root: root, parent: section.id, kind: "page", name: "Untitled Page",
            path: "sections/\(GraphClient.component(section.id))/pages", body: Data(html.utf8), contentType: "text/html")
        if !pages.contains(where: { $0.id == item.id }) { pages.append(item) }
        pageID = item.id
        let sync = NoteSync(vault: vault, remote: graph, diagrams: MermaidRenderer())
        var ledger = try await sync.open(PageIdentity(root: root, pageID: item.id, accountKey: accountKey))
        ledger.hierarchy = [notebook.name, section.name]
        ledger.notebookID = notebook.id; ledger.sectionID = section.id
        try vault.saveLedger(ledger); try display(ledger)
        try completeCreation(root: root, parent: section.id, kind: "page", id: item.id)
    }
}
