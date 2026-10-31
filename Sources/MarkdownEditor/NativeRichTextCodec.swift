import AppKit
import MarkdownNotes

/// A reversible presentation of the portable tree. No HTML import, network loading,
/// or RTF conversion participates in document persistence.
@MainActor public enum NativeRichTextCodec {
    static let block = NSAttributedString.Key("O2NBlock")
    static let raw = NSAttributedString.Key("O2NRetainedSource")
    static let retainedID = NSAttributedString.Key("O2NRetainedBlock")
    static let code = NSAttributedString.Key("O2NInlineCode")
    static let bold = NSAttributedString.Key("O2NInlineBold")
    static let listPrefix = NSAttributedString.Key("O2NListPrefix")
    static let listMarker = NSAttributedString.Key("O2NListMarker")
    public static var body: [NSAttributedString.Key: Any] {
        [.font: NSFont(name: "Calibri", size: 18) ?? NSFont.systemFont(ofSize: 18), .foregroundColor: NSColor.textColor]
    }
    public static func render(_ source: String) throws -> NSAttributedString {
        let conversion = MarkdownConversion()
        let document: NoteDocument
        do { document = try conversion.parse(source) }
        catch {
            var attributes = body; attributes[raw] = source; attributes[retainedID] = 0
            return NSAttributedString(string: "Content preserved — open Markdown to edit.\n", attributes: attributes)
        }
        let slices = conversion.rawBlocks(source)
        let result = NSMutableAttributedString()
        for (index, node) in document.blocks.enumerated() {
            if !supported(node) {
                var attributes = body
                attributes[raw] = index < slices.count ? (slices[index] ?? conversion.markdown(NoteDocument(blocks: [node]))) : conversion.markdown(NoteDocument(blocks: [node]))
                attributes[retainedID] = index
                attributes[.foregroundColor] = NSColor.secondaryLabelColor
                let label = node.text.isEmpty ? "Preserved content — edit with Markdown" : node.text.trimmingCharacters(in: .newlines)
                result.append(NSAttributedString(string: label + "\n", attributes: attributes))
            } else { append(node, to: result, attributes: body) }
        }
        return result
    }
    private static func supported(_ node: NoteNode) -> Bool {
        guard case .element(let tag, _, let children) = node else { return true }
        if tag == "li" {
            if !children.isEmpty {
                guard children.count == 1, case .element("p", _, _) = children[0] else { return false }
            }
        }
        return ["p", "h1", "h2", "h3", "h4", "h5", "h6", "strong", "em", "s", "a", "code", "br", "ul", "ol", "li", "table", "tr", "tbody", "td"].contains(tag) && children.allSatisfy(supported)
    }
    private static func append(_ node: NoteNode, to result: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any]) {
        guard case .element(let tag, let metadata, let children) = node else {
            result.append(NSAttributedString(string: node.text, attributes: attributes)); return
        }
        var next = attributes
        if tag == "li", children.isEmpty {
            next[block] = "p"; result.append(NSAttributedString(string: "\n", attributes: next)); return
        }
        if tag == "ul" || tag == "ol" {
            for (index, child) in children.enumerated() {
                var item = attributes
                item[listPrefix] = tag == "ul" ? "- " : "\((Int(metadata["start"] ?? "1") ?? 1) + index). "
                let style = NSMutableParagraphStyle(); style.headIndent = 24; style.firstLineHeadIndent = 8
                style.textLists = [NSTextList(markerFormat: tag == "ul" ? .disc : .decimal, options: 0)]
                item[.paragraphStyle] = style
                var marker = item; marker[listMarker] = true
                result.append(NSAttributedString(string: tag == "ul" ? "•\t" : "\((Int(metadata["start"] ?? "1") ?? 1) + index).\t", attributes: marker))
                append(child, to: result, attributes: item)
            }
            return
        }
        if tag == "table" {
            appendTable(children, to: result, attributes: attributes); return
        }
        let font = next[.font] as? NSFont ?? NSFont.systemFont(ofSize: 18)
        if tag == "strong" { next[bold] = true; next[.font] = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask) }
        if tag == "em" { next[.font] = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask) }
        if tag == "s" { next[.strikethroughStyle] = NSUnderlineStyle.single.rawValue }
        if tag == "a" { next[.link] = metadata["href"]; next[.foregroundColor] = NSColor.linkColor }
        if tag == "code" { next[code] = true; next[.font] = NSFont.monospacedSystemFont(ofSize: 16, weight: .regular) }
        let paragraph = tag == "p" || tag.hasPrefix("h")
        if paragraph {
            next[block] = tag
            let style = NSMutableParagraphStyle(); style.paragraphSpacing = 12
            if tag != "p" {
                let level = Int(tag.dropFirst()) ?? 1
                next[.font] = NSFont.systemFont(ofSize: CGFloat(30 - level * 2), weight: .semibold)
                next[.foregroundColor] = NSColor.systemBlue
            }
            if next[listPrefix] == nil && (next[.paragraphStyle] as? NSParagraphStyle)?.textBlocks.isEmpty != false { next[.paragraphStyle] = style }
        }
        if tag == "br" { result.append(NSAttributedString(string: "\u{2028}", attributes: next)) }
        else { for child in children { append(child, to: result, attributes: next) } }
        if paragraph { result.append(NSAttributedString(string: "\n", attributes: next)) }
    }
    public static func markdown(_ rich: NSAttributedString) -> String {
        let text = rich.string as NSString
        var position = 0
        var blocks: [String] = []
        let conversion = MarkdownConversion()
        var previousList = false
        var activeTable: NSTextTable?
        var tableRows: [[String]] = []
        func flushTable() {
            guard let header = tableRows.first else { return }
            blocks.append(([header, Array(repeating: "---", count: header.count)] + Array(tableRows.dropFirst())).map { "| " + $0.joined(separator: " | ") + " |" }.joined(separator: "\n"))
            tableRows = []; activeTable = nil
        }
        while position < text.length {
            let range = text.paragraphRange(for: NSRange(location: position, length: 0))
            let attributes = rich.attributes(at: position, effectiveRange: nil)
            let cell = (attributes[.paragraphStyle] as? NSParagraphStyle)?.textBlocks.first as? NSTextTableBlock
            if cell?.table !== activeTable { flushTable() }
            if let retained = attributes[raw] as? String {
                blocks.append(retained); previousList = false
                var retainedRange = NSRange()
                _ = rich.attribute(retainedID, at: position, effectiveRange: &retainedRange)
                position = NSMaxRange(retainedRange)
                continue
            }
            else {
                var content = range
                while content.length > 0 && [10, 13].contains(text.character(at: NSMaxRange(content) - 1)) { content.length -= 1 }
                var nodes: [NoteNode] = []
                rich.enumerateAttributes(in: content) { values, span, _ in
                    if values[listMarker] as? Bool == true { return }
                    let string = text.substring(with: span)
                    var node: NoteNode = string.contains("\u{2028}")
                        ? .element("p", [:], string.components(separatedBy: "\u{2028}").enumerated().flatMap { index, part -> [NoteNode] in
                            (index == 0 ? [] : [.element("br", [:], [])]) + [.text(part)]
                        }) : .text(string)
                    if values[code] as? Bool == true { node = .element("code", [:], [node]) }
                    else if let font = values[.font] as? NSFont {
                        let traits = NSFontManager.shared.traits(of: font)
                        if traits.contains(.italicFontMask) { node = .element("em", [:], [node]) }
                        if values[bold] as? Bool == true || traits.contains(.boldFontMask) && (values[block] as? String ?? "p") == "p" { node = .element("strong", [:], [node]) }
                    }
                    if (values[.strikethroughStyle] as? Int ?? 0) != 0 { node = .element("s", [:], [node]) }
                    if let url = values[.link] {
                        let destination = (url as? URL)?.absoluteString ?? (url as? String ?? "")
                        node = .element("a", ["href": destination], [node])
                    }
                    appendCoalescing(node, to: &nodes)
                }
                let value = conversion.markdown(NoteDocument(blocks: [.element(attributes[block] as? String ?? "p", [:], nodes)])).trimmingCharacters(in: .newlines)
                if let cell {
                    previousList = false
                    activeTable = cell.table
                    while tableRows.count <= cell.startingRow { tableRows.append([]) }
                    tableRows[cell.startingRow].append(value.replacingOccurrences(of: "\n", with: " "))
                } else if let prefix = attributes[listPrefix] as? String {
                    if previousList, !blocks.isEmpty { blocks[blocks.count - 1] += "\n" + prefix + value }
                    else { blocks.append(prefix + value) }
                    previousList = true
                } else { blocks.append(value); previousList = false }
            }
            position = NSMaxRange(range)
        }
        flushTable()
        return blocks.joined(separator: "\n\n") + (blocks.isEmpty ? "" : "\n")
    }
    private static func appendCoalescing(_ node: NoteNode, to nodes: inout [NoteNode]) {
        guard let last = nodes.last else { nodes.append(node); return }
        if case .text(let first) = last, case .text(let second) = node {
            nodes[nodes.count - 1] = .text(first + second)
        } else if case .element(let tag, let attributes, var children) = last,
                  case .element(let nextTag, let nextAttributes, let nextChildren) = node,
                  tag == nextTag, attributes == nextAttributes, ["strong", "em", "s", "a", "code"].contains(tag) {
            for child in nextChildren { appendCoalescing(child, to: &children) }
            nodes[nodes.count - 1] = .element(tag, attributes, children)
        } else { nodes.append(node) }
    }
    private static func appendTable(_ nodes: [NoteNode], to result: NSMutableAttributedString, attributes: [NSAttributedString.Key: Any]) {
        func rows(_ nodes: [NoteNode]) -> [[NoteNode]] {
            nodes.flatMap { node -> [[NoteNode]] in
                guard case .element(let tag, _, let children) = node else { return [] }
                return tag == "tr" ? [children] : rows(children)
            }
        }
        let content = rows(nodes)
        let table = NSTextTable(); table.numberOfColumns = content.first?.count ?? 1
        for (row, cells) in content.enumerated() {
            for (column, node) in cells.enumerated() {
                let cell = NSTextTableBlock(table: table, startingRow: row, rowSpan: 1, startingColumn: column, columnSpan: 1)
                cell.setBorderColor(.separatorColor); cell.setWidth(0.5, type: .absoluteValueType, for: .border)
                cell.setWidth(8, type: .absoluteValueType, for: .padding)
                cell.setContentWidth(220, type: .absoluteValueType)
                let style = NSMutableParagraphStyle(); style.textBlocks = [cell]
                var next = attributes; next[.paragraphStyle] = style; next[block] = "p"
                append(node, to: result, attributes: next)
                result.append(NSAttributedString(string: "\n", attributes: next))
            }
        }
    }
}
