import AppKit
import SwiftUI
import MarkdownNotes

@MainActor struct NativeAccountSurfaces: View {
    @Bindable var shell: NativeShellState
    let surface: NativeShellSheet
    @State private var clientID = ""
    @State private var tenant = ""
    @State private var redirect = ""
    @State private var name = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(title, systemImage: icon).font(.title2)
                Spacer(); Button("Done") { dismiss() }.keyboardShortcut(.cancelAction)
            }
            Divider()
            switch surface {
            case .account: account
            case .notebooks: notebooks
            case .settings: settings
            case .recovery: recovery
            case .newNotebook, .newSection: creation
            }
        }.padding(24).frame(minWidth: surface == .recovery ? 780 : 540, idealWidth: surface == .recovery ? 900 : 600, minHeight: 260)
            .onAppear {
                if let configuration = shell.session.microsoftConfiguration {
                    clientID = configuration.clientID; tenant = configuration.tenant; redirect = configuration.redirectURI
                }
            }
    }
    private var title: String {
        switch surface { case .account: "Account"; case .notebooks: "Open Notebook"; case .settings: "Preferences"; case .recovery: "Sync and Recovery"; case .newNotebook: "New Notebook"; case .newSection: "New Section" }
    }
    private var icon: String {
        switch surface { case .account: "person.crop.circle"; case .notebooks, .newNotebook: "book.closed"; case .settings: "gearshape"; case .recovery: "arrow.triangle.2.circlepath"; case .newSection: "rectangle.stack" }
    }
    private var account: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connect Microsoft to open your OneNote notebooks.").font(.headline)
            Text("Your notes remain available on this Mac. Signing in opens Microsoft's account window.").foregroundStyle(.secondary)
            HStack {
                Button("Sign In", systemImage: "person.crop.circle.badge.plus") {
                    guard let controller = shell.window?.contentViewController ?? NSApp.keyWindow?.contentViewController else { shell.session.message = "The account window is not available."; return }
                    shell.session.login(controller: controller)
                }.disabled(shell.session.signIn == nil || shell.session.busy)
                Button("Open Notebooks…") { shell.sheet = .notebooks }
                Spacer()
                Button("Advanced Setup…") { shell.sheet = .settings }
            }
            status
        }
    }
    private var notebooks: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !shell.notebooks.isEmpty {
                Text("On this Mac").font(.headline)
                ScrollView { VStack(alignment: .leading, spacing: 8) { ForEach(shell.notebooks, id: \.self) { notebook in
                    Button { shell.selectNotebook(notebook); dismiss() } label: { Label(notebook, systemImage: "book.closed.fill").frame(maxWidth: .infinity, alignment: .leading) }
                } } }.frame(maxHeight: 140)
            }
            Divider()
            HStack { Text("Microsoft OneNote").font(.headline); Spacer(); Button("Refresh notebooks") { shell.session.loadNotebooks() }.disabled(shell.session.graph == nil || shell.session.busy) }
            if shell.session.graph == nil {
                Button("Sign in to open more notebooks…") { shell.sheet = .account }
            } else {
                Form {
                    Picker("Notebook", selection: Binding(get: { shell.session.notebookID }, set: { shell.session.notebookID = $0 })) {
                        Text("Choose a notebook").tag(String?.none)
                        ForEach(shell.session.notebooks) { Text($0.name).tag(Optional($0.id)) }
                    }.onChange(of: shell.session.notebookID) { _, _ in shell.session.loadSections() }
                    Picker("Section", selection: Binding(get: { shell.session.sectionID }, set: { shell.session.sectionID = $0 })) {
                        Text("Choose a section").tag(String?.none)
                        ForEach(shell.session.sections) { Text($0.name).tag(Optional($0.id)) }
                    }.onChange(of: shell.session.sectionID) { _, _ in shell.session.loadPages() }
                    Picker("Page", selection: Binding(get: { shell.session.pageID }, set: { shell.session.pageID = $0 })) {
                        Text("Choose a page").tag(String?.none)
                        ForEach(shell.session.pages) { Text($0.name).tag(Optional($0.id)) }
                    }
                }.disabled(shell.session.busy)
                HStack { Spacer(); Button("Open Page") { shell.session.openPage() }.disabled(shell.session.pageID == nil || shell.session.busy) }
            }
            status
        }
    }
    private var settings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Microsoft · Advanced registration").font(.headline)
            Text("These settings belong to your approved Microsoft public-client registration. Ordinary writing does not require changing them.").foregroundStyle(.secondary)
            Form {
                TextField("Client ID", text: $clientID)
                TextField("Tenant", text: $tenant)
                TextField("Redirect URI", text: $redirect)
                TextField("Notebook location (Graph root)", text: Binding(get: { shell.session.root }, set: { shell.session.root = $0 }))
            }.textFieldStyle(.roundedBorder).disabled(shell.session.busy)
            Button("Apply Registration") { shell.session.configure(clientID: clientID, tenant: tenant, redirect: redirect) }.disabled(shell.session.busy || clientID.isEmpty || redirect.isEmpty)
            status
        }
    }
    private var recovery: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(shell.friendlyState).font(.headline)
            if let note = shell.session.selected {
                Text(note.hierarchy?.joined(separator: " › ") ?? "On this Mac").foregroundStyle(.secondary)
                if let external = note.externalRecoveryMarkdown {
                    comparison([("Your edited source", shell.session.source), ("External file", external)])
                    HStack { Button("Reload External File") { shell.session.resolveExternal(keepEdited: false) }; Button("Keep Edited Source") { shell.session.resolveExternal(keepEdited: true) } }.disabled(shell.session.busy)
                } else if let remote = note.remoteRecovery {
                    comparison([("Last Synced", MarkdownConversion().markdown(note.baseline)), ("Your Source", shell.session.source), ("Remote Copy", MarkdownConversion().markdown(remote))])
                    Button("Use Edited Source as Resolution") { shell.session.resolve() }.disabled(shell.session.busy)
                } else {
                    Text("Local source and recovery history are preserved. Sync updates the same linked OneNote page.").foregroundStyle(.secondary)
                }
            }
            HStack { Button("Sync This Page") { shell.session.sync() }.disabled(!shell.canPerform("Sync page")); if shell.session.busy { Button("Cancel") { shell.session.cancel() } }; Spacer() }
            status
        }
    }
    private func comparison(_ copies: [(String, String)]) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(Array(copies.enumerated()), id: \.offset) { _, copy in
                VStack(alignment: .leading) {
                    Text(copy.0).font(.headline)
                    ScrollView([.horizontal, .vertical]) { Text(copy.1).font(.system(size: 13, design: .monospaced)).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .topLeading).padding(8) }.frame(height: 300).background(.quaternary, in: RoundedRectangle(cornerRadius: 4))
                }.frame(maxWidth: .infinity)
            }
        }
    }
    private var creation: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Create a local \(surface == .newNotebook ? "notebook" : "section"). Existing Microsoft pages can be opened separately.").foregroundStyle(.secondary)
            TextField("Name", text: $name).textFieldStyle(.roundedBorder)
            HStack { Spacer(); Button("Create") {
                let value = name.trimmingCharacters(in: .whitespacesAndNewlines)
                if surface == .newNotebook { shell.createPage(notebook: value, section: "Notes") }
                else { shell.createPage(section: value) }
                dismiss()
            }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || shell.session.busy) }
        }
    }
    private var status: some View {
        HStack(spacing: 8) {
            if shell.session.busy { ProgressView().controlSize(.small) }
            Text(shell.session.message).font(.callout).foregroundStyle(.secondary).textSelection(.enabled)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
