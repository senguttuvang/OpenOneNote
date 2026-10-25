import AppKit
import SwiftUI

@MainActor struct RibbonView: View {
    @ObservedObject var commands: EditorCommands
    @ObservedObject var formatting: EditorFormatting
    @State private var link = "https://"
    @State private var linkOpen = false
    @State private var quickAccess = Set(["Undo", "Redo"])
    init(commands: EditorCommands) { self.commands = commands; formatting = commands.formatting }
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if quickAccess.contains("Undo") { icon("Undo", "arrow.uturn.backward") }
                if quickAccess.contains("Redo") { icon("Redo", "arrow.uturn.forward") }
                Menu { ForEach(["Undo", "Redo"], id: \.self) { title in Toggle(title, isOn: Binding(get: { quickAccess.contains(title) }, set: { if $0 { quickAccess.insert(title) } else { quickAccess.remove(title) } })) } } label: { Image(systemName: "ellipsis") }.menuIndicator(.hidden).fixedSize().help("Customise Quick Access Toolbar")
                Spacer()
            }.padding(.leading, 104).padding(.trailing, 12).frame(height: 36)
                .overlay { Text("OpenOneNote").font(.system(size: 12)) }
            HStack(spacing: 23) {
                ForEach(["Home", "Insert", "Draw", "View"], id: \.self) { title in
                    Button { if commands.tab == title { commands.ribbonCollapsed.toggle() } else { commands.tab = title; commands.ribbonCollapsed = false } } label: {
                        Text(title).font(.system(size: 13, weight: commands.tab == title ? .bold : .medium)).padding(.vertical, 8)
                            .overlay(alignment: .bottom) { if commands.tab == title { Capsule().fill(.white).frame(height: 3) } }
                    }.accessibilityLabel(title)
                }
                Button { commands.searching.toggle() } label: { Label("Tell me", systemImage: "lightbulb") }.help("Tell me what you want to do")
                Spacer(minLength: 12)
                Menu { Text(commands.session.status); Button("Save on this Mac") { commands.session.saveNow() }; Button("Sync This Notebook") {}.disabled(true) } label: { Image(systemName: "checkmark.icloud") }.menuIndicator(.hidden).fixedSize().help("Page sync status • " + commands.session.status).accessibilityLabel("Page sync status")
                Menu { RibbonMenuContents(items: InterfaceCatalog.menus.first(where: { $0.title == "File" })!.children.first(where: { $0.title == "Share" })!.children, commands: commands) } label: { Label("Share", systemImage: "square.and.arrow.up").font(.system(size: 12)).padding(.horizontal, 9).padding(.vertical, 4).background(PaperPalette.accent).clipShape(RoundedRectangle(cornerRadius: 5)) }.menuIndicator(.visible).fixedSize().help("Share • cloud sharing is not available")
            }.padding(.horizontal, 12).frame(height: 36)
            if !commands.ribbonCollapsed {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        switch commands.tab {
                        case "Home": home
                        case "Insert": insert
                        case "Draw": draw
                        default: view
                        }
                    }.padding(.horizontal, 16).frame(height: 76)
                }.scrollIndicators(.hidden)
            }
        }.buttonStyle(.plain).background(PaperPalette.ribbon)
            .overlay(alignment: .bottom) { PaperPalette.line.frame(height: 1) }
            .popover(isPresented: $linkOpen) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Link").font(.headline)
                    TextField("Address", text: $link).frame(width: 300)
                    Button("Insert Link") { formatting.link(link); linkOpen = false }.disabled(URL(string: link)?.scheme == nil)
                }.padding(18)
            }
    }
    private var home: some View {
        Group {
            HStack(spacing: 5) {
                VStack(spacing: 3) {
                    HStack(spacing: 0) { Button { commands.perform("Paste") } label: { Image(systemName: "doc.on.clipboard").font(.system(size: 28)) }.disabled(!commands.canPerform("Paste")); dropdown("Paste", items: ["Paste", "Paste and Match Formatting", "Paste and Keep Text Only"]) }
                    Text("Paste").font(.system(size: 11))
                }.frame(width: 37)
                VStack(alignment: .leading, spacing: 3) { small("Cut", "scissors"); small("Copy", "doc.on.doc"); small("Format", "paintbrush", command: "Copy Format") }.frame(width: 64, alignment: .leading)
            }.padding(.trailing, 5)
            separator
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    RibbonCombo(label: "Font:", value: formatting.fontName, choices: NSFontManager.shared.availableFontFamilies.sorted()) { formatting.font(name: $0) }.frame(width: 99, height: 24)
                    RibbonCombo(label: "Font Size:", value: (formatting.fontSize * 0.75).formatted(.number.precision(.fractionLength(0...1))), choices: ["8", "9", "10", "11", "12", "14", "16", "18", "20", "22", "24", "26", "28", "36", "48", "72"]) { if let size = Double($0), (6...72).contains(size) { formatting.font(size: size / 0.75) } }.frame(width: 54, height: 24)
                    Spacer(minLength: 3)
                    splitIcon("Bulletpoints", "list.bullet", options: ["Bulletpoints", "Numbering"])
                    splitIcon("Numbering", "list.number", options: ["Numbering", "Bulletpoints"])
                    Spacer(minLength: 3)
                    icon("Decrease Indent", "decrease.indent")
                    icon("Increase Indent", "increase.indent")
                    icon("Clear Formatting", "a.badge.checkmark")
                }
                HStack(spacing: 12) {
                    icon("Bold", "bold", active: formatting.bold)
                    icon("Italic", "italic", active: formatting.italic)
                    icon("Underline", "underline", active: formatting.underline)
                    icon("Strikethrough", "strikethrough")
                    Menu { RibbonMenuContents(items: [InterfaceItem("Subscript"), InterfaceItem("Superscript")], commands: commands) } label: { HStack(spacing: 2) { Text("x₂"); chevron } }.menuIndicator(.hidden).fixedSize().help("Subscript and Superscript").accessibilityLabel("Subscript and Superscript")
                    colorMenu("Text Highlight Colour", symbol: "highlighter", key: .backgroundColor)
                    colorMenu("Font Colour", symbol: "a.underline", key: .foregroundColor)
                    Spacer(minLength: 0)
                    Menu { RibbonMenuContents(items: ["Align to Left", "Centre", "Align to Right"].map { InterfaceItem($0) }, commands: commands) } label: { HStack(spacing: 3) { Image(systemName: "text.alignleft"); chevron } }.menuIndicator(.hidden).fixedSize().help("Paragraph Alignment")
                    icon("Delete", "xmark")
                }.frame(height: 22)
            }.frame(width: 340, alignment: .leading)
            separator
            gallery(title: "Styles", first: "Heading 1", second: "Heading 2", width: 182, items: InterfaceCatalog.styles, tint: Color(nsColor: EditorTheme.link))
            separator
            gallery(title: "Tags", first: "To Do", second: "Important", width: 238, items: InterfaceCatalog.tags + ["Remove Tag"], tint: .primary)
            separator
            large("Dictate", "mic.fill")
        }
    }
    private var insert: some View {
        Group {
            VStack(spacing: 3) { Button { commands.perform("Table") } label: { Image(systemName: "tablecells").font(.system(size: 28)) }.disabled(!commands.canPerform("Table")); Menu("Table") { Button("Insert Table (3 × 2)") { commands.perform("Table") }.disabled(!formatting.available) }.fixedSize() }.frame(width: 42)
            separator
            HStack(spacing: 0) {
                large("File", "paperclip", width: 34, command: "File…")
                large("Printout", "doc.text", width: 46, command: "Printout…")
                large("Picture", "photo", width: 44, command: "Picture…")
                largeMenu("Screenshot", "camera.viewfinder", width: 66, choices: ["Screen Clipping", "Screenshot"])
            }
            separator
            Button { linkOpen = true } label: { tile("Link", "link", width: 36) }.disabled(!formatting.available)
            separator
            large("Equation", "function", width: 46)
            separator
            VStack(alignment: .leading, spacing: 10) { small("Date", "calendar"); small("Date & Time", "calendar.badge.clock") }.frame(width: 94, alignment: .leading)
            separator
            VStack(spacing: 2) {
                ForEach(0..<2, id: \.self) { row in HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { column in
                        let index = [0, 1, 2, 3, 4, 5, 6, 7, 9, 8, 10, 11, 12, 13][row * 7 + column]
                        let name = InterfaceCatalog.shapes[index]
                        Button {} label: { ShapeSample(kind: index).stroke(Color(nsColor: EditorTheme.link).opacity(0.7), lineWidth: 1.2).frame(width: 20, height: 18).frame(width: 24, height: 24) }.disabled(true).help(name + " • unavailable").accessibilityLabel(name)
                    }
                } }
            }.padding(.horizontal, 5).frame(width: 190, height: 58).background(Color.white.opacity(0.085)).clipShape(RoundedRectangle(cornerRadius: 3))
            separator
            large("Audio Recording", "mic", width: 55)
            separator
            HStack(spacing: 0) { large("Meeting Details", "calendar", width: 52, command: "Meeting Details…"); large("Stickers", "face.smiling", width: 44, command: "Stickers…") }
        }
    }
    private var draw: some View {
        Group {
            HStack(spacing: 0) { large("Text Mode", "text.cursor", width: 37); large("Lasso Select", "lasso", width: 37); large("Insert Space", "arrow.up.and.down", width: 37) }.padding(.leading, -7)
            separator
            HStack(spacing: 0) {
                largeMenu("Eraser", "eraser.fill", width: 50, choices: ["Small Eraser", "Medium Eraser", "Large Eraser", "Stroke Eraser"])
                large("Pen", "pencil.tip", width: 40); large("Marker", "pencil.tip.crop.circle", width: 45); large("Highlighter", "highlighter", width: 57)
            }
            separator
            HStack(spacing: 13) { ForEach([Color.gray, .blue, .green, .red], id: \.self) { color in Button {} label: { Circle().fill(color).frame(width: 21, height: 21) }.disabled(true) } }.frame(width: 172, height: 58).background(Color.white.opacity(0.085)).clipShape(RoundedRectangle(cornerRadius: 3)).accessibilityLabel("Suggested colours")
            largeMenu("Ink Colour", "pencil.tip", width: 40, choices: ["Automatic", "Blue", "Green", "Red", "More Colours…"])
            separator
            HStack(spacing: 0) { ForEach([0.25, 0.35, 0.5, 0.7, 1.0], id: \.self) { thickness in
                Button {} label: { VStack(spacing: 5) { StrokeSample().stroke(Color.primary.opacity(0.6), style: StrokeStyle(lineWidth: thickness * 4, lineCap: .round)).frame(width: 48, height: 26); Text("\(thickness.formatted()) mm").font(.system(size: 11)) }.frame(width: 61) }.disabled(true).help("\(thickness.formatted()) mm").accessibilityLabel("\(thickness.formatted()) mm")
            } }.padding(.horizontal, 15).frame(width: 335, height: 58).background(Color.white.opacity(0.085)).clipShape(RoundedRectangle(cornerRadius: 3))
        }
    }
    private var view: some View {
        Group {
            HStack(spacing: 0) { large("New Window", "macwindow.badge.plus", width: 48); large("Switch Background", "sun.max", width: 64) }.padding(.leading, -8)
            separator
            HStack(spacing: 0) {
                largeMenu("Page Versions", "doc.on.doc", width: 50, choices: ["Page Versions", "Delete All Versions in Section"])
                largeMenu("Deleted Notes", "trash", width: 44, choices: ["View Deleted Notes", "Empty Deleted Notes", "Disable History for This Notebook"])
            }
            separator
            HStack(spacing: 0) {
                large("Zoom Out", "minus.magnifyingglass", width: 38); large("Zoom In", "plus.magnifyingglass", width: 38)
                VStack(alignment: .leading, spacing: 2) {
                    RibbonCombo(label: "Zoom", value: "\(Int(commands.zoom * 100))%", choices: ["50%", "75%", "100%", "125%", "150%", "200%"]) { let text = $0.replacingOccurrences(of: "%", with: ""); if let value = Double(text), (50...200).contains(value) { commands.zoom = value / 100 } }.frame(width: 92, height: 22)
                    small("Reset Zoom", "doc.plaintext"); small("Page Width", "arrow.left.and.right")
                }.frame(width: 92)
            }
            separator
            largeMenu("Password Protection", "lock", width: 60, choices: ["Protect Current Section", "Lock All Protected Sections"])
            separator
            HStack(spacing: 0) {
                largeMenu("Paper Colour", "paintpalette", width: 50, choices: ["Automatic", "White", "Blue", "Yellow", "Green", "More Colours…"])
                largeMenu("Paper Style", "list.bullet.rectangle", width: 50, choices: InterfaceCatalog.paperStyles + ["Always Create Pages with Rule Lines"])
                large("Hide Page Title", "doc.text", width: 56); large("Hide Authors", "person.text.rectangle", width: 50)
            }
        }
    }
    private var chevron: some View { Image(systemName: "chevron.down").font(.system(size: 7)) }
    private var separator: some View { Rectangle().fill(Color.white.opacity(0.18)).frame(width: 1, height: 64) }
    private func icon(_ title: String, _ symbol: String, active: Bool = false) -> some View {
        Button { commands.perform(title) } label: {
            Group {
                if title == "Clear Formatting" { Text("A").font(.system(size: 15)).overlay(alignment: .bottomTrailing) { Image(systemName: "eraser.fill").font(.system(size: 8)).foregroundStyle(.purple).offset(x: 4) } }
                else { Image(systemName: symbol).font(.system(size: 13)) }
            }.frame(width: 18, height: 22).background(active ? Color.white.opacity(0.16) : .clear)
        }.disabled(!commands.canPerform(title)).help(title).accessibilityLabel(title).focusable(false)
    }
    private func small(_ title: String, _ symbol: String, command: String? = nil) -> some View {
        Button { commands.perform(command ?? title) } label: { Label(title, systemImage: symbol).font(.system(size: 12)).lineLimit(1) }.disabled(!commands.canPerform(command ?? title)).help(commands.canPerform(command ?? title) ? title : title + " • unavailable in the local editor")
    }
    private func tile(_ title: String, _ symbol: String, width: Double) -> some View {
        let split: [String: String] = ["Text Mode": "Text\nMode", "Lasso Select": "Lasso\nSelect", "Insert Space": "Insert\nSpace", "Audio Recording": "Audio\nRecording", "Meeting Details": "Meeting\nDetails", "New Window": "New\nWindow", "Switch Background": "Switch\nBackground", "Page Versions": "Page\nVersions", "Deleted Notes": "Deleted\nNotes", "Zoom Out": "Zoom\nOut", "Zoom In": "Zoom\nIn", "Password Protection": "Password\nProtection", "Paper Colour": "Paper\nColour", "Paper Style": "Paper\nStyle", "Hide Page Title": "Hide\nPage Title", "Hide Authors": "Hide\nAuthors", "Ink Colour": "Ink\nColour"]
        return VStack(spacing: 4) { Image(systemName: symbol).font(.system(size: 28)).frame(height: 30); Text(split[title] ?? title).font(.system(size: 11)).lineLimit(2).multilineTextAlignment(.center).frame(width: width).fixedSize(horizontal: false, vertical: true) }.frame(width: width, height: 64, alignment: .top)
    }
    private func large(_ title: String, _ symbol: String, width: Double = 48, command: String? = nil) -> some View {
        Button { commands.perform(command ?? title) } label: { tile(title, symbol, width: width) }.disabled(!commands.canPerform(command ?? title)).help(commands.canPerform(command ?? title) ? title : title + " • unavailable in the local editor").accessibilityLabel(title)
    }
    private func largeMenu(_ title: String, _ symbol: String, width: Double, choices: [String]) -> some View {
        Menu { RibbonMenuContents(items: choices.map { InterfaceItem($0) }, commands: commands) } label: { tile(title, symbol, width: width) }.menuIndicator(.hidden).fixedSize().help(title).accessibilityLabel(title)
    }
    private func dropdown(_ title: String, items: [String]) -> some View { Menu { RibbonMenuContents(items: items.map { InterfaceItem($0) }, commands: commands) } label: { chevron }.menuIndicator(.hidden).fixedSize().help(title + " options") }
    private func splitIcon(_ title: String, _ symbol: String, options: [String]) -> some View { HStack(spacing: 0) { icon(title, symbol); dropdown(title, items: options) } }
    private func menuLabel(_ title: String, _ symbol: String, choices: [String]) -> some View { Menu { RibbonMenuContents(items: choices.map { InterfaceItem($0) }, commands: commands) } label: { Label(title, systemImage: symbol).font(.system(size: 12)) }.fixedSize().help(title) }
    private func gallery(title: String, first: String, second: String, width: Double, items: [String], tint: Color) -> some View {
        HStack(spacing: 4) {
            VStack(alignment: .leading, spacing: 8) {
                galleryButton(first, tint: tint)
                galleryButton(second, tint: tint)
            }.frame(maxWidth: .infinity, alignment: .leading)
            Menu { RibbonMenuContents(items: items.map { InterfaceItem($0) }, commands: commands) } label: { Image(systemName: "chevron.right").font(.system(size: 9)) }.menuIndicator(.hidden).fixedSize().help("Next \(title) gallery")
        }.padding(.horizontal, title == "Styles" ? 26 : 30).frame(width: width, height: 58).background(Color.white.opacity(0.085)).overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.white.opacity(0.08)))
    }
    private func galleryButton(_ title: String, tint: Color) -> some View {
        Button { commands.perform(title) } label: {
            HStack(spacing: 8) {
                if title == "To Do" { Image(systemName: "checkmark.circle.fill").foregroundStyle(.purple) }
                if title == "Important" { Image(systemName: "star.fill").foregroundStyle(.orange) }
                Text(title).foregroundStyle(tint)
            }.font(.system(size: 14))
        }.disabled(!commands.canPerform(title)).accessibilityLabel(title)
    }
    private func colorMenu(_ title: String, symbol: String, key: NSAttributedString.Key?) -> some View {
        Menu {
            ForEach(["Automatic", "White", "Black", "Blue", "Red", "Green", "Yellow", "Purple", "No Colour"], id: \.self) { name in
                Button(name) {
                    guard let key else { return }
                    let colors: [String: NSColor] = ["Automatic": EditorTheme.foreground, "White": .white, "Black": .black, "Blue": EditorTheme.link, "Red": .systemRed, "Green": .systemGreen, "Yellow": NSColor(srgbRed: 0.3, green: 0.3, blue: 0, alpha: 1), "Purple": .systemPurple, "No Colour": key == .foregroundColor ? EditorTheme.foreground : .clear]
                    formatting.attribute(key, value: colors[name]!, action: title)
                }.disabled(key == nil || !formatting.available)
            }
        } label: { HStack(spacing: 2) {
            if title == "Font Colour" { Text("A").font(.system(size: 15, weight: .semibold)).overlay(alignment: .bottom) { Rectangle().fill(Color.white).frame(height: 2).offset(y: 3) } }
            else { Image(systemName: symbol) }
            chevron
        } }.menuIndicator(.hidden).fixedSize().help(title).accessibilityLabel(title)
    }
}

@MainActor private struct RibbonMenuContents: View {
    let items: [InterfaceItem]
    @ObservedObject var commands: EditorCommands
    var body: some View {
        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
            if item.title == "-" { Divider() }
            else if !item.children.isEmpty { Menu(item.title) { RibbonMenuContents(items: item.children, commands: commands) } }
            else { Button(item.title) { commands.perform(item.title) }.disabled(!commands.canPerform(item.title)).help(commands.canPerform(item.title) ? item.title : "Not available in the local editor yet") }
        }
    }
}

@MainActor private struct RibbonCombo: NSViewRepresentable {
    let label: String
    let value: String
    let choices: [String]
    let change: (String) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeNSView(context: Context) -> NSComboBox {
        let combo = NSComboBox(); combo.isEditable = true; combo.completes = true; combo.font = .systemFont(ofSize: 12)
        combo.addItems(withObjectValues: choices); combo.stringValue = value; combo.delegate = context.coordinator; combo.setAccessibilityLabel(label)
        return combo
    }
    func updateNSView(_ view: NSComboBox, context: Context) { context.coordinator.parent = self; if view.currentEditor() == nil { view.stringValue = value } }
    final class Coordinator: NSObject, NSComboBoxDelegate {
        var parent: RibbonCombo
        init(_ parent: RibbonCombo) { self.parent = parent }
        func comboBoxSelectionDidChange(_ notification: Notification) { if let combo = notification.object as? NSComboBox { parent.change(combo.stringValue) } }
        func controlTextDidEndEditing(_ notification: Notification) { if let combo = notification.object as? NSComboBox { parent.change(combo.stringValue) } }
    }
}

private struct StrokeSample: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(); path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.midY), control1: CGPoint(x: rect.width * 0.2, y: rect.minY), control2: CGPoint(x: rect.width * 0.25, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control1: CGPoint(x: rect.width * 0.8, y: rect.maxY), control2: CGPoint(x: rect.width * 0.8, y: rect.maxY))
        return path
    }
}

private struct ShapeSample: Shape {
    let kind: Int
    func path(in r: CGRect) -> Path {
        var p = Path(); let left = r.minX + 1, right = r.maxX - 1, top = r.minY + 1, bottom = r.maxY - 1
        switch kind {
        case 0, 1, 2:
            p.move(to: CGPoint(x: left, y: top)); p.addLine(to: CGPoint(x: right, y: bottom))
            if kind > 0 { p.move(to: CGPoint(x: right - 7, y: bottom)); p.addLine(to: CGPoint(x: right, y: bottom)); p.addLine(to: CGPoint(x: right, y: bottom - 7)) }
            if kind == 2 { p.move(to: CGPoint(x: left + 7, y: top)); p.addLine(to: CGPoint(x: left, y: top)); p.addLine(to: CGPoint(x: left, y: top + 7)) }
        case 3, 4, 5:
            p.move(to: CGPoint(x: left, y: top)); p.addLine(to: CGPoint(x: right, y: top)); p.addLine(to: CGPoint(x: right, y: bottom))
            if kind > 3 { p.move(to: CGPoint(x: right - 5, y: bottom - 5)); p.addLine(to: CGPoint(x: right, y: bottom)); p.addLine(to: CGPoint(x: right + 1, y: bottom - 5)) }
            if kind == 5 { p.move(to: CGPoint(x: left + 5, y: top - 1)); p.addLine(to: CGPoint(x: left, y: top)); p.addLine(to: CGPoint(x: left + 5, y: top + 5)) }
        case 6: p.addRect(r.insetBy(dx: 1, dy: 1))
        case 7: p.addEllipse(in: r.insetBy(dx: 1, dy: 1))
        case 8:
            p.move(to: CGPoint(x: r.midX, y: top)); p.addLine(to: CGPoint(x: right, y: bottom)); p.addLine(to: CGPoint(x: left, y: bottom)); p.closeSubpath()
        case 9:
            p.move(to: CGPoint(x: left + 4, y: top)); p.addLine(to: CGPoint(x: right, y: top)); p.addLine(to: CGPoint(x: right - 4, y: bottom)); p.addLine(to: CGPoint(x: left, y: bottom)); p.closeSubpath()
        case 10:
            p.move(to: CGPoint(x: r.midX, y: top)); p.addLine(to: CGPoint(x: right, y: r.midY)); p.addLine(to: CGPoint(x: r.midX, y: bottom)); p.addLine(to: CGPoint(x: left, y: r.midY)); p.closeSubpath()
        default:
            let center = CGPoint(x: kind == 11 ? left : r.midX, y: kind == 11 ? bottom : r.midY)
            p.move(to: CGPoint(x: center.x, y: bottom)); p.addLine(to: CGPoint(x: center.x, y: top)); p.move(to: CGPoint(x: left, y: center.y)); p.addLine(to: CGPoint(x: right, y: center.y))
            if kind == 13 { p.move(to: center); p.addLine(to: CGPoint(x: right, y: bottom)) }
        }
        return p
    }
}
