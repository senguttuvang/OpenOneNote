import AppKit
import SwiftUI

struct NativePalette {
    let dark: Bool
    init(_ scheme: ColorScheme) { dark = scheme == .dark }
    var canvas: Color { dark ? Color(white: 32 / 255) : .white }
    var navigation: Color { Color(white: dark ? 36 / 255 : 0.97) }
    var ribbon: Color { Color(white: dark ? 39 / 255 : 0.96) }
    var rail: Color { Color(white: dark ? 48 / 255 : 0.93) }
    var selected: Color { Color(white: dark ? 59 / 255 : 0.87) }
    var accent: Color { Color(red: 0.62, green: 0.20, blue: 0.79) }
    var ink: Color { Color(white: dark ? 0.92 : 0.12) }
    var secondary: Color { Color(white: dark ? 0.68 : 0.36) }
    var line: Color { Color(white: dark ? 0.07 : 0.81) }
    var link: Color { Color(red: dark ? 0.39 : 0.05, green: dark ? 0.68 : 0.36, blue: dark ? 0.90 : 0.69) }
}

struct NativeToolStyle: ButtonStyle {
    @Environment(\.isEnabled) private var enabled
    func makeBody(configuration: Configuration) -> some View { ToolBody(configuration: configuration, enabled: enabled) }
    private struct ToolBody: View {
        let configuration: ButtonStyleConfiguration
        let enabled: Bool
        @State private var hovered = false
        var body: some View {
            configuration.label.padding(.horizontal, 2).padding(.vertical, 1)
                .background(.primary.opacity(configuration.isPressed ? 0.18 : hovered && enabled ? 0.09 : 0), in: RoundedRectangle(cornerRadius: 3))
                .opacity(enabled ? 1 : 0.38).onHover { hovered = $0 }
        }
    }
}

@MainActor struct NativeRibbon: View {
    @Bindable var shell: NativeShellState
    @State private var presentedGallery: String?
    @Environment(\.colorScheme) private var scheme
    private var palette: NativePalette { NativePalette(scheme) }
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                tool("Undo", "arrow.uturn.backward"); tool("Redo", "arrow.uturn.forward")
                Menu("Customise Quick Access Toolbar", systemImage: "ellipsis") { Text("Undo"); Text("Redo"); Button("Save") { shell.perform("Save") } }.labelStyle(.iconOnly).menuIndicator(.hidden).fixedSize()
                Spacer()
            }.padding(.leading, 104).padding(.trailing, 16).frame(height: 36)
                .overlay { Text("OpenOneNote").font(.system(size: 12)) }
            HStack(spacing: 22) {
                ForEach(["Home", "Insert", "Draw", "View"] + (shell.tableContext ? ["Table"] : []), id: \.self) { tab in
                    Button { if shell.tab == tab { shell.ribbonCollapsed.toggle() } else { shell.tab = tab; shell.ribbonCollapsed = false } } label: {
                        Text(tab).font(.system(size: 13, weight: shell.tab == tab ? .bold : .medium)).padding(.vertical, 8)
                            .overlay(alignment: .bottom) { if shell.tab == tab { Capsule().fill(palette.ink).frame(height: 3) } }
                    }.accessibilityAddTraits(shell.tab == tab ? .isSelected : [])
                }
                Button { shell.searching.toggle() } label: { Label("Tell me", systemImage: "lightbulb") }.font(.system(size: 12))
                Spacer(minLength: 12)
                Button { shell.syncPopover.toggle() } label: {
                    Image(systemName: shell.session.selectedID.flatMap { shell.session.syncErrors[$0] } == nil ? "checkmark.icloud" : "exclamationmark.icloud")
                }.accessibilityLabel("Page sync status").help(shell.friendlyState)
                    .popover(isPresented: $shell.syncPopover, arrowEdge: .bottom) { NativeSyncPopover(shell: shell) }
                Menu { Button("Microsoft account…") { shell.showCloud(.account) }; Button("Open notebooks…") { shell.showCloud(.notebooks) }; Button("Share page link") {}.disabled(true) } label: {
                    Label("Share", systemImage: "square.and.arrow.up").font(.system(size: 12)).padding(.horizontal, 8).padding(.vertical, 3).foregroundStyle(.white).background(palette.accent, in: RoundedRectangle(cornerRadius: 4))
                }.fixedSize()
            }.padding(.horizontal, 12).frame(height: 36)
            if !shell.ribbonCollapsed {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        switch shell.tab {
                        case "Insert": insert
                        case "Draw": draw
                        case "View": view
                        case "Table": table
                        default: home
                        }
                    }.padding(.horizontal, 16).frame(height: 76)
                }.scrollIndicators(.hidden).frame(height: 76)
            }
        }.background(palette.ribbon).foregroundStyle(palette.ink).buttonStyle(NativeToolStyle())
            .overlay(alignment: .bottom) { palette.line.frame(height: 1) }
    }
    private var home: some View {
        Group {
            HStack(spacing: 3) {
                VStack(spacing: 1) {
                    Menu { ForEach(["Keep Source Formatting", "Match Formatting", "Keep Text Only"], id: \.self) { command in Button(command) { shell.perform(command) }.disabled(!shell.canPerform(command)) } } label: { Image(systemName: "doc.on.clipboard").font(.system(size: 28)) }.menuIndicator(.visible).fixedSize()
                    Text("Paste").font(.system(size: 11))
                }.frame(width: 40)
                VStack(alignment: .leading, spacing: 2) { small("Cut", "scissors"); small("Copy", "doc.on.doc"); small("Format", "paintbrush", command: "Copy Format") }.frame(width: 64)
            }
            divider
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    NativeFontCombo(value: Binding(get: { !shell.markdownVisible || shell.mode == .read ? "Calibri" : shell.editor.fontName }, set: { shell.editor.fontName = $0; shell.mode = .write }), choices: NSFontManager.shared.availableFontFamilies.sorted()).frame(width: 99, height: 24).disabled(!shell.markdownVisible).help("Font changes are available for source display; portable rich font metadata is unavailable")
                    Menu { ForEach([10, 11, 12, 14, 16, 18, 20, 24, 28], id: \.self) { size in Button("\(size)") { shell.editor.fontSize = Double(size) * 4 / 3 } } } label: { HStack { Text("\(Int(shell.editor.fontSize * 0.75))"); Image(systemName: "chevron.down").font(.system(size: 7)) }.frame(width: 48, height: 22).background(.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 3)) }.menuIndicator(.hidden).fixedSize().disabled(!shell.markdownVisible).help("Font Size • source display only")
                    galleryTool("Bulletpoints", "list.bullet", kind: "bullets"); galleryTool("Numbering", "list.number", kind: "numbering")
                    tool("Decrease Indent", "decrease.indent"); tool("Increase Indent", "increase.indent"); tool("Clear Formatting", "eraser")
                }
                HStack(spacing: 11) {
                    tool("Bold", "bold"); tool("Italic", "italic"); tool("Underline", "underline"); tool("Strikethrough", "strikethrough")
                    Menu("Subscript and Superscript") { unavailable("Subscript"); unavailable("Superscript") }.labelsHidden().frame(width: 27).overlay { Text("x₂").allowsHitTesting(false) }
                    galleryTool("Text Highlight Colour", "highlighter", kind: "highlight"); galleryTool("Font Colour", "a.underline", kind: "font")
                    Menu { ForEach(["Align to Left", "Centre", "Align to Right"], id: \.self) { unavailable($0) } } label: { Image(systemName: "text.alignleft").frame(width: 18, height: 22) }.menuIndicator(.hidden).fixedSize().accessibilityLabel("Paragraph Alignment")
                    tool("Delete", "xmark")
                }.frame(height: 22)
            }.frame(width: 340, alignment: .leading)
            divider
            gallery("Styles", first: "Heading 1", second: "Heading 2", width: 182, items: InterfaceCatalog.styles)
            divider
            gallery("Tags", first: "To Do", second: "Important", width: 238, items: InterfaceCatalog.tags)
            divider
            large("Dictate", "mic.fill", width: 48)
            divider
            Button { shell.markdownVisible.toggle(); shell.mode = .write } label: {
                tile("Markdown", "chevron.left.forwardslash.chevron.right", width: 64)
            }.accessibilityLabel("Markdown source").help("Show or hide Markdown source (⌥⌘M)")
            if shell.markdownVisible { modes }
        }
    }
    private var insert: some View {
        Group {
            galleryTile("Table", "tablecells", width: 42, kind: "table"); divider
            large("File", "paperclip", width: 34, command: "File…"); large("Printout", "doc.text", width: 46); large("Picture", "photo", width: 44, command: "Picture…"); large("Screenshot", "camera.viewfinder", width: 66)
            divider; large("Link", "link", width: 36, command: "Link…"); divider; large("Equation", "function", width: 46); divider
            VStack(alignment: .leading, spacing: 8) { small("Date", "calendar"); small("Date & Time", "calendar.badge.clock") }.frame(width: 94)
            divider
            VStack(spacing: 3) { ForEach(0..<2) { row in HStack(spacing: 7) { ForEach(0..<7) { column in
                ShapeSample(kind: row * 7 + column).stroke(palette.link.opacity(0.65), lineWidth: 1.2).frame(width: 20, height: 18).accessibilityLabel(InterfaceCatalog.shapes[row * 7 + column])
            } } } }.frame(width: 190, height: 58).background(.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 3)).help("Shapes • ink objects are unavailable in Markdown")
            divider; large("Audio Recording", "mic", width: 60); divider; large("Meeting Details", "calendar", width: 56); large("Stickers", "face.smiling", width: 44)
        }
    }
    private var draw: some View {
        Group {
            large("Text Mode", "text.cursor", width: 40, command: "Write"); large("Lasso Select", "lasso", width: 40); large("Insert Space", "arrow.up.and.down", width: 40); divider
            Menu { ForEach(["Small Eraser", "Medium Eraser", "Large Eraser", "Stroke Eraser"], id: \.self) { unavailable($0) } } label: { tile("Eraser", "eraser.fill", width: 48) }.menuIndicator(.hidden).fixedSize()
            large("Pen", "pencil.tip", width: 40); large("Marker", "pencil.tip.crop.circle", width: 45); large("Highlighter", "highlighter", width: 57); divider
            HStack(spacing: 13) { ForEach([Color.gray, .blue, .green, .red], id: \.self) { color in Circle().fill(color).frame(width: 21, height: 21) } }.frame(width: 172, height: 58).background(.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 3)).opacity(0.55)
            galleryTile("Ink Colour", "pencil.tip", width: 44, kind: "ink"); divider
            HStack(spacing: 13) { ForEach([0.25, 0.35, 0.5, 0.7, 1.0], id: \.self) { value in VStack(spacing: 5) { StrokeSample().stroke(palette.ink.opacity(0.4), lineWidth: value * 4).frame(width: 48, height: 26); Text("\(value.formatted()) mm").font(.system(size: 11)).foregroundStyle(palette.secondary) } } }.padding(.horizontal, 15).frame(height: 58).background(.primary.opacity(0.07), in: RoundedRectangle(cornerRadius: 3))
        }
    }
    private var view: some View {
        Group {
            large("New Window", "macwindow.badge.plus", width: 48); large("Switch Background", "sun.max", width: 64); divider
            large("Page Versions", "doc.on.doc", width: 50); large("Deleted Notes", "trash", width: 44); divider
            large("Zoom Out", "minus.magnifyingglass", width: 38); large("Zoom In", "plus.magnifyingglass", width: 38)
            VStack(alignment: .leading, spacing: 2) { Text("\(Int(shell.zoom * 100))%").font(.system(size: 12)).frame(width: 90, height: 22).background(.primary.opacity(0.07)); small("Reset Zoom", "doc.plaintext"); small("Page Width", "arrow.left.and.right", command: "Zoom to Page Width") }; divider
            large("Password Protection", "lock", width: 64); divider
            galleryTile("Paper Colour", "paintpalette", width: 50, kind: "paper"); galleryTile("Paper Style", "list.bullet.rectangle", width: 50, kind: "ruling"); large("Hide Page Title", "doc.text", width: 56); large("Hide Authors", "person.text.rectangle", width: 50); divider
            if shell.markdownVisible { modes }
        }
    }
    private var table: some View {
        Group {
            ForEach(Array((InterfaceCatalog.ribbon["Table"] ?? []).enumerated()), id: \.offset) { index, title in
                if [4, 7, 11].contains(index) { divider }
                large(title, "tablecells", width: 56)
            }
        }
    }
    private var modes: some View {
        Picker("Editor mode", selection: $shell.mode) { ForEach(MarkdownEditorMode.allCases, id: \.self) { Text($0.rawValue).tag($0) } }.pickerStyle(.segmented).frame(width: 210).help("Markdown editor mode")
    }
    private var divider: some View { Rectangle().fill(.primary.opacity(0.18)).frame(width: 1, height: 64) }
    @ViewBuilder private func galleryContent(_ kind: String) -> some View {
        switch kind {
        case "bullets", "numbering": NativeListGallery(numbered: kind == "numbering", shell: shell) { presentedGallery = nil }
        case "table": NativeTableGallery(shell: shell) { presentedGallery = nil }
        case "ruling": NativePaperGallery()
        default: NativeColourGallery(kind: kind)
        }
    }
    private func galleryTool(_ title: String, _ symbol: String, kind: String) -> some View {
        Button { presentedGallery = kind } label: { Image(systemName: symbol).font(.system(size: 13)).frame(width: 18, height: 22) }
            .popover(isPresented: Binding(get: { presentedGallery == kind }, set: { if !$0 { presentedGallery = nil } }), arrowEdge: .bottom) { galleryContent(kind) }
            .accessibilityLabel(title).help(title)
    }
    private func galleryTile(_ title: String, _ symbol: String, width: Double, kind: String) -> some View {
        Button { presentedGallery = kind } label: { tile(title, symbol, width: width) }
            .popover(isPresented: Binding(get: { presentedGallery == kind }, set: { if !$0 { presentedGallery = nil } }), arrowEdge: .bottom) { galleryContent(kind) }
            .accessibilityLabel(title).help(title)
    }
    private func unavailable(_ title: String) -> some View { Button(title) {}.disabled(true) }
    private func tool(_ title: String, _ symbol: String) -> some View {
        Button { shell.perform(title) } label: { Image(systemName: symbol).font(.system(size: 13)).frame(width: 18, height: 22) }.disabled(!shell.canPerform(title)).accessibilityLabel(title).help(shell.canPerform(title) ? title : title + " • unavailable for Markdown")
    }
    private func small(_ title: String, _ symbol: String, command: String? = nil) -> some View {
        Button { shell.perform(command ?? title) } label: { Label(title, systemImage: symbol).font(.system(size: 12)).lineLimit(1) }.disabled(!shell.canPerform(command ?? title)).help(title)
    }
    private func tile(_ title: String, _ symbol: String, width: Double) -> some View {
        VStack(spacing: 4) { Image(systemName: symbol).font(.system(size: 28)).frame(height: 30); Text(title).font(.system(size: 11)).multilineTextAlignment(.center).lineLimit(2).frame(width: width) }.frame(width: width, height: 64, alignment: .top)
    }
    private func large(_ title: String, _ symbol: String, width: Double, command: String? = nil) -> some View {
        Button { shell.perform(command ?? title) } label: { tile(title, symbol, width: width) }.disabled(!shell.canPerform(command ?? title)).accessibilityLabel(title).help(shell.canPerform(command ?? title) ? title : title + " • unavailable for Markdown")
    }
    private func gallery(_ title: String, first: String, second: String, width: Double, items: [String]) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                ForEach([first, second], id: \.self) { name in Button { shell.perform(name) } label: { HStack(spacing: 8) { if name == "To Do" { Image(systemName: "checkmark.circle.fill").foregroundStyle(.purple) }; if name == "Important" { Image(systemName: "star.fill").foregroundStyle(.orange) }; Text(name).foregroundStyle(title == "Styles" ? palette.link : palette.ink) }.font(.system(size: 14)) }.disabled(!shell.canPerform(name)) }
            }
            Spacer(minLength: 0)
            Menu { ForEach(items, id: \.self) { name in Button(name) { shell.perform(name) }.disabled(!shell.canPerform(name)) } } label: { Image(systemName: "chevron.right").font(.system(size: 9)) }.menuIndicator(.hidden).fixedSize().accessibilityLabel(title)
        }.padding(.horizontal, 24).frame(width: width, height: 58).background(.primary.opacity(0.085), in: RoundedRectangle(cornerRadius: 3))
    }
}

@MainActor private struct NativeFontCombo: NSViewRepresentable {
    @Binding var value: String
    let choices: [String]
    func makeNSView(context: Context) -> NSComboBox { let box = NSComboBox(); box.addItems(withObjectValues: choices); box.font = .systemFont(ofSize: 12); box.delegate = context.coordinator; box.setAccessibilityLabel("Font"); return box }
    func updateNSView(_ box: NSComboBox, context: Context) { context.coordinator.parent = self; if box.stringValue != value { box.stringValue = value } }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator: NSObject, NSComboBoxDelegate {
        var parent: NativeFontCombo
        init(_ parent: NativeFontCombo) { self.parent = parent }
        func comboBoxSelectionDidChange(_ notification: Notification) { if let box = notification.object as? NSComboBox { parent.value = box.stringValue } }
        func controlTextDidEndEditing(_ notification: Notification) { if let box = notification.object as? NSComboBox { parent.value = box.stringValue } }
    }
}
