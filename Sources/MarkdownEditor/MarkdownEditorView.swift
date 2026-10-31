import AppKit
import SwiftUI
import MarkdownNotes

@MainActor public struct MarkdownEditorView: View {
    @Bindable private var session: MarkdownSession
    @State private var shell: NativeShellState
    @Environment(\.colorScheme) private var scheme
    @FocusState private var titleFocused: Bool
    private var palette: NativePalette { NativePalette(scheme) }
    public init(session: MarkdownSession, presentation: NativeShellState? = nil) {
        self.session = session; _shell = State(initialValue: presentation ?? NativeShellState(session: session))
    }
    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                NativeRibbon(shell: shell)
                HStack(spacing: 0) {
                    NativeNotebookNavigation(shell: shell, wide: geometry.size.width >= 1400)
                    page
                }
            }.background(palette.canvas).foregroundStyle(palette.ink)
        }.frame(minWidth: 960, minHeight: 600).tint(palette.accent)
            .onChange(of: session.selectedID) { _, _ in titleFocused = false; shell.followSelection() }
            .onChange(of: shell.titleFocusRequest) { _, request in
                guard shell.editingSectionID == nil else { return }
                let identity = session.selectedID
                titleFocused = false
                // Finish the current click/update before re-arming the same field.
                RunLoop.main.perform(inModes: [.default]) {
                    MainActor.assumeIsolated {
                        guard shell.titleFocusRequest == request, session.selectedID == identity, shell.editingSectionID == nil else { return }
                        titleFocused = true
                    }
                }
            }
            .onChange(of: shell.markdownVisible) { _, _ in
                titleFocused = false
                if let view = shell.editor.target { view.window?.makeFirstResponder(view) }
            }
            .sheet(item: $shell.sheet) { sheet in NativeAccountSurfaces(shell: shell, surface: sheet) }
    }
    private var page: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        pageTitle
                            .help(session.selected?.identity.root == "local" ? "Page title" : "Cloud page rename is unavailable")
                        Rectangle().fill(palette.secondary.opacity(0.7)).frame(width: 310, height: 0.5)
                    }
                    Spacer(minLength: 8)
                    if session.selected?.remoteRecovery != nil || session.selected?.externalRecoveryMarkdown != nil {
                        Button { shell.sheet = .recovery } label: { Label("Review changes", systemImage: "exclamationmark.triangle") }.foregroundStyle(.orange)
                    }
                }.padding(.leading, 48).padding(.trailing, 24).padding(.top, 22).frame(height: 74, alignment: .top)
                if session.selectedID != nil {
                    ZStack {
                        richPane
                            .disabled(session.busy || shell.markdownVisible).padding(.leading, 36).padding(.trailing, 24)
                            .opacity(shell.markdownVisible ? 0 : 1).allowsHitTesting(!shell.markdownVisible).accessibilityHidden(shell.markdownVisible)
                    ScrollView([.horizontal, .vertical]) {
                        HStack(alignment: .top, spacing: 0) {
                            sourcePane.frame(maxWidth: shell.mode == .read ? 0 : .infinity).clipped().accessibilityHidden(shell.mode == .read)
                            if shell.mode == .split { Divider() }
                            readingPane.frame(maxWidth: shell.mode == .write ? 0 : .infinity).clipped().accessibilityHidden(shell.mode == .write)
                        }.frame(width: shell.mode == .split ? max(1000, geometry.size.width - 120) : max(360, min(914, geometry.size.width - 120)), height: max(580, geometry.size.height - 120), alignment: .topLeading)
                            .background(shell.lightPaper ? Color.white : palette.canvas)
                            .overlay(Rectangle().stroke(.primary.opacity(0.12), lineWidth: 0.5))
                            .overlay(alignment: .top) { Text("····").font(.system(size: 11)).foregroundStyle(palette.secondary).frame(maxWidth: .infinity).frame(height: 9).background(.primary.opacity(0.08)).accessibilityHidden(true) }
                            .padding(.leading, 72).padding(.trailing, 24).padding(.top, 24).padding(.bottom, 12)
                    }
                    .opacity(shell.markdownVisible ? 1 : 0).allowsHitTesting(shell.markdownVisible).accessibilityHidden(!shell.markdownVisible)
                    }
                } else {
                    ContentUnavailableView("Choose a page", systemImage: "book.closed", description: Text("Open a notebook or add a page. Markdown is available from the ribbon.")).frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                HStack(spacing: 8) {
                    Text(shell.visibleStatus).lineLimit(1).help(shell.visibleStatus); Spacer()
                    Button { shell.sheet = .recovery } label: { Image(systemName: "info.circle") }.help("Sync details and recovery")
                }.font(.system(size: 11)).foregroundStyle(palette.secondary).padding(.horizontal, 16).frame(height: 24)
            }.background(shell.lightPaper ? Color.white : palette.canvas)
        }
    }
    private var sourcePane: some View {
        var editor = MarkdownSourceEditor(source: session.source, identity: session.selectedID, onChange: session.edit)
        editor.commands = shell.sourceCommands; editor.pointSize = shell.sourceCommands.fontSize * shell.zoom; editor.fontName = shell.sourceCommands.fontName; editor.lightPaper = shell.lightPaper
        return editor.disabled(session.busy || shell.mode == .read || !shell.markdownVisible).padding(.top, 12)
    }
    private var pageTitle: some View {
        let identity = session.selectedID
        return TextField("", text: Binding(
            get: { session.selected?.title == "Untitled Page" ? "" : (session.selected?.title ?? "") },
            set: { if session.selectedID == identity { session.renameSelected($0) } }))
            .id(identity).textFieldStyle(.plain).font(.system(size: 24, weight: .regular)).focused($titleFocused)
            .accessibilityLabel("Page title").disabled(identity == nil || session.busy || session.selected?.identity.root != "local")
            .onSubmit {
                guard session.selectedID == identity else { return }
                titleFocused = false
                RunLoop.main.perform(inModes: [.default]) {
                    MainActor.assumeIsolated {
                        guard session.selectedID == identity, let view = shell.editor.target else { return }
                        view.window?.makeFirstResponder(view)
                    }
                }
            }
    }
    private var richPane: some View {
        var editor = NativeRichEditor(source: session.source, identity: session.selectedID, commands: shell.richCommands, onChange: session.edit)
        editor.zoom = shell.zoom; editor.lightPaper = shell.lightPaper
        editor.onRejectedEdit = { session.message = $0 }
        return editor
    }
    private var readingPane: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(session.preview.blocks.enumerated()), id: \.offset) { _, node in MarkdownBlockView(node: node, vault: session.vault, scale: shell.zoom) }
                ForEach(session.preview.warnings, id: \.self) { Text($0).foregroundStyle(.orange) }
            }.frame(maxWidth: .infinity, alignment: .leading).padding(14)
        }.environment(\.colorScheme, shell.lightPaper ? .light : scheme).tint(palette.link).padding(.top, 8)
    }
}
