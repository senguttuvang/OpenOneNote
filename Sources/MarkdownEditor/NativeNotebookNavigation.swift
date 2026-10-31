import SwiftUI
import MarkdownNotes

@MainActor struct NativeNotebookNavigation: View {
    @Bindable var shell: NativeShellState
    let wide: Bool
    @State private var selectedPage: UUID?
    @FocusState private var sectionNameFocused: Bool
    @Environment(\.colorScheme) private var scheme
    private var palette: NativePalette { NativePalette(scheme) }
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                railButton("Hide Section and Page Lists", "rectangle.righthalf.inset.filled") { shell.navigationHidden.toggle() }
                railButton("Search", "magnifyingglass", tint: .pink) { shell.searching.toggle() }
                railButton("Notebooks", "book.closed.fill", tint: .purple) { shell.navigationHidden = false; shell.sheet = .notebooks }
                    .overlay(alignment: .leading) { palette.accent.opacity(0.5).frame(width: 3).padding(.vertical, 4) }
                railButton("Recent Notes", "clock") {}.disabled(true).help("Recent editing history is unavailable")
                Spacer()
                railButton("Account Settings", "person.crop.circle.fill", tint: .purple) { shell.sheet = .account }
            }.frame(width: 47).background(palette.rail)
            if !shell.navigationHidden { columns }
        }.onAppear { selectedPage = shell.session.selectedID }
            .onChange(of: shell.session.selectedID) { _, value in selectedPage = value }
    }
    private var columns: some View {
        let sectionWidth = wide ? shell.sectionWidth : max(140, shell.sectionWidth - 50)
        let pageWidth = wide ? shell.pageWidth : max(160, shell.pageWidth - 81)
        return VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "book.closed.fill").foregroundStyle(.blue)
                Menu {
                    ForEach(shell.notebooks, id: \.self) { name in Button(name) { shell.selectNotebook(name) } }
                    Divider(); Button("Open More Notebooks…") { shell.sheet = .notebooks }; Button("New Notebook…") { shell.sheet = .newNotebook }
                } label: { Text(shell.notebook.isEmpty ? "On My Mac" : shell.notebook).font(.system(size: 14, weight: .semibold)) }.menuIndicator(.hidden).fixedSize()
                Spacer(minLength: 4)
                Button { shell.navigationHidden = true } label: { Image(systemName: "sidebar.left") }.help("Hide Section and Page Lists")
                Menu("Sort Pages", systemImage: "line.3.horizontal.decrease") { Text("Name"); Text("Page order follows the current notebook") }.labelStyle(.iconOnly).menuIndicator(.hidden).fixedSize()
            }.buttonStyle(NativeToolStyle()).padding(.horizontal, 12).frame(height: 45)
            if shell.searching {
                HStack { TextField("Search pages", text: $shell.search).textFieldStyle(.roundedBorder).accessibilityLabel("Search pages"); Button("Done") { shell.searching = false; shell.search = "" } }.padding(8)
            }
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    List(selection: Binding<String?>(get: { shell.section }, set: { if let value = $0 { shell.selectSection(value) } })) {
                        ForEach(Array(shell.sections.enumerated()), id: \.element) { index, name in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 2).fill([Color.blue, .yellow, .pink, .green][index % 4]).frame(width: 8, height: 25)
                                if shell.editingSectionName == name {
                                    TextField("Section name", text: $shell.sectionNameDraft)
                                        .textFieldStyle(.plain).font(.system(size: 14)).focused($sectionNameFocused)
                                        .accessibilityLabel("Section name").onAppear { sectionNameFocused = true }
                                        .onSubmit { if shell.finishSectionName() { sectionNameFocused = false } }
                                        .onExitCommand { shell.cancelSectionName(); sectionNameFocused = false }
                                } else { Text(name).font(.system(size: 14)).lineLimit(1) }
                                Spacer(minLength: 0)
                            }.frame(height: 36).tag(name).listRowInsets(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 8)).listRowSeparator(.hidden)
                                .listRowBackground(shell.section == name ? palette.selected : .clear)
                        }
                    }.listStyle(.plain).scrollContentBackground(.hidden).tint(.gray).disabled(shell.session.busy)
                    footer("Add section") { shell.createSection() }
                }.frame(width: sectionWidth)
                NativeColumnDivider(width: $shell.sectionWidth, bounds: 190...360, title: "Section column width")
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                    List(selection: $selectedPage) {
                        ForEach(shell.pages) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title).font(.system(size: 14)).lineLimit(1)
                                Text(shell.pagePreview(note)).font(.system(size: 12)).foregroundStyle(palette.secondary).lineLimit(1)
                            }.frame(height: 56).tag(note.id).id(note.id)
                                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 12)).listRowSeparator(.hidden)
                                .listRowBackground(shell.session.selectedID == note.id ? palette.selected : .clear)
                                .contextMenu { Button("Relink moved Markdown…") { shell.session.relink(note.id) }; Button("Sync details…") { shell.sheet = .recovery } }
                        }
                    }.listStyle(.plain).scrollContentBackground(.hidden).tint(.gray).disabled(shell.session.busy)
                        .onChange(of: selectedPage) { _, value in if let value { shell.session.select(value); selectedPage = shell.session.selectedID } }
                        .onChange(of: shell.session.selectedID) { _, value in if let value { proxy.scrollTo(value, anchor: .bottom) } }
                    }
                    footer("Add page") { shell.createPage() }
                }.frame(width: pageWidth)
            }
        }.frame(width: sectionWidth + pageWidth + 1).background(palette.navigation)
            .onChange(of: sectionNameFocused) { _, focused in
                if !focused && shell.editingSectionID != nil && !shell.finishSectionName(focusTitle: false) { sectionNameFocused = true }
            }
            .overlay(alignment: .trailing) { NativeColumnDivider(width: $shell.pageWidth, bounds: 241...400, title: "Page column width") }
    }
    private func railButton(_ title: String, _ symbol: String, tint: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(systemName: symbol).font(.system(size: 18)).foregroundStyle(tint ?? palette.secondary).frame(width: 43, height: 44) }.buttonStyle(NativeToolStyle()).help(title).accessibilityLabel(title)
    }
    private func footer(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { Text(title).font(.system(size: 14, weight: .semibold)).foregroundStyle(palette.dark ? Color(red: 0.78, green: 0.68, blue: 0.89) : palette.accent).frame(maxWidth: .infinity, minHeight: 44, alignment: .leading).padding(.leading, 20) }.buttonStyle(NativeToolStyle()).disabled(shell.session.busy).overlay(alignment: .top) { palette.line.frame(height: 1) }
    }
}
