import SwiftUI
import MarkdownNotes

@MainActor struct NativeSyncPopover: View {
    @Bindable var shell: NativeShellState
    private var note: NoteLedger? { shell.session.selected }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sync status").font(.system(size: 12, weight: .semibold))
            Divider()
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
        }.padding(12).frame(width: 250, alignment: .leading)
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
