import AppKit
import SwiftUI
import NotebookCore

@MainActor enum PaperPalette {
    static let canvas = Color(nsColor: EditorTheme.background)
    static let navigation = Color(white: 0.14)
    static let ribbon = Color(white: 0.153)
    static let selected = Color(white: 0.23)
    static let secondary = Color(white: 0.68)
    static let accent = Color(red: 0.57, green: 0.17, blue: 0.73)
    static let line = Color.black.opacity(0.55)
}

@MainActor public struct EditorView: View {
    @ObservedObject public var session: NotebookSession
    @StateObject private var commands: EditorCommands
    public init(session: NotebookSession, commands: EditorCommands? = nil) {
        self.session = session
        _commands = StateObject(wrappedValue: commands ?? EditorCommands(session: session))
    }
    private var canvas: Color { commands.lightCanvas ? .white : PaperPalette.canvas }
    public var body: some View {
        GeometryReader { geometry in
            if let notebook = session.notebook {
                VStack(spacing: 0) {
                    RibbonView(commands: commands)
                    HStack(spacing: 0) {
                        appRail
                        if !commands.navigationHidden {
                            VStack(spacing: 0) {
                                notebookHeader
                                if commands.searching { searchField }
                                HStack(spacing: 0) {
                                    sidebar(notebook).frame(width: (geometry.size.width >= 1400 ? 250 : 200) + commands.navigationAdjustment)
                                    pageList.frame(width: geometry.size.width >= 1400 ? 301 : 220)
                                }
                            }.frame(width: (geometry.size.width >= 1400 ? 551 : 420) + commands.navigationAdjustment).background(PaperPalette.navigation)
                        }
                        pageContent
                    }
                }.onAppear { updateViewport(geometry.size.width) }
                    .onChange(of: geometry.size.width) { _, width in updateViewport(width) }
                    .onChange(of: commands.navigationHidden) { _, _ in updateViewport(geometry.size.width) }
                    .onChange(of: commands.navigationAdjustment) { _, _ in updateViewport(geometry.size.width) }
            } else {
                ContentUnavailableView("Couldn’t open notebook", systemImage: "exclamationmark.triangle", description: Text(session.errorMessage ?? "The original file has been preserved."))
            }
        }.background(canvas).foregroundStyle(Color(nsColor: EditorTheme.foreground)).preferredColorScheme(.dark).tint(PaperPalette.accent)
            .onChange(of: session.selectedPageID) { _, _ in commands.formatting.clear() }
    }
    private func updateViewport(_ width: Double) {
        commands.viewportWidth = max(240, width - 47 - (commands.navigationHidden ? 0 : (width >= 1400 ? 551 : 420) + commands.navigationAdjustment))
    }
    private var appRail: some View {
        VStack(spacing: 0) {
            Button { commands.navigationHidden.toggle() } label: { Image(systemName: "rectangle.righthalf.inset.filled").frame(width: 47, height: 45) }.help("Hide Section and Page Lists").accessibilityLabel("Hide Section and Page Lists")
            Button { commands.searching.toggle(); commands.navigationHidden = false } label: { Image(systemName: "magnifyingglass").foregroundStyle(.pink).frame(width: 47, height: 45) }.help("Search").accessibilityLabel("Search")
            Button { commands.navigationHidden = false } label: { Image(systemName: "book.closed.fill").foregroundStyle(.purple).frame(width: 47, height: 45).overlay(alignment: .leading) { Color.purple.opacity(0.6).frame(width: 3) } }.help("Notebooks").accessibilityLabel("Notebooks")
            Button {} label: { Image(systemName: "clock").frame(width: 47, height: 45) }.disabled(true).help("Recent Notes • edit history is not available yet").accessibilityLabel("Recent Notes")
            Spacer()
            Menu { Text("Local notebook • no account signed in"); Button("Sign In…") {}.disabled(true) } label: { Image(systemName: "person.crop.circle.fill").font(.system(size: 34)).foregroundStyle(Color(red: 0.56, green: 0.38, blue: 0.76)) }.menuIndicator(.hidden).padding(.bottom, 6).help("Account Settings").accessibilityLabel("Account Settings")
        }.font(.system(size: 17)).foregroundStyle(PaperPalette.secondary).frame(width: 47).background(Color(white: 0.19)).buttonStyle(.plain)
    }
    private var notebookHeader: some View {
        HStack(spacing: 8) {
            Menu {
                Text(session.notebook?.title ?? "Notebook")
                TextField("Notebook name", text: Binding(get: { session.notebook?.title ?? "" }, set: { session.renameNotebook($0) }))
                Divider(); Button("New Notebook…") {}.disabled(true); Button("Open Notebook…") {}.disabled(true)
            } label: { HStack(spacing: 8) { Image(systemName: "book.closed.fill").foregroundStyle(.blue); Text(session.notebook?.title ?? "Notebook") }.font(.system(size: 14, weight: .semibold)) }.menuIndicator(.hidden).fixedSize().help("Current notebook")
            Spacer()
            Button { commands.navigationHidden.toggle() } label: { Image(systemName: "sidebar.left") }.help("Hide Section and Page Lists").accessibilityLabel("Hide Section and Page Lists")
            Menu { ForEach(["Original Order", "Title A–Z", "Title Z–A"], id: \.self) { order in Button(order) { commands.pageSort = order } }; Button("Recent Notes") {}.disabled(true) } label: { Image(systemName: "line.3.horizontal.decrease") }.menuIndicator(.hidden).fixedSize().help("Sort Pages").accessibilityLabel("Sort Pages")
        }.buttonStyle(.plain).padding(.horizontal, 12).frame(height: 45).overlay(alignment: .bottom) { PaperPalette.line.frame(height: 1) }
    }
    private var searchField: some View {
        HStack { Image(systemName: "magnifyingglass"); TextField("Search this \(commands.searchScope)", text: $commands.search); Button { commands.search = ""; commands.searching = false } label: { Image(systemName: "xmark") } }.padding(10).font(.system(size: 12))
    }
    private func sidebar(_ notebook: Notebook) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(notebook.sections.enumerated()), id: \.element.id) { index, section in
                        Button { session.selectSection(section.id) } label: {
                            HStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 3).fill([Color.blue, .yellow, .pink, .green][index % 4]).frame(width: 8, height: 26)
                                Text(section.title).font(.system(size: 14)).lineLimit(1); Spacer(minLength: 4)
                            }.padding(.leading, 13).frame(height: 36).background(section.id == session.selectedSectionID ? PaperPalette.selected : .clear).contentShape(Rectangle())
                        }.buttonStyle(.plain).contextMenu {
                            TextField("Section name", text: Binding(get: { section.title }, set: { session.selectSection(section.id); session.renameSection($0) }))
                            Button("New Section") { session.addSection() }
                            Button("New Section Group") {}.disabled(true)
                        }
                    }
                }
            }
            footer("Add section") { session.addSection() }
        }.overlay(alignment: .trailing) { PaperPalette.line.frame(width: 1) }
    }
    private var pages: [NotePage] {
        let values = commands.searching && commands.searchScope == "notebook" ? (session.notebook?.sections.flatMap(\.pages) ?? []) : commands.searching && commands.searchScope == "page" ? session.selectedPage.map { [$0] } ?? [] : session.selectedSection?.pages ?? []
        let filtered = commands.search.isEmpty ? values : values.filter { ($0.title + " " + $0.blocks.map(\.text).joined(separator: " ")).localizedCaseInsensitiveContains(commands.search) }
        if commands.pageSort == "Title A–Z" { return filtered.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending } }
        if commands.pageSort == "Title Z–A" { return filtered.sorted { $0.title.localizedStandardCompare($1.title) == .orderedDescending } }
        return filtered
    }
    private var pageList: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(pages) { page in
                        Button {
                            if let section = session.notebook?.sections.first(where: { $0.pages.contains(where: { $0.id == page.id }) }) { session.selectSection(section.id) }
                            session.selectPage(page.id)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(page.title.isEmpty ? "Untitled page" : page.title).font(.system(size: 14)).lineLimit(1)
                                Text(page.blocks.first?.text ?? "Start writing…").font(.system(size: 12)).foregroundStyle(PaperPalette.secondary).lineLimit(1)
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 20).frame(height: 56).background(page.id == session.selectedPageID ? PaperPalette.selected : .clear).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }
            }
            footer("Add page") { session.addPage() }
        }.overlay(alignment: .trailing) { PaperPalette.line.frame(width: 1) }
    }
    private func footer(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { Text(title).font(.system(size: 14, weight: .semibold)).foregroundStyle(Color(red: 0.79, green: 0.69, blue: 0.91)).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 20).frame(height: 44) }.buttonStyle(.plain).overlay(alignment: .top) { PaperPalette.line.frame(height: 1) }
    }
    private var pageContent: some View {
        VStack(spacing: 0) {
            if let error = session.errorMessage { HStack { Text("Couldn’t save: \(error)"); Button("Retry") { session.saveNow() } }.padding(12).foregroundStyle(.red) }
            if let page = session.selectedPage {
                if !commands.hidePageTitle {
                    HStack {
                        TextField("Page title", text: Binding(get: { session.selectedPage?.title ?? "" }, set: { session.renamePage($0, pageID: page.id) }))
                            .textFieldStyle(.plain).font(.system(size: 24, weight: .regular)).accessibilityLabel("Page title").frame(maxWidth: 310).padding(.bottom, 5).overlay(alignment: .bottom) { Color.gray.frame(height: 1) }
                        Spacer(minLength: 0)
                    }.foregroundStyle(commands.lightCanvas ? .black : Color(nsColor: EditorTheme.foreground)).padding(.leading, 48).padding(.top, 22).padding(.bottom, 12)
                }
                ScrollView([.horizontal, .vertical]) {
                    let width = max(760, (page.blocks.map { $0.x + $0.width }.max() ?? 0) + 48)
                    let height = max(900, (page.blocks.map { $0.y + ($0.height ?? 260) }.max() ?? 0) + 100)
                    ZStack(alignment: .topLeading) {
                        canvas
                        PaperLines(style: commands.paperStyle)
                        ForEach(page.blocks) { block in
                            TextContainerView(session: session, formatting: commands.formatting, lightCanvas: commands.lightCanvas, pageID: page.id, block: block).id(block.id).offset(x: block.x, y: block.y)
                        }
                    }.frame(width: width, height: height).scaleEffect(commands.zoom, anchor: .topLeading)
                        .frame(width: width * commands.zoom, height: height * commands.zoom, alignment: .topLeading)
                }
            } else { ContentUnavailableView("Choose a page", systemImage: "doc.text", description: Text("Add a page to start writing.")) }
        }.background(canvas)
    }
}

private struct PaperLines: View {
    let style: String
    var body: some View {
        Canvas { context, size in
            guard style != "None" else { return }
            let step: CGFloat = style.contains("Narrow") || style.contains("Small") ? 16 : style.contains("Wide") || style.contains("Very Large") ? 40 : style.contains("Large") ? 32 : 24
            var path = Path()
            for y in stride(from: step, through: size.height, by: step) { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)) }
            if style.contains("Grid") { for x in stride(from: step, through: size.width, by: step) { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)) } }
            context.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 0.5)
        }.allowsHitTesting(false)
    }
}

@MainActor private struct TextContainerView: View {
    @ObservedObject var session: NotebookSession
    let formatting: EditorFormatting
    let lightCanvas: Bool
    let pageID: UUID
    let block: NoteBlock
    @State private var drag: CGSize = .zero
    @State private var resize: CGSize = .zero
    private var editor: RichTextEditor {
        var editor = RichTextEditor(text: block.text, richText: block.richText, undoManager: session.undoManager, onChange: { session.editText(pageID: pageID, blockID: block.id, text: $0, richText: $1) }, onError: { session.reportError($0) })
        editor.formatting = formatting; editor.lightCanvas = lightCanvas
        return editor
    }
    var body: some View {
        VStack(spacing: 0) {
            HStack { Spacer(); Text("····").font(.system(size: 10)); Spacer() }.frame(height: 9).background(Color.gray.opacity(0.22)).contentShape(Rectangle()).help("Drag to move text container")
                .gesture(DragGesture().onChanged { drag = $0.translation }.onEnded { value in
                    session.setGeometry(pageID: pageID, blockID: block.id, x: block.x + value.translation.width, y: block.y + value.translation.height, width: block.width, height: block.height ?? 260); drag = .zero
                })
            editor
        }.frame(width: max(240, block.width + resize.width), height: max(140, (block.height ?? 260) + resize.height)).overlay(Rectangle().stroke(Color.gray.opacity(0.22), lineWidth: 1))
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "arrow.down.right").font(.system(size: 10)).foregroundStyle(PaperPalette.secondary).padding(5).contentShape(Rectangle()).help("Drag to resize text container")
                    .gesture(DragGesture().onChanged { resize = $0.translation }.onEnded { value in
                        session.setGeometry(pageID: pageID, blockID: block.id, x: block.x, y: block.y, width: block.width + value.translation.width, height: (block.height ?? 260) + value.translation.height); resize = .zero
                    })
            }.offset(drag)
    }
}
