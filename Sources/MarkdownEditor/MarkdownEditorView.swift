import AppKit
import SwiftUI
import MarkdownNotes

public struct MarkdownEditorView: View {
    @Bindable private var session: MarkdownSession
    @State private var clientID = ""
    @State private var tenant = "common"
    @State private var redirect = ""
    @State private var showConnection = false
    public init(session: MarkdownSession) { self.session = session }
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "doc.richtext").foregroundStyle(.purple)
                Text("O2N").font(.headline)
                Text("Markdown workspace").foregroundStyle(.secondary)
                Spacer()
                Button("Microsoft connection", systemImage: "person.crop.circle") { showConnection.toggle() }
                Button("Save locally", systemImage: "square.and.arrow.down") { session.save() }.keyboardShortcut("s")
                Button("Attach file", systemImage: "paperclip") { session.attachFile() }.disabled(session.selectedID == nil || session.busy)
                Button("Sync page", systemImage: "arrow.triangle.2.circlepath") { session.sync() }
                    .disabled(session.selectedID == nil || session.graph == nil || session.busy)
                if session.busy { ProgressView().controlSize(.small); Button("Cancel") { session.cancel() } }
            }.padding(16)
            Divider()
            if showConnection { connectionPanel; Divider() }
            HSplitView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("LOCAL NOTES").font(.caption.weight(.semibold)).foregroundStyle(.secondary).padding(16)
                    if session.notes.isEmpty {
                        ContentUnavailableView("Open a cloud page", systemImage: "book.closed", description: Text("Connect Microsoft, then choose an existing notebook, section and page."))
                    } else {
                        List(session.notes) { note in
                            Button { session.select(note.id) } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(note.title).font(.body).lineLimit(2)
                                    if let hierarchy = note.hierarchy, !hierarchy.isEmpty {
                                        Text(hierarchy.joined(separator: " / ")).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                    }
                                    Text(note.state).font(.caption).foregroundStyle(.secondary)
                                }.padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .leading)
                            }.buttonStyle(.plain)
                                .listRowBackground(session.selectedID == note.id ? Color.purple.opacity(0.2) : Color.clear)
                        }
                    }
                    Spacer(minLength: 0)
                    Text("Plain .md + local assets").font(.caption).foregroundStyle(.secondary).padding(16)
                }.frame(minWidth: 200, idealWidth: 240, maxWidth: 300)
                VStack(alignment: .leading, spacing: 0) {
                    Text(session.selected?.title ?? "Choose a note").font(.title2.weight(.semibold)).padding(20)
                    Divider()
                    if let selected = session.selected, let recovery = selected.remoteRecovery {
                        DisclosureGroup("Conflict recovery · compare before resolving") {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text("Last synced baseline").font(.headline)
                                    Text(MarkdownConversion().markdown(selected.baseline)).textSelection(.enabled)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                VStack(alignment: .leading) {
                                    Text("Current remote copy").font(.headline)
                                    Text(MarkdownConversion().markdown(recovery)).textSelection(.enabled)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                            }.font(.system(size: 14)).frame(maxHeight: 160)
                            Button("Use edited source as resolution") { session.resolve() }.disabled(session.busy)
                        }.padding(16)
                        Divider()
                    }
                    HSplitView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Markdown source").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                            MarkdownSourceEditor(source: session.source, identity: session.selectedID, onChange: session.edit)
                                .font(.system(size: 16, design: .monospaced)).scrollContentBackground(.hidden)
                                .accessibilityLabel("Markdown source")
                                .disabled(session.selectedID == nil || session.busy)
                        }.padding(16).frame(minWidth: 260)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reading preview").font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(Array(session.preview.blocks.enumerated()), id: \.offset) { _, node in
                                        MarkdownBlockView(node: node, vault: session.vault)
                                    }
                                    ForEach(session.preview.warnings, id: \.self) { Text($0).font(.callout).foregroundStyle(.orange) }
                                }.frame(maxWidth: 720, alignment: .leading).padding(.vertical, 8)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }.padding(16).frame(minWidth: 260)
                    }
                }.frame(minWidth: 560)
            }
            Divider()
            Text(session.message).font(.callout).textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 16).padding(.vertical, 10)
        }.frame(minWidth: 900, minHeight: 600).background(Color(nsColor: .windowBackgroundColor)).tint(.purple)
    }
    private var connectionPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Use your sanctioned Microsoft public-client registration. Credentials remain in MSAL’s Keychain cache.").font(.callout)
            HStack {
                TextField("Client ID", text: $clientID).accessibilityLabel("Microsoft client ID")
                TextField("Tenant or common", text: $tenant).accessibilityLabel("Microsoft tenant")
                TextField("Registered redirect URI", text: $redirect).accessibilityLabel("Microsoft redirect URI")
                Button("Configure") { session.configure(clientID: clientID, tenant: tenant, redirect: redirect) }
                Button("Sign in") {
                    if let controller = NSApp.keyWindow?.contentViewController { session.login(controller: controller) }
                    else { session.message = "Sign-in presentation is unavailable in this window." }
                }.disabled(session.signIn == nil || session.busy)
            }
            HStack {
                TextField("Graph root: me or sites/id", text: $session.root).frame(maxWidth: 240)
                Button("Load notebooks") { session.loadNotebooks() }.disabled(session.graph == nil || session.busy)
                Picker("Notebook", selection: $session.notebookID) {
                    Text("Choose").tag(String?.none)
                    ForEach(session.notebooks) { Text($0.name).tag(Optional($0.id)) }
                }.onChange(of: session.notebookID) { _, _ in session.loadSections() }
                Picker("Section", selection: $session.sectionID) {
                    Text("Choose").tag(String?.none)
                    ForEach(session.sections) { Text($0.name).tag(Optional($0.id)) }
                }.onChange(of: session.sectionID) { _, _ in session.loadPages() }
                Picker("Page", selection: $session.pageID) {
                    Text("Choose").tag(String?.none)
                    ForEach(session.pages) { Text($0.name).tag(Optional($0.id)) }
                }
                Button("Open page") { session.openPage() }.disabled(session.pageID == nil || session.busy)
            }
        }.textFieldStyle(.roundedBorder).padding(16).disabled(session.busy)
    }
}

private struct MarkdownBlockView: View {
    let node: NoteNode
    let vault: MarkdownVault
    var body: some View {
        block(node)
    }
    private func inline(_ node: NoteNode) -> Text {
        switch node {
        case .text(let value): return Text(value)
        case .element(let tag, let attrs, let children):
            let text = children.reduce(Text("")) { $0 + inline($1) }
            switch tag {
            case "strong": return text.bold()
            case "em": return text.italic()
            case "s": return text.strikethrough()
            case "code": return Text(node.text).monospaced()
            case "br": return Text("\n")
            case "a":
                var attributed = AttributedString(node.text)
                if let href = attrs["href"], MarkdownConversion.safeLink(href) { attributed.link = URL(string: href) }
                return Text(attributed)
            default: return text
            }
        }
    }
    private func block(_ node: NoteNode) -> AnyView {
        guard case .element(let tag, let attrs, let children) = node else { return AnyView(inline(node).textSelection(.enabled)) }
        if tag == "img", let source = attrs["src"], let data = try? vault.asset(source), let image = NSImage(data: data) {
            return AnyView(Image(nsImage: image).resizable().scaledToFit().accessibilityLabel(attrs["alt"] ?? "Note image"))
        }
        if tag == "object", let path = attrs["data"], let url = try? vault.safeURL(path) {
            return AnyView(Link(destination: url) { Label(attrs["data-attachment"] ?? "Attachment", systemImage: "paperclip") })
        }
        if tag == "p", children.contains(where: { child in
            if case .element(let childTag, _, _) = child { return childTag == "img" || childTag == "object" }
            return false
        }) {
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in block(child) }
            })
        }
        if tag == "pre" { return AnyView(Text(node.text).font(.system(size: 15, design: .monospaced)).textSelection(.enabled).padding(12).frame(maxWidth: .infinity, alignment: .leading).background(.quaternary, in: RoundedRectangle(cornerRadius: 8))) }
        if ["ul", "ol", "li", "blockquote", "table", "tbody", "tr", "div"].contains(tag) {
            if tag == "tr" {
                return AnyView(HStack(alignment: .top) { ForEach(Array(children.enumerated()), id: \.offset) { _, child in block(child).frame(maxWidth: .infinity, alignment: .leading) } }.padding(8).overlay(Rectangle().stroke(.separator, lineWidth: 1)))
            }
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    HStack(alignment: .top, spacing: 10) {
                        if tag == "ul" { Image(systemName: "circle.fill").font(.system(size: 5)).padding(.top, 8) }
                        if tag == "ol" { Text("\((Int(attrs["start"] ?? "1") ?? 1) + index).") }
                        block(child)
                    }
                }
            })
        }
        let font: Font = tag == "h1" ? .largeTitle.weight(.bold) : tag == "h2" ? .title2.weight(.semibold) : tag.hasPrefix("h") && tag != "hr" ? .title3.weight(.semibold) : .system(size: 18)
        if tag == "hr" { return AnyView(Divider()) }
        return AnyView(inline(node).font(font).lineSpacing(4).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading))
    }
}
