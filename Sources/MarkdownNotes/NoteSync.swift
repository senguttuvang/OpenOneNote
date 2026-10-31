import Foundation

public actor NoteSync {
    public let vault: MarkdownVault
    private let remote: any OneNoteRemote
    private let markdown = MarkdownConversion()
    private let html = HTMLConversion()
    private var inFlight: Set<UUID> = []
    private let diagrams: (any DiagramRendering)?
    public init(vault: MarkdownVault, remote: any OneNoteRemote, diagrams: (any DiagramRendering)? = nil) {
        self.vault = vault; self.remote = remote; self.diagrams = diagrams
    }

    private func materialize(_ page: RemotePage) async throws -> (RemoteDocument, [AssetRecord]) {
        var mapping: [String: String] = [:]; var assets: [AssetRecord] = []
        for source in try html.resourceURLs(page.html) {
            guard let url = URL(string: source) else { continue }
            // Adapter validates host/root/resource path before attaching authorization.
            do {
                let bytes = try await remote.resource(url)
                let suffix: String
                if bytes.starts(with: [0x89, 0x50, 0x4e, 0x47]) { suffix = "png" }
                else if bytes.starts(with: [0xff, 0xd8, 0xff]) { suffix = "jpg" }
                else if bytes.starts(with: Array("GIF8".utf8)) { suffix = "gif" }
                else { suffix = "bin" }
                let record = try vault.storeAsset(bytes, resourceURL: source, extension: suffix)
                assets.append(record); mapping[source] = record.path
            } catch is CancellationError { throw CancellationError() }
            catch { continue } // Explicit protected-object warning is produced by the converter.
        }
        let decoded = try html.decode(page.html, resources: mapping)
        return (try DiagramSource.recover(decoded, vault: vault), assets)
    }
    /// Canonicalization removes vendor wrappers and Markdown punctuation differences.
    private func canonical(_ document: NoteDocument) throws -> NoteDocument {
        func normalize(_ node: NoteNode) -> NoteNode {
            guard case .element(let tag, var attrs, let children) = node else { return node }
            if tag == "pre", attrs["language"] != "mermaid" { attrs["language"] = "" }
            if tag == "object" { attrs["type"] = "application/octet-stream" }
            return .element(tag, attrs, children.map(normalize))
        }
        let parsed = try markdown.parse(markdown.markdown(document))
        return NoteDocument(blocks: parsed.blocks.map(normalize), warnings: document.warnings)
    }
    public func open(_ identity: PageIdentity) async throws -> NoteLedger {
        if let existing = try vault.ledgers().first(where: { $0.identity == identity }) { return existing }
        let page = try await remote.fetch(identity)
        guard page.id == identity.pageID else { throw NotesError.invalid("Remote page identity mismatch") }
        let (document, assets) = try await materialize(page)
        let source = markdown.markdown(document.document)
        let baseline = try canonical(document.document)
        let ledger = NoteLedger(identity: identity, title: page.title, baseline: baseline, markdown: source,
                                htmlHash: MarkdownVault.hash(page.html), assets: assets)
        try vault.create(ledger); return ledger
    }
    public func save(_ id: UUID, markdown source: String) throws -> NoteLedger {
        var ledger = try vault.load(id)
        // Save source even when incomplete/unsupported Markdown is being edited. Validation happens at sync.
        try vault.saveOffline(source, ledger: &ledger); return ledger
    }
    public func sync(_ id: UUID, allowPush: Bool = true) async throws -> NoteLedger {
        guard inFlight.insert(id).inserted else { throw NotesError.invalid("This page is already syncing") }
        defer { inFlight.remove(id) }
        var ledger = try vault.load(id)
        try vault.recover(&ledger)
        guard ledger.externalRecoveryMarkdown == nil else { throw NotesError.conflict }
        var localSource = try vault.markdown(ledger)
        var parsedLocal = try markdown.parse(localSource)
        func address(_ node: NoteNode) throws -> NoteNode {
            guard case .element(let tag, var attrs, let children) = node else { return node }
            let key = tag == "img" ? "src" : tag == "object" ? "data" : nil
            if let key, let path = attrs[key] {
                let bytes = try vault.asset(path)
                let suffix = URL(fileURLWithPath: path).pathExtension.lowercased()
                let stored = try vault.storeAsset(bytes, resourceURL: "", extension: suffix.isEmpty ? "bin" : suffix)
                attrs[key] = stored.path
            }
            return .element(tag, attrs, try children.map(address))
        }
        let addressed = try parsedLocal.blocks.map(address)
        if addressed != parsedLocal.blocks {
            parsedLocal.blocks = addressed
            localSource = markdown.markdown(parsedLocal)
            try vault.saveOffline(localSource, ledger: &ledger)
        }
        let local = try canonical(parsedLocal)
        do {
            let fetched = try await remote.fetch(ledger.identity)
            guard fetched.id == ledger.identity.pageID else { throw NotesError.invalid("Remote page identity mismatch") }
            let (current, currentAssets) = try await materialize(fetched)
            let currentDocument = try canonical(current.document)
            let mergedBlocks: [NoteNode]
            do { mergedBlocks = try SequenceMerge.merge(base: ledger.baseline.blocks, local: local.blocks, remote: currentDocument.blocks) }
            catch {
                ledger.state = "conflict"; ledger.remoteRecovery = currentDocument
                ledger.pendingMarkdown = localSource; try vault.saveLedger(ledger); throw NotesError.conflict
            }
            let desired = NoteDocument(blocks: mergedBlocks, warnings: current.warnings)
            if desired.blocks != currentDocument.blocks {
                if !allowPush {
                    ledger.state = "outbox"; ledger.pendingMarkdown = localSource
                    try vault.saveLedger(ledger); return ledger
                }
                guard parsedLocal.warnings.isEmpty else { throw NotesError.unsupported(parsedLocal.warnings.joined(separator: " ")) }
                let presentations = try await diagramPresentations(desired.blocks)
                func presented(_ node: NoteNode) -> NoteNode {
                    if let source = DiagramSource.source(node), let value = presentations[MarkdownVault.hash(source)] { return value }
                    if case .element(let tag, let attrs, let children) = node { return .element(tag, attrs, children.map(presented)) }
                    return node
                }
                // Grouping/normalization can differ from Markdown. Protect pages where mapping is ambiguous.
                let rawCanonicalBlocks = try current.blocks.map { try canonical(NoteDocument(blocks: [$0.node])).blocks }
                guard rawCanonicalBlocks.allSatisfy({ $0.count == 1 }), rawCanonicalBlocks.flatMap({ $0 }) == currentDocument.blocks else {
                    throw NotesError.unsupported("Remote block boundaries require explicit conversion; local changes retained.")
                }
                var mapped = current
                for index in mapped.blocks.indices { mapped.blocks[index].node = rawCanonicalBlocks[index][0] }
                var commands = try html.commands(from: mapped, to: desired, render: { self.markdown.html(presented($0)) })
                var parts: [BinaryPart] = []
                // Re-upload referenced local assets as binary multipart, never as file:// or authenticated URLs.
                for index in commands.indices {
                    let rewritten = try resourceCommands(commands[index].content, parts: &parts)
                    commands[index].content = rewritten
                }
                // No documented conditional write is assumed; this recheck narrows, but cannot close, the race.
                let rechecked = try await remote.fetch(ledger.identity)
                guard rechecked.id == ledger.identity.pageID, MarkdownVault.hash(rechecked.html) == MarkdownVault.hash(fetched.html) else { throw NotesError.remoteChanged }
                ledger.state = "writing"; ledger.pendingMarkdown = localSource
                ledger.remoteRecovery = currentDocument; try vault.saveLedger(ledger)
                try await remote.update(ledger.identity, commands: commands, parts: parts)
                let readback = try await remote.fetch(ledger.identity)
                guard readback.id == ledger.identity.pageID else { throw NotesError.remoteChanged }
                let (verified, verifiedAssets) = try await materialize(readback)
                let normalized = try canonical(verified.document)
                guard normalized.blocks == desired.blocks else {
                    ledger.state = "readback-mismatch"; ledger.remoteRecovery = normalized
                    try vault.saveLedger(ledger); throw NotesError.remoteChanged
                }
                ledger.assets = verifiedAssets; ledger.remoteHTMLHash = MarkdownVault.hash(readback.html)
            } else {
                ledger.assets = currentAssets; ledger.remoteHTMLHash = MarkdownVault.hash(fetched.html)
            }
            // Preserve the exact local Markdown punctuation when semantics did not change.
            let source: String
            if desired.blocks == local.blocks { source = localSource }
            else {
                // Keep unchanged local block spelling, including fenced code language, during a merge.
                let localAST = parsedLocal.blocks
                let raw = markdown.rawBlocks(localSource)
                var used: Set<Int> = []
                let retained = desired.blocks.map { block -> String in
                    if let index = local.blocks.indices.first(where: { !used.contains($0) && local.blocks[$0] == block }) {
                        used.insert(index)
                        if index < raw.count, let original = raw[index], let reparsed = try? markdown.parse(original), reparsed.blocks == [localAST[index]] { return original }
                        return String(markdown.markdown(NoteDocument(blocks: [localAST[index]])).dropLast())
                    }
                    return String(markdown.markdown(NoteDocument(blocks: [block])).dropLast())
                }
                source = retained.joined(separator: "\n\n") + (retained.isEmpty ? "" : "\n")
            }
            // An external file edit during network I/O is preserved; never replace it silently.
            guard try vault.markdown(ledger) == localSource else { throw NotesError.conflict }
            if source != localSource {
                ledger.recoveryVersions = (ledger.recoveryVersions ?? []) + [RecoveryVersion(baseline: ledger.baseline, localMarkdown: localSource, remote: desired)]
            }
            ledger.materializationPreviousHash = MarkdownVault.hash(localSource)
            ledger.baseline = desired; ledger.baselineMarkdown = source; ledger.pendingMarkdown = source; ledger.state = "materializing"
            try vault.saveLedger(ledger)
            try vault.writeMarkdown(source, ledger: ledger)
            ledger.pendingMarkdown = nil; ledger.materializationPreviousHash = nil; ledger.remoteRecovery = nil; ledger.state = "synced"
            ledger.title = fetched.title; try vault.saveLedger(ledger); return ledger
        } catch {
            // Do not flatten a write timeout/mismatch into a clean baseline. Next sync compares all three copies.
            if ledger.state == "synced" { ledger.state = "offline-or-inaccessible"; ledger.pendingMarkdown = localSource; try vault.saveLedger(ledger) }
            throw error
        }
    }
    private func resourceCommands(_ source: String, parts: inout [BinaryPart]) throws -> String {
        // Parse attributes using the maintained HTML parser, not string/regex HTML extraction.
        try HTMLAssetRewriter.rewrite(source) { path, image in
            guard MarkdownConversion.safeAsset(path) else { throw NotesError.invalid("Only local vault resources can be uploaded") }
            let bytes = try vault.asset(path)
            let name = "asset-" + String(parts.count)
            let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
            let mime = ["png": "image/png", "jpg": "image/jpeg", "gif": "image/gif"][ext] ?? "application/octet-stream"
            if image && mime == "application/octet-stream" { throw NotesError.unsupported("Image format is not supported; source retained") }
            parts.append(BinaryPart(name: name, mimeType: mime, bytes: bytes)); return "name:" + name
        }
    }
    private func diagramPresentations(_ blocks: [NoteNode]) async throws -> [String: NoteNode] {
        func sources(_ node: NoteNode) -> [String] {
            if let source = DiagramSource.source(node) { return [source] }
            if case .element(_, _, let children) = node { return children.flatMap(sources) }
            return []
        }
        var result: [String: NoteNode] = [:]
        for source in Set(blocks.flatMap(sources)) {
            guard let diagrams else { throw NotesError.unsupported("A local Mermaid renderer is required before diagram sync") }
            let png = try await diagrams.png(source: source)
            let preview = try vault.storeAsset(png, resourceURL: "", extension: "png")
            let text = try vault.storeAsset(Data(source.utf8), resourceURL: "", extension: "mmd")
            let filename = DiagramSource.filename(sourceHash: text.hash, previewHash: preview.hash)
            result[text.hash] = .element("div", [:], [
                .element("img", ["src": preview.path, "alt": "O2N diagram"], []),
                .element("object", ["data": text.path, "type": "application/octet-stream", "data-attachment": filename], [])
            ])
        }
        return result
    }
}
