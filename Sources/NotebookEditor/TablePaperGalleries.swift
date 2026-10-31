import SwiftUI

@MainActor struct TableGrid: View {
    @ObservedObject var formatting: EditorFormatting
    let dismiss: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Insert Table")
            VStack(spacing: 4) { ForEach(1...8, id: \.self) { row in HStack(spacing: 4) { ForEach(1...10, id: \.self) { column in
                Button { formatting.target?.insertTable(rows: row, columns: column); dismiss() } label: { Rectangle().stroke(.primary.opacity(0.6)).frame(width: 17, height: 17).contentShape(Rectangle()) }.buttonStyle(.plain).disabled(!formatting.available || formatting.inTable).accessibilityLabel("table with \(column) columns, \(row) rows")
            } } } }
        }.padding(15).background(PaperPalette.canvas)
    }
}

@MainActor struct PaperGallery: View {
    @ObservedObject var commands: EditorCommands
    let dismiss: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rule Lines")
            HStack(spacing: 12) { ForEach(Array(InterfaceCatalog.paperStyles.prefix(5).enumerated()), id: \.offset) { index, name in sample(name, index: index) } }
            Text("Grid Lines")
            HStack(spacing: 12) { ForEach(Array(InterfaceCatalog.paperStyles.suffix(4).enumerated()), id: \.offset) { index, name in sample(name, index: index + 5) } }
            Divider()
            Menu("Rule Line Colour") { ForEach(["<none>", "Light Blue", "Blue", "Yellow", "Green", "Red", "Purple", "Cyan", "Orange", "Magenta", "Blue Mist", "Purple Mist", "Tan", "Lemon Lime", "Apple", "Teal", "Red Chalk", "Silver"], id: \.self) { Text($0) } }
            Button("Always Create Pages with Rule Lines") {}.disabled(true)
        }.padding(10).background(PaperPalette.canvas)
    }
    private func sample(_ name: String, index: Int) -> some View {
        Button { commands.perform(name); dismiss() } label: {
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
        }.buttonStyle(.plain).accessibilityLabel(name).help(name)
    }
}
