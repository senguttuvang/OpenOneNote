import AppKit
import SwiftUI
import MarkdownNotes

@MainActor public struct MarkdownEditorView: View {
    @Bindable private var session: MarkdownSession
    @State private var shell: NativeShellState
    @Environment(\.colorScheme) private var scheme
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
            .onChange(of: session.selectedID) { _, _ in shell.followSelection() }
            .sheet(item: $shell.sheet) { sheet in NativeAccountSurfaces(shell: shell, surface: sheet) }
    }
    private var page: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(session.selected?.title ?? "OpenOneNote").font(.system(size: 24, weight: .regular)).lineLimit(1)
                        Rectangle().fill(palette.secondary.opacity(0.7)).frame(width: 310, height: 0.5)
                    }
                    Spacer(minLength: 8)
                    if session.selected?.remoteRecovery != nil || session.selected?.externalRecoveryMarkdown != nil {
                        Button { shell.sheet = .recovery } label: { Label("Review changes", systemImage: "exclamationmark.triangle") }.foregroundStyle(.orange)
                    }
                }.padding(.leading, 48).padding(.trailing, 24).padding(.top, 22).frame(height: 74, alignment: .top)
                if session.selectedID != nil {
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
        editor.commands = shell.editor; editor.pointSize = shell.editor.fontSize * shell.zoom; editor.fontName = shell.editor.fontName; editor.lightPaper = shell.lightPaper
        return editor.disabled(session.busy || shell.mode == .read).padding(.top, 12)
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
