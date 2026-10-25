import AppKit
import SwiftUI
import NotebookCore

@MainActor enum PaperPalette {
    static let canvas = Color(nsColor: EditorTheme.background)
    static let navigation = Color(white: 0.14)
    static let ribbon = Color(white: 0.153)
    static let selected = Color(white: 0.23)
    static let secondary = Color(white: 0.68)
    static let accent = Color(red: 0.62, green: 0.20, blue: 0.79)
    static let line = Color.black.opacity(0.55)
}

@MainActor public struct EditorView: View {
    @ObservedObject public var session: NotebookSession
    @StateObject private var formatting = EditorFormatting()
    @State private var tab = "Home"
    @State private var link = "https://"
    public init(session: NotebookSession) { self.session = session }

    public var body: some View {
        GeometryReader { geometry in
            if let notebook = session.notebook {
                VStack(spacing: 0) {
                    ribbon
                    HStack(spacing: 0) {
                        appRail
                        VStack(spacing: 0) {
                            notebookHeader
                            HStack(spacing: 0) {
                                sidebar(notebook).frame(width: geometry.size.width >= 1400 ? 250 : 200)
                                pageList.frame(width: geometry.size.width >= 1400 ? 301 : 220)
                            }
                        }.frame(width: geometry.size.width >= 1400 ? 551 : 420).background(PaperPalette.navigation)
                        pageContent
                    }
                }
            } else {
                ContentUnavailableView("Couldn’t open notebook", systemImage: "exclamationmark.triangle", description: Text(session.errorMessage ?? "The original file has been preserved."))
            }
        }
        .background(PaperPalette.canvas).foregroundStyle(Color(nsColor: EditorTheme.foreground))
        .preferredColorScheme(.dark).tint(PaperPalette.accent)
        .onChange(of: session.selectedPageID) { _, _ in formatting.clear() }
    }

    private var ribbon: some View {
        VStack(spacing: 0) {
            HStack {
                Button { session.undoManager.undo() } label: { Image(systemName: "arrow.uturn.backward") }.help("Undo (⌘Z)")
                Button { session.undoManager.redo() } label: { Image(systemName: "arrow.uturn.forward") }.help("Redo (⇧⌘Z)")
                Spacer()
                Text("OpenOneNote").font(.system(size: 12, weight: .medium))
                Spacer()
                Text(session.status).font(.system(size: 11)).foregroundStyle(PaperPalette.secondary)
                Button { session.saveNow() } label: { Image(systemName: "square.and.arrow.down") }.help("Save (⌘S)").accessibilityLabel("Save Notebook")
            }.padding(.horizontal, 24).frame(height: 36)
            HStack(spacing: 24) {
                ForEach(["Home", "Insert", "Draw", "View"], id: \.self) { title in
                    Button { tab = title } label: {
                        Text(title).font(.system(size: 13, weight: tab == title ? .bold : .medium))
                            .padding(.vertical, 8).overlay(alignment: .bottom) { if tab == title { Capsule().fill(.white).frame(height: 3) } }
                    }
                }
                Spacer()
            }.padding(.horizontal, 12).frame(height: 36)
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    if tab == "Home" { homeTools }
                    if tab == "Insert" {
                        tool("Text Container", "text.badge.plus") { session.addContainer() }
                        tool("Table", "tablecells") { formatting.table() }.disabled(!formatting.available)
                        Divider().frame(height: 54)
                        TextField("Link URL", text: $link).frame(width: 240).textFieldStyle(.roundedBorder)
                        Button("Apply Link") { formatting.link(link) }.disabled(!formatting.available)
                    }
                    if tab == "Draw" { Text("Ink tools are not available in this local editor.").foregroundStyle(PaperPalette.secondary) }
                    if tab == "View" {
                        Text("100% • Document coordinates are preserved when resizing.").foregroundStyle(PaperPalette.secondary)
                        tool("Add Text", "text.badge.plus") { session.addContainer() }
                    }
                }.padding(.horizontal, 16).frame(height: 76)
            }.scrollIndicators(.hidden)
        }
        .buttonStyle(.plain).background(PaperPalette.ribbon)
        .overlay(alignment: .bottom) { PaperPalette.line.frame(height: 1) }
    }

    private var homeTools: some View {
        Group {
            tool("Paste", "doc.on.clipboard") { formatting.perform("paste:") }.disabled(!formatting.available)
            VStack(alignment: .leading, spacing: 7) {
                Button("Cut") { formatting.perform("cut:") }
                Button("Copy") { formatting.perform("copy:") }
            }.disabled(!formatting.available).font(.system(size: 12))
            Divider().frame(height: 60)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Picker("Font", selection: Binding(get: { formatting.fontName }, set: { formatting.font(name: $0) })) {
                        ForEach(Array(Set(["Calibri", "Helvetica", "Arial", "Times New Roman", "Menlo", formatting.fontName])).sorted(), id: \.self) { Text($0).tag($0) }
                    }.labelsHidden().frame(width: 105)
                    Picker("Font Size", selection: Binding(get: { formatting.fontSize }, set: { formatting.font(size: $0) })) {
                        ForEach(Array(Set([10.0, 12, 14, 16, 18, 20, 24, 28, 36, formatting.fontSize])).sorted(), id: \.self) { Text($0.formatted()).tag($0) }
                    }.labelsHidden().frame(width: 58)
                }
                HStack(spacing: 14) {
                    formatButton("Bold", "bold", active: formatting.bold) { formatting.perform("toggleBoldface:") }
                    formatButton("Italic", "italic", active: formatting.italic) { formatting.perform("toggleItalics:") }
                    formatButton("Underline", "underline", active: formatting.underline) { formatting.attribute(.underlineStyle, value: formatting.underline ? 0 : 1, action: "Underline") }
                    formatButton("Strikethrough", "strikethrough") { formatting.attribute(.strikethroughStyle, value: 1, action: "Strikethrough") }
                    formatButton("Highlight", "highlighter") { formatting.attribute(.backgroundColor, value: NSColor.systemYellow.withAlphaComponent(0.4), action: "Highlight") }
                    formatButton("Text Color", "a.underline") { formatting.attribute(.foregroundColor, value: EditorTheme.link, action: "Text Color") }
                }
            }.disabled(!formatting.available)
            Divider().frame(height: 60)
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 18) {
                    formatButton("Bulleted List", "list.bullet") { formatting.list(numbered: false) }
                    formatButton("Numbered List", "list.number") { formatting.list(numbered: true) }
                }
                HStack(spacing: 18) {
                    formatButton("Align Left", "text.alignleft") { formatting.perform("alignLeft:") }
                    formatButton("Align Center", "text.aligncenter") { formatting.perform("alignCenter:") }
                    formatButton("Align Right", "text.alignright") { formatting.perform("alignRight:") }
                }
            }.disabled(!formatting.available)
            Divider().frame(height: 60)
            VStack(alignment: .leading, spacing: 8) {
                Button("Heading 1") { formatting.heading(1) }.font(.system(size: 14, weight: .medium))
                Button("Heading 2") { formatting.heading(2) }.font(.system(size: 12))
            }.foregroundStyle(Color(nsColor: EditorTheme.link)).frame(width: 150, alignment: .leading)
                .padding(10).background(Color.white.opacity(0.08)).disabled(!formatting.available)
            Divider().frame(height: 60)
            tool("Add Text", "text.badge.plus") { session.addContainer() }
        }
    }

    private func tool(_ title: String, _ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { VStack(spacing: 5) { Image(systemName: symbol).font(.system(size: 23)); Text(title).font(.system(size: 11)) } }
            .help(title).accessibilityLabel(title).focusable(false)
    }
    private func formatButton(_ title: String, _ symbol: String, active: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(systemName: symbol).frame(width: 18, height: 20).background(active ? Color.white.opacity(0.2) : .clear) }
            .help(title).accessibilityLabel(title).focusable(false)
    }
    private var appRail: some View {
        VStack(spacing: 26) {
            Image(systemName: "sidebar.left")
            Image(systemName: "books.vertical.fill").foregroundStyle(.purple)
            Spacer()
            Image(systemName: "internaldrive").help("Stored on this Mac")
        }.font(.system(size: 17)).foregroundStyle(PaperPalette.secondary).padding(.vertical, 18).frame(width: 47)
            .background(Color(white: 0.19)).accessibilityLabel("Local notebook")
    }
    private var notebookHeader: some View {
        HStack {
            Image(systemName: "book.closed.fill").foregroundStyle(.blue)
            TextField("Notebook name", text: Binding(get: { session.notebook?.title ?? "" }, set: { session.renameNotebook($0) }))
                .textFieldStyle(.plain).font(.system(size: 14, weight: .semibold)).accessibilityLabel("Notebook name")
            Spacer()
            TextField("Section name", text: Binding(get: { session.selectedSection?.title ?? "" }, set: { session.renameSection($0) }))
                .textFieldStyle(.plain).font(.system(size: 12)).foregroundStyle(PaperPalette.secondary).frame(maxWidth: 150).accessibilityLabel("Section name")
        }.padding(.horizontal, 12).frame(height: 45).overlay(alignment: .bottom) { PaperPalette.line.frame(height: 1) }
    }
    private func sidebar(_ notebook: Notebook) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(notebook.sections.enumerated()), id: \.element.id) { index, section in
                        Button { session.selectSection(section.id) } label: {
                            HStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 3).fill([Color.blue, .yellow, .pink, .green][index % 4]).frame(width: 8, height: 26)
                                Text(section.title).font(.system(size: 14)).lineLimit(1)
                                Spacer(minLength: 4)
                            }.padding(.leading, 13).frame(height: 36).background(section.id == session.selectedSectionID ? PaperPalette.selected : .clear).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
            }
            footer("Add section") { session.addSection() }
        }.overlay(alignment: .trailing) { PaperPalette.line.frame(width: 1) }
    }
    private var pageList: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(session.selectedSection?.pages ?? []) { page in
                        Button { session.selectPage(page.id) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(page.title.isEmpty ? "Untitled page" : page.title).font(.system(size: 14)).lineLimit(1)
                                Text(page.blocks.first?.text ?? "Start writing…").font(.system(size: 12)).foregroundStyle(PaperPalette.secondary).lineLimit(1)
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).frame(height: 56)
                                .background(page.id == session.selectedPageID ? PaperPalette.selected : .clear).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
            }
            footer("Add page") { session.addPage() }
        }.overlay(alignment: .trailing) { PaperPalette.line.frame(width: 1) }
    }
    private func footer(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { Text(title).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color(red: 0.79, green: 0.69, blue: 0.91)).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 20).frame(height: 44) }
            .buttonStyle(.plain).overlay(alignment: .top) { PaperPalette.line.frame(height: 1) }
    }
    private var pageContent: some View {
        VStack(spacing: 0) {
            if let error = session.errorMessage {
                HStack { Text("Couldn’t save: \(error)"); Button("Retry") { session.saveNow() } }.padding(12).foregroundStyle(.red)
            }
            if let page = session.selectedPage {
                HStack {
                    TextField("Page title", text: Binding(get: { session.selectedPage?.title ?? "" }, set: { session.renamePage($0, pageID: page.id) }))
                        .textFieldStyle(.plain).font(.system(size: 24)).accessibilityLabel("Page title")
                        .frame(maxWidth: 420).padding(.bottom, 5).overlay(alignment: .bottom) { Color.gray.frame(height: 1) }
                    Spacer(minLength: 0)
                }.padding(.leading, 48).padding(.top, 22).padding(.bottom, 12)
                ScrollView([.horizontal, .vertical]) {
                    ZStack(alignment: .topLeading) {
                        PaperPalette.canvas
                        ForEach(page.blocks) { block in
                            TextContainerView(session: session, formatting: formatting, pageID: page.id, block: block).id(block.id)
                                .offset(x: block.x, y: block.y)
                        }
                    }.frame(width: max(760, (page.blocks.map { $0.x + $0.width }.max() ?? 0) + 48),
                            height: max(900, (page.blocks.map { $0.y + ($0.height ?? 260) }.max() ?? 0) + 100))
                }
            } else { ContentUnavailableView("Choose a page", systemImage: "doc.text", description: Text("Add a page to start writing.")) }
        }.background(PaperPalette.canvas)
    }
}

@MainActor private struct TextContainerView: View {
    @ObservedObject var session: NotebookSession
    let formatting: EditorFormatting
    let pageID: UUID
    let block: NoteBlock
    @State private var drag: CGSize = .zero
    @State private var resize: CGSize = .zero

    private var editor: RichTextEditor {
        var editor = RichTextEditor(text: block.text, richText: block.richText, undoManager: session.undoManager,
            onChange: { session.editText(pageID: pageID, blockID: block.id, text: $0, richText: $1) }, onError: { session.reportError($0) })
        editor.formatting = formatting
        return editor
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack { Spacer(); Text("····").font(.system(size: 10)); Spacer() }
                .frame(height: 9).background(Color.white.opacity(0.09)).contentShape(Rectangle()).help("Drag to move text container")
                .gesture(DragGesture().onChanged { drag = $0.translation }.onEnded { value in
                    session.setGeometry(pageID: pageID, blockID: block.id, x: block.x + value.translation.width, y: block.y + value.translation.height, width: block.width, height: block.height ?? 260)
                    drag = .zero
                })
            editor
        }.frame(width: max(240, block.width + resize.width), height: max(140, (block.height ?? 260) + resize.height))
            .background(PaperPalette.canvas).overlay(Rectangle().stroke(Color.gray.opacity(0.22), lineWidth: 1))
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "arrow.down.right").font(.system(size: 10)).foregroundStyle(PaperPalette.secondary).padding(5)
                    .contentShape(Rectangle()).help("Drag to resize text container")
                    .gesture(DragGesture().onChanged { resize = $0.translation }.onEnded { value in
                        session.setGeometry(pageID: pageID, blockID: block.id, x: block.x, y: block.y, width: block.width + value.translation.width, height: (block.height ?? 260) + value.translation.height)
                        resize = .zero
                    })
            }.offset(drag)
    }
}
