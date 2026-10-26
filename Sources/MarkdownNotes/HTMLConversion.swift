import Foundation
import SwiftSoup

public struct RemoteBlock: Equatable, Sendable {
    public var target: String
    public var container: String
    public var node: NoteNode
    public var editable: Bool
}

public struct RemoteDocument: Equatable, Sendable {
    public var blocks: [RemoteBlock]
    public var warnings: [String]
    public var document: NoteDocument { NoteDocument(blocks: blocks.map(\.node), warnings: warnings) }
}

public struct HTMLConversion: Sendable {
    public init() {}
    /// Resources must be materialized first. No authenticated URLs enter portable Markdown.
    public func decode(_ html: String, resources: [String: String] = [:]) throws -> RemoteDocument {
        guard html.utf8.count <= 16 * 1024 * 1024 else { throw NotesError.invalid("Page HTML exceeds 16 MiB") }
        let document = try SwiftSoup.parse(html)
        guard let body = document.body() else { throw NotesError.invalid("Page body missing") }
        var blocks: [RemoteBlock] = []; var warnings: [String] = []
        let supported = Set(["p", "h1", "h2", "h3", "h4", "h5", "h6", "strong", "b", "em", "i", "s", "strike", "a", "br", "hr", "pre", "code", "ul", "ol", "li", "table", "tbody", "thead", "tr", "th", "td", "img", "object", "span", "div", "blockquote"])
        func convert(_ node: Node, editable: inout Bool) throws -> [NoteNode] {
            if let text = node as? TextNode { return [.text(text.getWholeText())] }
            guard let element = node as? Element else { return [] }
            let tag = element.tagName().lowercased()
            let tagged = try element.attr("data-tag")
            let rendered = try element.attr("data-render-src")
            if !supported.contains(tag) || !tagged.isEmpty || !rendered.isEmpty {
                editable = false; warnings.append("Unsupported remote structure retained on server: \(tag)")
                if !supported.contains(tag) {
                    return [.element("p", [:], [.text(try element.text() + " [Unsupported \(tag) retained remotely]")])]
                }
            }
            if ["script", "style"].contains(tag) { editable = false; return [.text("[Unsupported \(tag) retained remotely]")] }
            var attrs: [String: String] = [:]
            if tag == "a" {
                let href = try element.attr("href")
                guard MarkdownConversion.safeLink(href) else {
                    editable = false; return [.text(try element.text() + " [unsafe link retained remotely]")]
                }
                attrs["href"] = href
            }
            if tag == "img" || tag == "object" {
                let full = try element.attr("data-fullres-src")
                let source = full.isEmpty ? try element.attr(tag == "img" ? "src" : "data") : full
                guard let local = resources[source], MarkdownConversion.safeAsset(local) else {
                    editable = false; warnings.append("Resource unavailable; original remote object protected")
                    return [.text("[Remote \(tag) unavailable locally; retained on server]")]
                }
                attrs[tag == "img" ? "src" : "data"] = local
                attrs["alt"] = try element.attr("alt")
                if tag == "object" {
                    attrs["data-attachment"] = try element.attr("data-attachment")
                    attrs["type"] = try element.attr("type")
                }
                return [.element(tag, attrs, [])]
            }
            if tag == "ol" { attrs["start"] = (try element.attr("start")).isEmpty ? "1" : try element.attr("start") }
            if tag == "pre" {
                func rawText(_ node: Node) -> String {
                    if let text = node as? TextNode { return text.getWholeText() }
                    return node.getChildNodes().map(rawText).joined()
                }
                return [.element("pre", ["language": ""], [.text(rawText(element))])]
            }
            var children = try element.getChildNodes().flatMap { try convert($0, editable: &editable) }
            let styles = try element.attr("style").lowercased().split(separator: ";").map { $0.replacingOccurrences(of: " ", with: "") }
            if styles.contains("font-weight:bold") || styles.contains("font-weight:700") { children = [.element("strong", [:], children)] }
            if styles.contains("font-style:italic") { children = [.element("em", [:], children)] }
            if ["span", "div", "thead", "tbody"].contains(tag) { return children }
            let normalized = ["b": "strong", "i": "em", "strike": "s", "th": "td"][tag] ?? tag
            return [.element(normalized, attrs, children)]
        }
        func add(_ element: Element, container: String, outer: Bool) throws {
            let tag = element.tagName()
            let target = try element.attr("id")
            if tag == "div" {
                let children = element.children().array()
                let directText = element.getChildNodes().compactMap { ($0 as? TextNode)?.getWholeText() }.joined()
                if !directText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    var editable = false
                    let nodes = try convert(element, editable: &editable)
                    blocks.append(RemoteBlock(target: target, container: target, node: .element("p", [:], nodes), editable: false))
                } else { for child in children { try add(child, container: outer ? target : container, outer: false) } }
                return
            }
            var editable = !target.isEmpty && !outer
            let nodes = try convert(element, editable: &editable)
            if tag == "p", nodes.allSatisfy({ $0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { return }
            let node = nodes.count == 1 ? nodes[0] : NoteNode.element("div", [:], nodes)
            blocks.append(RemoteBlock(target: target, container: container, node: node, editable: editable))
        }
        let containers = body.children().array()
        if containers.count > 1 { warnings.append("Multiple containers linearized in DOM order; spatial reading order is not inferred.") }
        for child in containers { try add(child, container: "body", outer: true) }
        return RemoteDocument(blocks: blocks, warnings: Array(Set(warnings)).sorted())
    }

    public func resourceURLs(_ html: String) throws -> [String] {
        let document = try SwiftSoup.parse(html)
        return try document.select("img[src], object[data]").array().map {
            let full = try $0.attr("data-fullres-src")
            return full.isEmpty ? try $0.attr($0.tagName() == "img" ? "src" : "data") : full
        }
    }

    /// Conservative change plan: preserve every unsupported object and all outer containers.
    /// Changed ranges replace an existing supported child; an empty paragraph represents deletion.
    public func commands(from remote: RemoteDocument, to desired: NoteDocument) throws -> [PageCommand] {
        let old = remote.blocks.map(\.node)
        let changes = SequenceMerge.edits(base: old, changed: desired.blocks)
        var commands: [PageCommand] = []
        let converter = MarkdownConversion()
        for edit in changes {
            if edit.range.isEmpty {
                if edit.range.lowerBound < remote.blocks.count {
                    let anchor = remote.blocks[edit.range.lowerBound]
                    guard anchor.editable else { throw NotesError.unsupported("Cannot insert beside a protected remote object") }
                    commands.append(PageCommand(target: anchor.target, action: "insert", position: "before", content: converter.html(NoteDocument(blocks: edit.replacement))))
                } else if let last = remote.blocks.last {
                    guard last.editable else { throw NotesError.unsupported("Cannot append beside a protected remote object") }
                    commands.append(PageCommand(target: last.target, action: "insert", position: "after", content: converter.html(NoteDocument(blocks: edit.replacement))))
                } else {
                    commands.append(PageCommand(target: "body", action: "append", content: converter.html(NoteDocument(blocks: edit.replacement))))
                }
            } else {
                let affected = remote.blocks[edit.range]
                guard affected.allSatisfy(\.editable) else { throw NotesError.unsupported("Edit overlaps a protected remote object. Original content retained.") }
                guard Set(affected.map(\.container)).count == 1 else { throw NotesError.unsupported("Edit spans multiple remote containers; explicit conversion is required.") }
                // One sibling group per replacement preserves order within the changed range.
                for (offset, block) in affected.enumerated() {
                    let content = offset == 0 ? converter.html(NoteDocument(blocks: edit.replacement)) : ""
                    commands.append(PageCommand(target: block.target, action: "replace", content: content.isEmpty ? "<p></p>" : "<div>" + content + "</div>"))
                }
            }
        }
        return commands
    }
}
