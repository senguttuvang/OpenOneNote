import Foundation
import Markdown
import SwiftSoup

public struct MarkdownConversion: Sendable {
    public init() {}

    public func parse(_ source: String) throws -> NoteDocument {
        let warnings: [String] = []
        func convert(_ node: any Markup) throws -> NoteNode {
            let children = try node.children.map { try convert($0) }
            func element(_ tag: String, _ attributes: [String: String] = [:]) -> NoteNode { .element(tag, attributes, children) }
            switch node {
            case let text as Markdown.Text: return .text(text.string)
            case let heading as Heading: return element("h\(heading.level)")
            case is Paragraph: return element("p")
            case is Strong: return element("strong")
            case is Emphasis: return element("em")
            case is Strikethrough: return element("s")
            case let link as Markdown.Link:
                guard let target = link.destination, Self.safeLink(target) else { throw NotesError.invalid("Unsafe link destination") }
                if Self.safeAsset(target) {
                    return .element("object", ["data": target, "data-attachment": link.plainText, "type": "application/octet-stream"], [])
                }
                return element("a", ["href": target])
            case let image as Markdown.Image:
                guard let target = image.source, Self.safeAsset(target) else { throw NotesError.invalid("Images must use local .assets paths") }
                return .element("img", ["src": target, "alt": image.plainText], [])
            case let code as InlineCode: return .element("code", [:], [.text(code.code)])
            case let code as CodeBlock:
                return .element("pre", ["language": code.language ?? ""], [.text(code.code)])
            case is UnorderedList: return element("ul")
            case let list as OrderedList: return element("ol", ["start": String(list.startIndex)])
            case is ListItem: return element("li")
            case is BlockQuote: return element("blockquote")
            case is ThematicBreak: return .element("hr", [:], [])
            case is SoftBreak: return .text(" ")
            case is LineBreak: return .element("br", [:], [])
            case is Table: return element("table")
            case is Table.Head: return .element("tr", [:], children)
            case is Table.Body: return .element("tbody", [:], children)
            case is Table.Row: return element("tr")
            case is Table.Cell: return element("td")
            case is HTMLBlock, is InlineHTML:
                throw NotesError.unsupported("Raw HTML cannot be synced. Use Markdown or keep the original remote object unchanged.")
            default: throw NotesError.unsupported("Unsupported Markdown structure: \(type(of: node))")
            }
        }
        return NoteDocument(blocks: try Document(parsing: source).children.map { try convert($0) }, warnings: warnings)
    }

    public func html(_ document: NoteDocument) -> String { document.blocks.map(html).joined() }

    /// Source ranges use UTF-8 columns. Each retained slice is reparsed before use by reconciliation.
    public func rawBlocks(_ source: String) -> [String?] {
        let bytes = Array(source.utf8)
        var starts = [0]
        for (index, byte) in bytes.enumerated() where byte == 10 { starts.append(index + 1) }
        return Document(parsing: source).children.map { node in
            guard let range = node.range, range.lowerBound.line > 0, range.upperBound.line > 0,
                  range.lowerBound.line <= starts.count, range.upperBound.line <= starts.count else { return nil }
            let lower = starts[range.lowerBound.line - 1] + range.lowerBound.column - 1
            let upper = starts[range.upperBound.line - 1] + range.upperBound.column - 1
            guard lower >= 0, upper >= lower, upper <= bytes.count else { return nil }
            return String(bytes: bytes[lower..<upper], encoding: .utf8)
        }
    }

    public func html(_ node: NoteNode) -> String {
        switch node {
        case .text(let value): return Self.escape(value)
        case .element(let tag, let attributes, let children):
            if tag == "pre" {
                return "<pre>" + Self.escape(node.text) + "</pre>"
            }
            let attrs = attributes.filter { ["href", "src", "alt", "start", "data", "type", "data-attachment"].contains($0.key) }
                .sorted { $0.key < $1.key }.map { " \($0.key)=\"\(Self.escape($0.value))\"" }.joined()
            if ["img", "br", "hr"].contains(tag) { return "<\(tag)\(attrs) />" }
            return "<\(tag)\(attrs)>" + children.map(html).joined() + "</\(tag)>"
        }
    }

    public func markdown(_ document: NoteDocument) -> String {
        document.blocks.map { markdown($0, block: true) }.joined(separator: "\n\n") + (document.blocks.isEmpty ? "" : "\n")
    }

    private func markdown(_ node: NoteNode, block: Bool = false) -> String {
        switch node {
        case .text(let value):
            return value.reduce("") { result, character in result + ("\\`*_[]<>|".contains(character) ? "\\" : "") + String(character) }
        case .element(let tag, let attrs, let children):
            let inner = children.map { markdown($0) }.joined()
            switch tag {
            case "h1", "h2", "h3", "h4", "h5", "h6": return String(repeating: "#", count: Int(tag.dropFirst()) ?? 1) + " " + inner
            case "p": return inner
            case "strong": return "**\(inner)**"
            case "em": return "*\(inner)*"
            case "s": return "~~\(inner)~~"
            case "a": return "[\(inner)](<\(attrs["href"] ?? "")>)"
            case "img": return "![\(Self.markdownLabel(attrs["alt"] ?? "Image"))](\(attrs["src"] ?? ""))"
            case "object": return "[\(Self.markdownLabel(attrs["data-attachment"] ?? "Attachment"))](\(attrs["data"] ?? ""))"
            case "code":
                let fence = String(repeating: "`", count: max(1, Self.longestTicks(node.text) + 1))
                return fence + " " + node.text + " " + fence
            case "pre":
                let fence = String(repeating: "`", count: max(3, Self.longestTicks(node.text) + 1))
                return fence + (attrs["language"] ?? "") + "\n" + node.text + (node.text.hasSuffix("\n") ? "" : "\n") + fence
            case "br": return "  \n"
            case "hr": return "---"
            case "blockquote": return children.map { markdown($0, block: true).split(separator: "\n", omittingEmptySubsequences: false).map { "> " + $0 }.joined(separator: "\n") }.joined(separator: "\n>\n")
            case "ul", "ol":
                return children.enumerated().map { index, item in
                    let prefix = tag == "ol" ? "\((Int(attrs["start"] ?? "1") ?? 1) + index). " : "- "
                    let lines = markdown(item).split(separator: "\n", omittingEmptySubsequences: false)
                    return prefix + lines.enumerated().map { $0.offset == 0 ? String($0.element) : String(repeating: " ", count: prefix.count) + $0.element }.joined(separator: "\n")
                }.joined(separator: "\n")
            case "li": return children.map { markdown($0, block: true) }.joined(separator: "\n")
            case "table":
                let rows = flattenRows(children)
                guard let first = rows.first else { return "" }
                let width = first.count
                let header = "| " + first.joined(separator: " | ") + " |"
                return ([header, "| " + Array(repeating: "---", count: width).joined(separator: " | ") + " |"] + rows.dropFirst().map { "| " + $0.joined(separator: " | ") + " |" }).joined(separator: "\n")
            default: return inner
            }
        }
    }

    private func flattenRows(_ nodes: [NoteNode]) -> [[String]] {
        nodes.flatMap { node -> [[String]] in
            guard case .element(let tag, _, let children) = node else { return [] }
            if tag == "tr" { return [children.map { markdown($0).replacingOccurrences(of: "\n", with: " ") }] }
            return flattenRows(children)
        }
    }
    public static func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "\"", with: "&quot;")
    }
    public static func safeLink(_ value: String) -> Bool {
        guard !value.contains(where: { $0.isNewline || $0.asciiValue == 0 }), let components = URLComponents(string: value) else { return false }
        if safeAsset(value) { return true }
        guard ["https", "http", "mailto", "onenote"].contains(components.scheme?.lowercased() ?? ""), components.user == nil, components.password == nil else { return false }
        return !(components.queryItems ?? []).contains {
            let name = $0.name.lowercased()
            return name.contains("token") || name.contains("auth") || ["sig", "signature", "code", "apikey", "api_key"].contains(name)
        }
    }
    public static func safeAsset(_ value: String) -> Bool {
        value.hasPrefix(".assets/") && value.count > 8 && value.split(separator: "/", omittingEmptySubsequences: false).count == 2 &&
        !value.contains("..") && value.dropFirst(8).allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || ".-_".contains($0)) }
    }
    private static func markdownLabel(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "[", with: "\\[").replacingOccurrences(of: "]", with: "\\]").replacingOccurrences(of: "\n", with: " ")
    }
    private static func longestTicks(_ value: String) -> Int {
        var longest = 0; var run = 0
        for character in value { run = character == "`" ? run + 1 : 0; longest = max(longest, run) }
        return longest
    }
}
