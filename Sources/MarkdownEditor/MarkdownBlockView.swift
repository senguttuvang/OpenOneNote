import AppKit
import SwiftUI
import MarkdownNotes

struct MarkdownBlockView: View {
    let node: NoteNode
    let vault: MarkdownVault
    var scale = 1.0
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        block(node)
    }
    private func inline(_ node: NoteNode) -> Text {
        switch node {
        case .text(let value): return Text(value)
        case .element(let tag, let attrs, let children):
            let text = children.reduce(Text("")) { $0 + inline($1) }
            switch tag {
            case "strong": return text.bold()
            case "em": return text.italic()
            case "s": return text.strikethrough()
            case "code": return Text(node.text).monospaced()
            case "br": return Text("\n")
            case "a":
                var attributed = AttributedString(node.text)
                if let href = attrs["href"], MarkdownConversion.safeLink(href) { attributed.link = URL(string: href) }
                return Text(attributed)
            default: return text
            }
        }
    }
    private func block(_ node: NoteNode) -> AnyView {
        guard case .element(let tag, let attrs, let children) = node else { return AnyView(inline(node).textSelection(.enabled)) }
        if tag == "img", let source = attrs["src"], let data = try? vault.asset(source), let image = NSImage(data: data) {
            return AnyView(Image(nsImage: image).resizable().scaledToFit().accessibilityLabel(attrs["alt"] ?? "Note image"))
        }
        if tag == "object", let path = attrs["data"], let url = try? vault.safeURL(path) {
            return AnyView(Link(destination: url) { Label(attrs["data-attachment"] ?? "Attachment", systemImage: "paperclip") })
        }
        if tag == "p", children.contains(where: { child in
            if case .element(let childTag, _, _) = child { return childTag == "img" || childTag == "object" }
            return false
        }) {
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(children.enumerated()), id: \.offset) { _, child in block(child) }
            })
        }
        if tag == "pre", attrs["language"] == "mermaid" { return AnyView(MermaidPreview(source: node.text)) }
        if tag == "table" { return table(node) }
        if tag == "pre" { return AnyView(Text(node.text).font(.system(size: 15, design: .monospaced)).textSelection(.enabled).padding(12).frame(maxWidth: .infinity, alignment: .leading).background(.quaternary, in: RoundedRectangle(cornerRadius: 8))) }
        if ["ul", "ol", "li", "blockquote", "table", "tbody", "tr", "div"].contains(tag) {
            if tag == "tr" {
                return AnyView(HStack(alignment: .top) { ForEach(Array(children.enumerated()), id: \.offset) { _, child in block(child).frame(maxWidth: .infinity, alignment: .leading) } }.padding(8).overlay(Rectangle().stroke(.separator, lineWidth: 1)))
            }
            return AnyView(VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(children.enumerated()), id: \.offset) { index, child in
                    HStack(alignment: .top, spacing: 10) {
                        if tag == "ul" { Image(systemName: "circle.fill").font(.system(size: 5)).padding(.top, 8) }
                        if tag == "ol" { Text("\((Int(attrs["start"] ?? "1") ?? 1) + index).") }
                        block(child)
                    }
                }
            })
        }
        let heading = ["h1", "h2", "h3", "h4", "h5", "h6"].contains(tag)
        let size = tag == "h1" ? 26.0 : tag == "h2" ? 22.0 : heading ? 20.0 : 18.6666667
        let font = Font(NSFont(name: "Calibri", size: size * scale) ?? .systemFont(ofSize: size * scale))
        if tag == "hr" { return AnyView(Divider()) }
        return AnyView(inline(node).font(font).foregroundStyle(heading ? NativePalette(scheme).link : .primary).lineSpacing(2).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading))
    }
    private func table(_ node: NoteNode) -> AnyView {
        func rows(_ value: NoteNode) -> [NoteNode] {
            guard case .element(let tag, _, let children) = value else { return [] }
            return tag == "tr" ? [value] : children.flatMap(rows)
        }
        let rows = rows(node)
        let cells = rows.map { row -> [NoteNode] in if case .element(_, _, let children) = row { return children }; return [] }
        let count = cells.map(\.count).max() ?? 0
        let font = NSFont(name: "Calibri", size: 18.6666667 * scale) ?? .systemFont(ofSize: 18.6666667 * scale)
        let widths = (0..<count).map { column in
            min(460 * scale, max(90 * scale, cells.map { column < $0.count ? ($0[column].text as NSString).size(withAttributes: [.font: font]).width * 1.15 + 16 : 0 }.max() ?? 90))
        }
        return AnyView(ScrollView(.horizontal) { VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(cells.enumerated()), id: \.offset) { row, values in
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(values.enumerated()), id: \.offset) { column, cell in
                        inline(cell).font(Font(font)).fontWeight(row == 0 ? .bold : .regular)
                            .textSelection(.enabled).padding(.horizontal, 5).padding(.vertical, 3)
                            .frame(width: widths[column], height: tableRowHeight(values, widths: widths, font: font), alignment: .leading)
                            .overlay(Rectangle().stroke(.secondary.opacity(0.6), lineWidth: 0.5))
                    }
                }
            }
        } }.fixedSize(horizontal: false, vertical: true))
    }
    private func tableRowHeight(_ cells: [NoteNode], widths: [Double], font: NSFont) -> Double {
        max(29 * scale, cells.enumerated().map { index, cell in
            (cell.text as NSString).boundingRect(with: NSSize(width: widths[index] - 12, height: 10_000), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font]).height + 8
        }.max() ?? 29 * scale)
    }
}
