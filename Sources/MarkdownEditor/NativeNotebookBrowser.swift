import AppKit
import SwiftUI
import MarkdownNotes
import OneNoteGraph

@MainActor struct NativeNotebookBrowser: View {
    @Bindable var shell: NativeShellState
    var closeWindow: (() -> Void)? = nil
    @State private var browser = CloudBrowserState()
    @State private var linked: [GraphItem] = []
    @State private var linkedSelection: String?
    @State private var linkedLoading = false
    @State private var linkedError: String?
    @State private var opening = false
    @State private var openingError: String?
    @State private var linkedTask: Task<Void, Never>?
    @State private var openingTask: Task<Void, Never>?
    @State private var generation = UUID()
    @Environment(\.dismiss) private var dismiss
    private var location: String { shell.browserLocation }
    private func close() { if let closeWindow { closeWindow() } else { dismiss() } }
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 24) {
                    NativeAccountAvatar(account: shell.session.account).padding(.top, 24)
                    Text("Open").fontWeight(.semibold)
                    Image(systemName: "folder.fill").font(.title).padding(12).background(.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
                    Spacer()
                }.frame(width: 80).background(.primary.opacity(0.04))
                VStack(alignment: .leading, spacing: 0) {
                    place("Recent Folders", symbol: "clock", id: "recent")
                    Text("On this Mac").font(.caption).foregroundStyle(.secondary).padding(16)
                    place("On My Mac", symbol: "laptopcomputer", id: "local")
                    if let account = shell.session.account {
                        Text("Work or school").font(.caption).foregroundStyle(.secondary).padding(16)
                        place("OneDrive", symbol: "cloud.fill", id: "drive", detail: account.email)
                        place("Sites", symbol: "building.2", id: "sites", detail: account.email)
                        place("Linked notebooks", symbol: "book.closed", id: "linked", detail: account.email)
                    } else {
                        Button("Sign in to open more notebooks…") { shell.showCloud(.storage) }.padding(16)
                    }
                    Spacer()
                    Button("Manage Storage Accounts", systemImage: "cloud.badge.gearshape") { shell.showCloud(.storage) }.buttonStyle(.plain).padding(12).frame(maxWidth: .infinity).background(.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 6)).padding(8)
                }.frame(width: 280).background(.primary.opacity(0.02))
                Divider()
                content.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }.disabled(opening)
            Divider()
            HStack(spacing: 12) {
                if browser.loading || linkedLoading || opening { ProgressView().controlSize(.small); Text(opening ? "Opening…" : "Refreshing…").foregroundStyle(.secondary) }
                else { Button("Refresh", systemImage: "arrow.clockwise") { load() }.disabled(location == "local" || location == "recent") }
                if let error = openingError ?? browser.error ?? linkedError { Text(error).foregroundStyle(.secondary).lineLimit(2); Button("Retry") { load() } }
                Spacer()
                Button("Cancel") { browser.cancel(); linkedTask?.cancel(); openingTask?.cancel(); close() }.keyboardShortcut(.cancelAction)
                Button("Open") { open() }.keyboardShortcut(.defaultAction).disabled(opening || (browser.selection == nil && linkedSelection == nil))
            }.padding(12).frame(minHeight: 48)
        }.frame(minWidth: 960, idealWidth: 1200, maxWidth: 1400, minHeight: 600, idealHeight: 740)
            .task { await shell.session.restoreAccount(); load() }
            .onChange(of: shell.browserLocation) { _, _ in load() }
            .onDisappear { browser.cancel(); linkedTask?.cancel(); openingTask?.cancel() }
    }
    @ViewBuilder private var content: some View {
        if location == "recent" {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Folders").font(.headline).padding(.bottom, 12)
                    if let error = shell.session.recentNotebooksError { Text(error).foregroundStyle(.secondary) }
                    let recents = shell.session.recentNotebooks.filter { $0.accountKey == shell.session.account?.key }
                    ForEach(recents) { recent in
                        Button {
                            openingTask = Task {
                                opening = true; defer { opening = false }
                                if await shell.session.openNotebook(root: recent.root, notebook: GraphItem(id: recent.notebookID, displayName: recent.name)) {
                                    shell.notebook = recent.name; shell.section = shell.session.sections.first?.name ?? ""; close()
                                } else { openingError = "This notebook could not be opened. Try again." }
                            }
                        } label: { Label(recent.name, systemImage: "book.closed.fill").frame(maxWidth: .infinity, alignment: .leading).padding(12) }.buttonStyle(.plain)
                    }
                    if recents.isEmpty { Text("No recent folders. Choose a location to open a notebook.").foregroundStyle(.secondary) }
                }.padding(24)
            }
        } else if location == "local" {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(location == "recent" ? "Recent Folders" : "On My Mac").font(.headline).padding(.bottom, 12)
                    let local = Array(Set(shell.session.notes.filter { $0.identity.root == "local" }.map(shell.notebookName))).sorted()
                    ForEach(local, id: \.self) { notebook in
                        Button { shell.selectNotebook(notebook); close() } label: { Label(notebook, systemImage: "book.closed.fill").frame(maxWidth: .infinity, alignment: .leading).padding(12) }.buttonStyle(.plain)
                    }
                    if local.isEmpty { Text("No notebooks on this Mac.").foregroundStyle(.secondary) }
                }.padding(24)
            }
        } else if location == "linked" {
            VStack(alignment: .leading, spacing: 8) {
                Text("Notebooks").font(.headline).padding(16)
                List(linked, selection: $linkedSelection) { item in Label(item.name, systemImage: "book.closed.fill").tag(item.id).padding(.vertical, 8) }.listStyle(.plain).disabled(linkedLoading)
                if linked.isEmpty && !linkedLoading && linkedError == nil { Text("No notebooks in this location.").foregroundStyle(.secondary).padding(16) }
            }.frame(width: 300)
        } else if shell.session.account?.storageConnected != true {
            VStack(alignment: .leading, spacing: 16) {
                Text("Connect storage").font(.title2)
                Text("Browse your OneDrive folders and SharePoint sites. Your linked notebooks are available without connecting storage.").foregroundStyle(.secondary)
                Button("Connect Storage…") { shell.showCloud(.storage) }
                Button("Open Linked Notebooks") { shell.browserLocation = "linked" }
            }.padding(32)
        } else {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(browser.columns.enumerated()), id: \.element.id) { index, column in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(column.title).font(.caption).foregroundStyle(.secondary).padding(16)
                            ScrollView {
                                LazyVStack(spacing: 4) {
                                    ForEach(column.entries) { entry in
                                        Button {
                                            guard let graph = shell.session.graph else { return }
                                            openingError = nil; browser.select(entry, column: index, using: graph)
                                        } label: {
                                            HStack(spacing: 10) {
                                                Image(systemName: entry.kind == .notebook ? "book.closed.fill" : entry.kind == .site ? "building.2.fill" : "folder.fill").foregroundStyle(entry.kind == .notebook ? .purple : .blue).frame(width: 24)
                                                Text(entry.name).lineLimit(1); Spacer(minLength: 2)
                                                if entry.kind != .notebook { Image(systemName: "chevron.right").font(.caption) }
                                            }.padding(12).background(column.selectedID == entry.id ? Color.purple.opacity(0.5) : .clear, in: RoundedRectangle(cornerRadius: 6))
                                        }.buttonStyle(.plain).accessibilityLabel(entry.name)
                                    }
                                    if column.entries.isEmpty { Text("No folders or notebooks here.").foregroundStyle(.secondary).padding(16) }
                                }.padding(.horizontal, 8)
                            }
                        }.frame(width: 240)
                        Divider()
                    }
                }
            }
        }
    }
    private func place(_ title: String, symbol: String, id: String, detail: String? = nil) -> some View {
        Button { shell.browserLocation = id } label: {
            HStack(spacing: 12) { Image(systemName: symbol).font(.title2).frame(width: 28).foregroundStyle(id == "sites" || id == "drive" ? Color.blue : Color.secondary); VStack(alignment: .leading, spacing: 2) { Text(title).fontWeight(.semibold); if let detail { Text(detail).font(.caption).foregroundStyle(.secondary).lineLimit(1) } }; Spacer() }.padding(12).background(location == id ? Color.primary.opacity(0.12) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
        }.buttonStyle(.plain).padding(.horizontal, 8).padding(.vertical, 2)
    }
    private func load() {
        linkedTask?.cancel(); generation = UUID(); linkedLoading = false
        let request = generation
        openingError = nil; linkedSelection = nil; linkedError = nil
        browser.reset(location: location)
        guard let graph = shell.session.graph else { return }
        if location == "linked" {
            let root = shell.session.microsoftConfiguration?.graphRoot ?? "me"
            linkedLoading = true
            linkedTask = Task {
                do { let items = try await graph.list(root: root, path: "notebooks"); try Task.checkCancellation(); guard generation == request else { return }; linked = items; linkedLoading = false }
                catch { guard generation == request else { return }; linked = []; linkedLoading = false; if !(error is CancellationError) { linkedError = CloudBrowserState.message(error) } }
            }
        } else if location == "sites" || location == "drive", shell.session.account?.storageConnected == true {
            browser.load(location: location, using: graph)
        }
    }
    private func open() {
        guard let graph = shell.session.graph else { return }
        let linkedNotebook = linked.first { $0.id == linkedSelection }
        let entry = browser.selection
        guard linkedNotebook != nil || entry != nil else { return }
        opening = true; openingError = nil
        openingTask = Task {
            defer { opening = false }
            do {
                let notebook: GraphItem
                let root: String
                if let linkedNotebook { notebook = linkedNotebook; root = shell.session.microsoftConfiguration?.graphRoot ?? "me" }
                else if let entry { notebook = try await graph.notebook(for: entry); root = entry.root }
                else { return }
                try Task.checkCancellation()
                if await shell.session.openNotebook(root: root, notebook: notebook) {
                    shell.notebook = notebook.name; shell.section = shell.session.sections.first?.name ?? ""; close()
                } else { openingError = "This notebook could not be opened. Try again." }
            }
            catch { openingError = "This notebook could not be opened. Refresh the location and try again." }
        }
    }
}
