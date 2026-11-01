import Foundation
import MarkdownNotes
import OneNoteGraph

extension MarkdownSession {
    /// Sync the selected notebook, or notebooks opened with this account. Local
    /// drafts never join a cloud batch by matching a display name.
    public func syncNotebooks(all: Bool) {
        guard !busy, let graph, save() else { return }
        let currentRoot = root
        let currentID = notebookID
        let currentNotebook = notebooks.first(where: { $0.id == currentID })
        let recents = recentNotebooks
        let selectedID = selectedID
        cloudActivity = "Preparing notebook sync…"; syncFailure = nil
        perform {
            let account = try await graph.authorization.identityKey()
            var targets = all ? recents.filter { $0.accountKey == account } : []
            if let currentID, let currentNotebook {
                guard self.remoteAccountKey == nil || self.remoteAccountKey == account else { throw NotesError.authenticationRequired }
                let current = RecentNotebook(root: currentRoot, notebookID: currentID, name: currentNotebook.name, accountKey: account, openedAt: Date())
                targets.removeAll { $0.id == current.id }; targets.insert(current, at: 0)
            }
            guard !targets.isEmpty else { throw NotesError.invalid("Open a notebook with this Microsoft account before syncing.") }
            let sync = NoteSync(vault: self.vault, remote: graph, diagrams: MermaidRenderer())
            var failures = 0
            for target in targets {
                try Task.checkCancellation()
                guard try await graph.authorization.identityKey() == account else { throw NotesError.authenticationRequired }
                self.cloudActivity = "Syncing \(target.name)…"
                let sections = try await graph.sections(root: target.root, notebookID: target.notebookID)
                let current = target.root == self.root && target.notebookID == self.notebookID
                if current { self.sections = sections }
                for section in sections {
                    let pages = try await graph.list(root: target.root, path: "sections/\(GraphClient.component(section.id))/pages?$select=id,title&$top=100")
                    if current, section.id == self.sectionID { self.pages = pages }
                    for (index, page) in pages.enumerated() {
                        try Task.checkCancellation()
                        self.cloudActivity = "Syncing \(target.name) · \(section.name) · \(index + 1) of \(pages.count)…"
                        var id: UUID?
                        defer { self.syncingPageID = nil }
                        do {
                            var ledger = try await sync.open(PageIdentity(root: target.root, pageID: page.id, accountKey: account))
                            id = ledger.id; self.syncingPageID = ledger.id
                            ledger = try await sync.sync(ledger.id)
                            ledger.hierarchy = [target.name, section.name]
                            ledger.notebookID = target.notebookID; ledger.sectionID = section.id
                            try self.vault.saveLedger(ledger); self.replace(ledger); self.syncErrors[ledger.id] = nil
                            if self.selectedID == selectedID, ledger.id == selectedID { try self.display(ledger) }
                        } catch is CancellationError { throw CancellationError() }
                        catch {
                            failures += 1
                            if let id {
                                self.syncErrors[id] = "Couldn’t sync this page. Your local changes are retained."
                                if let saved = try? self.vault.load(id) { self.replace(saved) }
                            }
                        }
                    }
                }
            }
            if failures > 0 { throw NotesError.invalid("\(failures) page(s) couldn’t sync. Local changes are retained; retry to recheck them.") }
            self.lastSyncAt = Date(); self.message = all ? "Opened notebooks synced." : "Notebook synced."
        }
    }
}
