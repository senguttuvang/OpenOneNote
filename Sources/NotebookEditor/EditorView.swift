import AppKit
import SwiftUI
import NotebookCore

@MainActor private enum PaperPalette {
    static let rail = Color(red: 0.031, green: 0.471, blue: 0.710)
    static let ink = Color(red: 0.094, green: 0.196, blue: 0.310)
    static let canvas = Color(red: 0.961, green: 0.976, blue: 0.996)
    static let selected = Color(red: 0.894, green: 0.949, blue: 1)
    static let secondary = Color(red: 0.322, green: 0.396, blue: 0.486)
}

@MainActor public struct EditorView: View {
    @ObservedObject public var session: NotebookSession
    public init(session: NotebookSession) { self.session = session }

    public var body: some View {
        Group {
            if let notebook = session.notebook {
                HStack(spacing: 0) {
                    sidebar(notebook).frame(width: 220)
                    pageList.frame(width: 230)
                    Divider()
                    pageContent
                }
            } else {
                ContentUnavailableView {
                    Label("Couldn’t open notebook", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(session.errorMessage ?? "The notebook could not be opened. The original file has been preserved.")
                } actions: {
                    Button("Show Notebook File") { NSWorkspace.shared.activateFileViewerSelecting([session.url]) }
                }
            }
        }
        .preferredColorScheme(.light)
        .tint(PaperPalette.rail)
    }

    private func sidebar(_ notebook: Notebook) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Label("OpenOneNote", systemImage: "book.closed").font(.system(size: 19, weight: .semibold))
            TextField("Notebook name", text: Binding(get: { session.notebook?.title ?? "" }, set: { session.renameNotebook($0) }))
                .textFieldStyle(.plain).font(.system(size: 22, weight: .semibold))
                .accessibilityLabel("Notebook name")
            VStack(spacing: 6) {
                ForEach(notebook.sections) { section in
                    Button { session.selectSection(section.id) } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "folder")
                            Text(section.title).lineLimit(2)
                            Spacer()
                        }
                        .font(.system(size: 16, weight: section.id == session.selectedSectionID ? .semibold : .regular))
                        .padding(12)
                        .background(section.id == session.selectedSectionID ? Color.white.opacity(0.18) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }
                Button(action: { session.addSection() }) { Label("New Section", systemImage: "plus").frame(maxWidth: .infinity, alignment: .leading).padding(12) }
                    .buttonStyle(.plain).font(.system(size: 15))
            }
            Spacer()
            Label("On this Mac", systemImage: "internaldrive").font(.system(size: 14))
        }
        .padding(20).foregroundStyle(.white).background(PaperPalette.rail)
    }

    private var pageList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                TextField("Section name", text: Binding(get: { session.selectedSection?.title ?? "" }, set: { session.renameSection($0) }))
                    .textFieldStyle(.plain).font(.system(size: 18, weight: .semibold)).accessibilityLabel("Section name")
                Spacer()
                Button(action: { session.addPage() }) { Image(systemName: "square.and.pencil") }
                    .buttonStyle(.plain).help("New Page (⌘N)").accessibilityLabel("New Page")
                    .disabled(session.selectedSection == nil)
            }.padding(.horizontal, 20).padding(.top, 22)
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(session.selectedSection?.pages ?? []) { page in
                        Button { session.selectPage(page.id) } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(page.title.isEmpty ? "Untitled page" : page.title).font(.system(size: 16, weight: .semibold)).lineLimit(2)
                                Text(page.blocks.first?.text.isEmpty == false ? page.blocks.first!.text : "Start writing…")
                                    .font(.system(size: 14)).foregroundStyle(PaperPalette.secondary).lineLimit(3)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                            .background(page.id == session.selectedPageID ? PaperPalette.selected : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 8)).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 10)
            }
            Spacer(minLength: 0)
        }.foregroundStyle(PaperPalette.ink).background(PaperPalette.canvas)
    }

    private var pageContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Button(action: { session.addContainer() }) { Label("Add Text", systemImage: "text.badge.plus") }.disabled(session.selectedPage == nil)
                Button { NSApp.sendAction(NSSelectorFromString("toggleBoldface:"), to: nil, from: nil) } label: { Image(systemName: "bold") }
                    .accessibilityLabel("Bold").help("Bold (⌘B)").focusable(false)
                Button { NSApp.sendAction(NSSelectorFromString("toggleItalics:"), to: nil, from: nil) } label: { Image(systemName: "italic") }
                    .accessibilityLabel("Italic").help("Italic (⌘I)").focusable(false)
                Spacer()
                Text(session.status).font(.system(size: 13)).foregroundStyle(PaperPalette.secondary).lineLimit(1)
                Button { session.saveNow() } label: { Image(systemName: "square.and.arrow.down") }
                    .accessibilityLabel("Save Notebook").help("Save (⌘S)")
            }.buttonStyle(.borderless).padding(.horizontal, 24).padding(.vertical, 14)
            Divider()
            if let error = session.errorMessage {
                HStack { Text("Couldn’t save: \(error)").font(.system(size: 14)); Spacer(); Button("Retry") { session.saveNow() } }
                    .padding(12).foregroundStyle(.red).background(Color.red.opacity(0.05))
            }
            if let page = session.selectedPage {
                TextField("Page title", text: Binding(get: { session.selectedPage?.title ?? "" }, set: { session.renamePage($0, pageID: page.id) }))
                    .textFieldStyle(.plain).font(.system(size: 28, weight: .semibold))
                    .padding(.horizontal, 48).padding(.top, 28).padding(.bottom, 20).accessibilityLabel("Page title")
                ScrollView([.horizontal, .vertical]) {
                    ZStack(alignment: .topLeading) {
                        Color.white
                        ForEach(page.blocks) { block in
                            TextContainerView(session: session, pageID: page.id, block: block).id(block.id)
                                .offset(x: block.x, y: block.y)
                        }
                    }
                    .frame(width: max(760, (page.blocks.map { $0.x + $0.width }.max() ?? 0) + 48),
                           height: max(800, (page.blocks.map { $0.y + ($0.height ?? 260) }.max() ?? 0) + 100))
                }.background(.white)
            } else {
                ContentUnavailableView("Choose a page", systemImage: "doc.text", description: Text("Create a section and a page to start writing."))
            }
        }.foregroundStyle(PaperPalette.ink).background(.white)
    }
}

@MainActor private struct TextContainerView: View {
    @ObservedObject var session: NotebookSession
    let pageID: UUID
    let block: NoteBlock
    @State private var drag: CGSize = .zero
    @State private var resize: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "line.3.horizontal").foregroundStyle(PaperPalette.secondary).font(.system(size: 11))
                Spacer()
            }
            .frame(height: 22).padding(.horizontal, 12).contentShape(Rectangle()).help("Drag to move this text container")
            .gesture(DragGesture().onChanged { drag = $0.translation }.onEnded { value in
                session.setGeometry(pageID: pageID, blockID: block.id, x: block.x + value.translation.width, y: block.y + value.translation.height,
                                    width: block.width, height: block.height ?? 260)
                drag = .zero
            })
            RichTextEditor(text: block.text, richText: block.richText, undoManager: session.undoManager,
                onChange: { session.editText(pageID: pageID, blockID: block.id, text: $0, richText: $1) }, onError: { session.reportError($0) })
        }
        .frame(width: max(240, block.width + resize.width), height: max(140, (block.height ?? 260) + resize.height))
        .background(.white)
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.22), lineWidth: 1))
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "arrow.down.right").font(.system(size: 11)).foregroundStyle(PaperPalette.secondary).padding(6)
                .contentShape(Rectangle()).help("Drag to resize this text container")
                .gesture(DragGesture().onChanged { resize = $0.translation }.onEnded { value in
                    session.setGeometry(pageID: pageID, blockID: block.id, x: block.x, y: block.y,
                                        width: block.width + value.translation.width, height: (block.height ?? 260) + value.translation.height)
                    resize = .zero
                })
        }
        .offset(drag)
    }
}
