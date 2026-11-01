import SwiftUI
import MarkdownNotes

@MainActor struct NativeSyncPopover: View {
    @Bindable var shell: NativeShellState
    private var note: NoteLedger? { shell.session.selected }
    @State private var creationToRetry: CloudCreationIntent?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sync status").font(.system(size: 12, weight: .semibold))
            Divider()
            if let activity = shell.session.cloudActivity {
                HStack { ProgressView().controlSize(.small); Text(activity) }
                Button("Cancel Sync") { shell.session.cancel() }
            } else if shell.session.refreshingPageID != nil {
                HStack { ProgressView().controlSize(.small); Text("Checking OneNote…") }
            }
            if let failure = shell.session.syncFailure { Text(failure).font(.callout).foregroundStyle(.secondary) }
            if let error = shell.session.creationJournalError { Text(error).font(.callout) }
            ForEach(Array(shell.session.creationReview.enumerated()), id: \.offset) { _, intent in
                if intent.root == shell.session.root && (intent.account == shell.session.remoteAccountKey || intent.account == shell.session.account?.key)
                    && (intent.kind == "section" && intent.parent == shell.session.notebookID || intent.kind == "page" && shell.session.sections.contains(where: { $0.id == intent.parent })) {
                    Text("Creation unconfirmed: \(intent.name)").font(.callout)
                    Button("Review notebook") { shell.session.refreshCurrentNotebook() }.disabled(shell.session.busy)
                    Button("Allow another attempt…") { creationToRetry = intent }.disabled(shell.session.busy)
                }
            }
            if let note {
                HStack {
                    if shell.session.syncingPageID == note.id { ProgressView().controlSize(.small) }
                    Text(title).fontWeight(.semibold)
                }
                if let date = note.lastSyncedAt {
                    TimelineView(.periodic(from: .now, by: 30)) { context in
                        Text(context.date.timeIntervalSince(date) < 60 ? "Page last synced just now" : "Page last synced \(date.formatted(.relative(presentation: .named)))").font(.callout)
                    }
                } else if note.identity.root == "local" { Text("Saved on this Mac").font(.callout) }
                else { Text("This page hasn’t synced yet.").font(.callout) }
                if let error = shell.session.syncErrors[note.id] { Text(error).font(.callout).foregroundStyle(.secondary) }
                if note.identity.root != "local" {
                    Button(shell.session.syncErrors[note.id] == nil ? "Sync Now" : "Retry") { shell.session.sync() }.disabled(!shell.canPerform("Sync page"))
                }
                if note.remoteRecovery != nil || note.externalRecoveryMarkdown != nil {
                    Button("Review changes…") { shell.syncPopover = false; shell.sheet = .recovery }
                }
            } else { Text("Choose a page to see its sync status.") }
            Button("Sync This Notebook") { shell.session.syncNotebooks(all: false) }.disabled(!shell.canPerform("Sync This Notebook"))
            Button("Sync All Notebooks") { shell.session.syncNotebooks(all: true) }.disabled(!shell.canPerform("Sync All Notebooks"))
            Text("All notebooks syncs notebooks opened with this account. Local drafts stay on this Mac.").font(.caption).foregroundStyle(.secondary)
            if let date = shell.session.lastSyncAt { Text("Last successful sync: \(date.formatted(date: .omitted, time: .standard))").font(.caption) }
        }.padding(12).frame(width: 250, alignment: .leading)
            .confirmationDialog("Allow another creation?", isPresented: Binding(get: { creationToRetry != nil }, set: { if !$0 { creationToRetry = nil } })) {
                Button("I checked OneNote; allow another attempt") {
                    if let intent = creationToRetry { shell.session.allowAnotherCreation(intent) }
                    creationToRetry = nil
                }
                Button("Cancel", role: .cancel) { creationToRetry = nil }
            } message: { Text("The previous request may have succeeded. Check the notebook first. Another attempt could create a duplicate.") }
    }
    private var title: String {
        guard let note else { return "" }
        if shell.session.syncingPageID == note.id { return "Syncing…" }
        if shell.session.syncErrors[note.id] != nil { return "Couldn’t sync this page" }
        switch note.state {
        case "conflict", "external-file-conflict": return "Changes need review"
        case "outbox": return "Changes waiting to sync"
        case "offline-or-inaccessible": return "Couldn’t sync this page"
        default: return "Page saved"
        }
    }
}
