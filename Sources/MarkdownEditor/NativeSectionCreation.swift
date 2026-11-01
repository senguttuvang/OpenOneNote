import Foundation

extension NativeShellState {
    /// The section row owns inline naming. Cloud sections POST the final name;
    /// local sections retain the immediate draft behavior.
    public func createSection() {
        guard !session.busy, finishSectionName(focusTitle: false) else { return }
        if isRemoteNotebook {
            let existing = session.sections.map(\.name)
            var number = 1
            while existing.contains(where: { $0.localizedCaseInsensitiveCompare("New Section \(number)") == .orderedSame }) { number += 1 }
            let name = "New Section \(number)"
            namingCloudSection = true; editingSectionID = UUID()
            cloudSectionRoot = session.root; cloudSectionNotebookID = session.notebookID
            editingSectionName = name; sectionNameDraft = name; section = name
            searching = false; search = ""; navigationHidden = false
            return
        }
        let destination = session.selected?.identity.root == "local" ? notebook : "On My Mac"
        let existing = session.notes.filter { notebookName($0) == destination }.map(sectionName)
        var number = 1
        while existing.contains(where: { $0.localizedCaseInsensitiveCompare("New Section \(number)") == .orderedSame }) { number += 1 }
        let name = "New Section \(number)"
        let previous = session.selectedID
        createPage(section: name)
        guard session.selectedID != previous, section == name else { return }
        searching = false; search = ""; navigationHidden = false
        editingSectionID = session.selectedID; editingSectionName = name; sectionNameDraft = name
    }

    @discardableResult public func finishSectionName(focusTitle: Bool = true) -> Bool {
        guard let id = editingSectionID, let original = editingSectionName else { return true }
        guard !session.busy, session.save() else { return false }
        let trimmed = sectionNameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = trimmed.isEmpty ? original : trimmed
        if namingCloudSection {
            guard cloudSectionRoot == session.root, cloudSectionNotebookID == session.notebookID else {
                session.message = "The notebook changed while naming this section. Cancel the name and choose New Section in the intended notebook."
                return false
            }
            guard session.createCloudSection(named: value, completion: { [weak self] confirmed in
                guard let self, confirmed, self.editingSectionID == id else { return }
                self.cancelSectionName(); self.followSelection()
            }) else { return false }
            return false // Navigation waits for the real section/page response.
        }
        do {
            var note = try session.vault.load(id)
            guard note.identity.root == "local", sectionName(note) == original else {
                session.message = "The section changed. Its existing name has been preserved."
                return false
            }
            let destination = notebookName(note)
            guard !session.notes.contains(where: {
                $0.id != id && notebookName($0) == destination && sectionName($0).localizedCaseInsensitiveCompare(value) == .orderedSame
            }) else {
                session.message = "A section with that name already exists. Choose another name."
                return false
            }
            note.hierarchy = [destination, value]
            try session.vault.saveLedger(note); session.replace(note)
            if notebook == destination && section == original { section = value }
            editingSectionID = nil; editingSectionName = nil; sectionNameDraft = ""
            if focusTitle { titleFocusRequest += 1 }
            return true
        } catch { session.message = error.localizedDescription; return false }
    }

    public func cancelSectionName() {
        if namingCloudSection { section = session.sections.first(where: { $0.id == session.sectionID })?.name ?? "" }
        namingCloudSection = false
        cloudSectionRoot = nil; cloudSectionNotebookID = nil
        editingSectionID = nil; editingSectionName = nil; sectionNameDraft = ""
    }
}
