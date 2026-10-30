import AppKit
import SwiftUI

/// Independently drawn galleries observed in OneNote 16.114.1. No vendor assets.
enum ListGalleryCatalog {
    static let bullets = ["None", "Small Solid Circle Bullet", "Hollow Circle Bullet", "Small Solid Diamond Bullet", "Hollow Diamond Bullet", "Dash Bullet", "Small Solid Square Bullet", "Hollow Square Bullet", "Wide Triangle Bullet", "Single Line Arrow Bullet"]
    static let numbering = ["None", "Numbers, Period", "Ordinal Numbers, Period", "Lowercase Letters, Period", "Capital Letters, Period", "Lowercase Roman Numerals, Period", "Capital Roman Numerals, Period", "Numbers, Parentheses", "Lowercase Letters, Parentheses", "Capital Letters, Parentheses", "Lowercase Roman Numerals, Parentheses", "Capital Roman Numerals, Parentheses", "Numbers, Double Parentheses", "Capital Letters, Double Parentheses", "Lowercase Letters, Double Parentheses", "Lowercase Roman Numerals, Double Parentheses", "Capital Roman Numerals, Double Parentheses", "Cardinal Names, Period", "Ordinal Names, Period", "Numbers, Dash"]
    static let bulletSamples = ["", "•", "○", "◆", "◇", "-", "▪", "□", "▶", "→"]
    static let numberSamples = ["", "1.|2.|3.", "1st.|2nd.|3rd.", "a.|b.|c.", "A.|B.|C.", "i.|ii.|iii.", "I.|II.|III.", "1)|2)|3)", "a)|b)|c)", "A)|B)|C)", "i)|ii)|iii)", "I)|II)|III)", "(1)|(2)|(3)", "(A)|(B)|(C)", "(a)|(b)|(c)", "(i)|(ii)|(iii)", "(I)|(II)|(III)", "One.|Two.|Three.", "First.|Second.|Third.", "1-|2-|3-"]
    static func marker(numbered: Bool, index: Int) -> NSTextList.MarkerFormat? {
        if index == 0 { return nil }
        if !numbered { return .init(rawValue: ["", "{disc}", "{circle}", "◆", "◇", "-", "{square}", "□", "▶", "→"][index]) }
        let formats = [1: "{decimal}.", 3: "{lower-alpha}.", 4: "{upper-alpha}.", 5: "{lower-roman}.", 6: "{upper-roman}.", 7: "{decimal})", 8: "{lower-alpha})", 9: "{upper-alpha})", 10: "{lower-roman})", 11: "{upper-roman})", 12: "({decimal})", 13: "({upper-alpha})", 14: "({lower-alpha})", 15: "({lower-roman})", 16: "({upper-roman})", 19: "{decimal}-"]
        return formats[index].map { .init(rawValue: $0) }
    }
}

struct PaletteSwatch: Identifiable {
    let name: String
    let hex: UInt32
    var id: UInt32 { hex }
    var color: NSColor { NSColor(srgbRed: Double((hex >> 16) & 255) / 255, green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255, alpha: 1) }
}

enum RibbonPalette {
    static let highlightNames = ["Dark Yellow", "Green", "Aqua", "Purple", "Light Blue", "Red", "Light Blue", "Sky Blue", "Light Green", "Lavender", "Rose", "Light Yellow", "Grey", "Dark Grey", "Tan", "Dark Yellow", "Dark Green", "Dark Teal", "Plum", "Dark Blue", "Dark Yellow", "Dark Green", "Teal", "Dark Purple", "Dark Teal", "Blue-Grey", "Dark Red", "Dark Green", "Dark Purple", "Black", "Blue-Grey", "Dark Red", "Dark Green", "Purple", "Brown", "Dark Blue", "Dark Red", "Dark Green", "Dark Purple", "Brown"]
    static let highlightHex: [UInt32] = [0x4d4d00,0x004d00,0x004040,0x9900aa,0x849eff,0xdd0000,0xccd8ff,0x008080,0x009900,0xff77ff,0xffaaaa,0x808000,0x484d48,0x383838,0xf5f5f5,0x404000,0x003300,0x004d60,0x800040,0x003366,0x664000,0x303d14,0x006666,0x6600bb,0x00556b,0x202d48,0x4d2525,0x242e14,0x4d3655,0x402000,0x293f60,0x663333,0x303820,0x604069,0x553000,0x31577f,0x883c3c,0x3b4d26,0x734c7f,0x663300]
    static var highlight: [PaletteSwatch] { zip(highlightNames, highlightHex).map { PaletteSwatch(name: $0, hex: $1) } }
    static let themeNames = ["Dark Grey", "Tan", "Dark Grey", "Ice Blue", "Blue", "Brown", "Red", "Dark Yellow", "Lavender", "Dark Green"]
    static let themeHex: [[UInt32]] = [
        [0x202020,0xeeeeee,0x202020,0xb8cad8,0x367db5,0xb94b00,0xe85f3b,0x665000,0xaa99c4,0x507d33],
        [0x101010,0x555555,0x5c5353,0x384963,0x154867,0x663000,0x662200,0x4d4000,0x563965,0x26451c],
        [0x333333,0x777777,0x777171,0x53697e,0x1d5d83,0x994000,0x993300,0x665000,0x795393,0x365b27],
        [0x4d4d4d,0xaaaaaa,0xaaa5a5,0x7b94ab,0x2881b5,0xcc5500,0xcc4422,0x806400,0xa277b8,0x4d7d35],
        [0x555555,0xdddddd,0xeeeeee,0xaec5d8,0x78b9e6,0xffad77,0xff9977,0xb38b00,0xd4b9e2,0x92ba73],
        [0x777777,0xffffff,0xfefefe,0xe2edf5,0xb8def7,0xffd4b3,0xffd1cc,0xffd500,0xeee5f4,0xc6e3ae]]
    static let standardHex: [UInt32] = [0xff6666,0xff0000,0x804000,0x806000,0x507d26,0x008840,0x008080,0x00aaff,0x66ccff,0xaa77cc]
    static let paperNames = ["Blue", "Teal", "Green", "Red", "Blue Mist", "Cyan", "Apple", "Red Chalk", "Purple Mist", "Silver", "Lemon Lime", "Tan", "Purple", "Magenta", "Yellow", "Orange"]
    static let paperHex: [UInt32] = [0x061521,0x04100f,0x091c14,0x300606,0x101529,0x07120f,0x101608,0x290a08,0x15132a,0x101018,0x141707,0x251a10,0x21101f,0x27071f,0x211906,0x251400]
}


@MainActor struct NativeListGallery: View {
    let numbered: Bool
    let shell: NativeShellState
    let dismiss: () -> Void
    var body: some View {
        let names = numbered ? ListGalleryCatalog.numbering : ListGalleryCatalog.bullets
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(75), spacing: 10), count: 5), spacing: 10) {
            ForEach(names.indices, id: \.self) { index in
                Button {
                    shell.format(numbered ? "Numbering" : "Bulletpoints"); dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 5) {
                        if index == 0 { Text("None").frame(maxWidth: .infinity, maxHeight: .infinity) }
                        else { ForEach(0..<3) { row in HStack(spacing: 3) {
                            Text(numbered ? ListGalleryCatalog.numberSamples[index].components(separatedBy: "|")[row] : ListGalleryCatalog.bulletSamples[index]).font(.system(size: 14)).fixedSize()
                            Rectangle().fill(.primary.opacity(0.65)).frame(height: 1)
                        } } }
                    }.padding(5).frame(width: 65, height: 65).background(.primary.opacity(0.06)).contentShape(Rectangle())
                }.buttonStyle(.plain).disabled(!shell.canPerform("Bulletpoints") || (numbered ? index != 1 : ![1, 5].contains(index))).help(names[index]).accessibilityLabel(names[index])
            }
        }.padding(10)
    }
}

@MainActor struct NativeColourGallery: View {
    let kind: String
    private func grid(_ swatches: [PaletteSwatch], columns: Int, size: Double) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(size), spacing: 2), count: columns), spacing: 2) {
            ForEach(Array(swatches.enumerated()), id: \.offset) { _, swatch in
                Button {} label: { Rectangle().fill(Color(nsColor: swatch.color)).frame(width: size, height: size).overlay(Rectangle().stroke(.primary.opacity(0.2))) }.buttonStyle(.plain).disabled(true).help(swatch.name + " • unavailable for Markdown").accessibilityLabel(swatch.name)
            }
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(kind == "font" ? "Automatic" : kind == "paper" ? "No Color" : "No Colour") {}.disabled(true)
            if kind == "highlight" { grid(RibbonPalette.highlight, columns: 5, size: 24) }
            else if kind == "paper" { grid(zip(RibbonPalette.paperNames, RibbonPalette.paperHex).map { PaletteSwatch(name: $0, hex: $1) }, columns: 4, size: 40) }
            else {
                Text("Theme Colours")
                grid(RibbonPalette.themeHex.enumerated().flatMap { row, values in values.enumerated().map { column, hex in PaletteSwatch(name: row == 0 ? RibbonPalette.themeNames[column] : "\(RibbonPalette.themeNames[column]) shade \(row)", hex: hex) } }, columns: 10, size: 16)
                Text("Standard Colours")
                grid(RibbonPalette.standardHex.enumerated().map { PaletteSwatch(name: ["Rose", "Red", "Brown", "Dark Yellow", "Dark Green", "Dark Green", "Dark Teal", "Blue", "Light Blue", "Lavender"][$0], hex: $1) }, columns: 10, size: 16)
                Divider(); Button("More Colours…") {}.disabled(true)
            }
            Text("Rich text colour is unavailable in Markdown.").font(.caption).foregroundStyle(.secondary)
        }.font(.system(size: 13)).padding(10)
    }
}

@MainActor struct NativeTableGallery: View {
    let shell: NativeShellState
    let dismiss: () -> Void
    @State private var rows = 0
    @State private var columns = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(rows == 0 ? "Insert Table" : "\(columns) × \(rows) Table")
            VStack(spacing: 4) { ForEach(1...8, id: \.self) { row in HStack(spacing: 4) { ForEach(1...10, id: \.self) { column in
                Button { shell.mode = .write; shell.editor.insertTable(rows: row, columns: column); dismiss() } label: {
                    Rectangle().fill(row <= rows && column <= columns ? Color.accentColor.opacity(0.3) : .clear).frame(width: 17, height: 17).border(.secondary).contentShape(Rectangle())
                }.buttonStyle(.plain).onHover { if $0 { rows = row; columns = column } }.disabled(!shell.canPerform("Table")).accessibilityLabel("table with \(column) columns, \(row) rows")
            } } } }
        }.padding(15)
    }
}

struct NativePaperGallery: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rule Lines")
            HStack(spacing: 12) { ForEach(Array(InterfaceCatalog.paperStyles.prefix(5).enumerated()), id: \.offset) { index, name in sample(name, index: index) } }
            Text("Grid Lines")
            HStack(spacing: 12) { ForEach(Array(InterfaceCatalog.paperStyles.suffix(4).enumerated()), id: \.offset) { index, name in sample(name, index: index + 5) } }
            Divider()
            Menu("Rule Line Colour") { ForEach(["<none>", "Light Blue", "Blue", "Yellow", "Green", "Red", "Purple", "Cyan", "Orange", "Magenta", "Blue Mist", "Purple Mist", "Tan", "Lemon Lime", "Apple", "Teal", "Red Chalk", "Silver"], id: \.self) { Text($0) } }
            Button("Always Create Pages with Rule Lines") {}.disabled(true)
            Text("Paper ruling is unavailable in Markdown.").font(.caption).foregroundStyle(.secondary)
        }.padding(10)
    }
    private func sample(_ name: String, index: Int) -> some View {
        Button {} label: {
            Canvas { context, size in
                if index == 0 { context.draw(Text("None").font(.system(size: 11)), at: CGPoint(x: size.width / 2, y: size.height / 2)) }
                else {
                    let spacing = index < 5 ? Double(index * 4 + 2) : Double((index - 3) * 4)
                    var path = Path()
                    for y in stride(from: spacing, to: size.height, by: spacing) { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y)) }
                    if index >= 5 { for x in stride(from: spacing, to: size.width, by: spacing) { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height)) } }
                    context.stroke(path, with: .color(.blue), lineWidth: 0.8)
                }
            }.frame(width: 44, height: 44).border(.primary.opacity(0.5))
        }.buttonStyle(.plain).disabled(true).accessibilityLabel(name).help(name)
    }
}
