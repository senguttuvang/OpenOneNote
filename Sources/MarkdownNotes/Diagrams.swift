import Foundation

public protocol DiagramRendering: Sendable {
    func png(source: String) async throws -> Data
}

public enum DiagramSource {
    public static func filename(sourceHash: String, previewHash: String) -> String {
        "o2n-diagram-\(sourceHash)-\(previewHash).mmd"
    }
    public static func hashes(filename: String) -> (source: String, preview: String)? {
        guard filename.hasPrefix("o2n-diagram-"), filename.hasSuffix(".mmd") else { return nil }
        let parts = filename.dropFirst(12).dropLast(4).split(separator: "-")
        guard parts.count == 2, parts.allSatisfy({ $0.count == 64 && $0.allSatisfy(\.isHexDigit) }) else { return nil }
        return (String(parts[0]), String(parts[1]))
    }
    public static func source(_ node: NoteNode) -> String? {
        if case .element("pre", let attrs, _) = node, attrs["language"] == "mermaid" { return node.text }
        return nil
    }
    public static func recover(_ document: RemoteDocument, vault: MarkdownVault) throws -> RemoteDocument {
        var result = document; result.blocks = []
        var index = 0
        while index < document.blocks.count {
            let image = document.blocks[index]
            if index + 1 < document.blocks.count,
               case .element("img", let imageAttributes, _) = image.node,
               case .element("object", let sourceAttributes, _) = document.blocks[index + 1].node,
               let filename = sourceAttributes["data-attachment"], let hashes = hashes(filename: filename),
               let sourcePath = sourceAttributes["data"], let previewPath = imageAttributes["src"] {
                let sourceBytes = try vault.asset(sourcePath)
                let previewBytes = try vault.asset(previewPath)
                if MarkdownVault.hash(sourceBytes) == hashes.source,
                   MarkdownVault.hash(previewBytes) == hashes.preview,
                   let source = String(data: sourceBytes, encoding: .utf8), source.utf8.count <= 128 * 1024 {
                    var recovered = image
                    recovered.node = .element("pre", ["language": "mermaid"], [.text(source)])
                    let attachment = document.blocks[index + 1]
                    recovered.editable = image.editable && attachment.editable && image.container == attachment.container
                    recovered.additionalTargets = [attachment.target]
                    result.blocks.append(recovered); index += 2; continue
                }
                result.warnings.append("Diagram preview or source changed remotely. The source attachment is stale; image and source are preserved separately.")
            }
            result.blocks.append(image); index += 1
        }
        return result
    }
}
