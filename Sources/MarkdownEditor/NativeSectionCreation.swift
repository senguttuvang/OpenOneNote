import Foundation

extension NativeShellState {
    /// Create immediately; the selected section row owns its inline name entry.
    public func createSection() {
        guard !session.busy, finishSectionName(focusTitle: false) else { return }
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
        editingSectionID = nil; editingSectionName = nil; sectionNameDraft = ""
    }
}
