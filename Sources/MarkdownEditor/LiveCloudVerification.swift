import AppKit
import Foundation
import MarkdownNotes
import OneNoteGraph

private actor ReconnectRemote: OneNoteRemote {
    let client: GraphClient
    var online = true
    init(client: GraphClient) { self.client = client }
    func setOnline(_ value: Bool) { online = value }
    func fetch(_ identity: PageIdentity) async throws -> RemotePage {
        guard online else { throw URLError(.notConnectedToInternet) }; return try await client.fetch(identity)
    }
    func resource(_ url: URL) async throws -> Data {
        guard online else { throw URLError(.notConnectedToInternet) }; return try await client.resource(url)
    }
    func update(_ identity: PageIdentity, commands: [PageCommand], parts: [BinaryPart]) async throws {
        guard online else { throw URLError(.notConnectedToInternet) }; try await client.update(identity, commands: commands, parts: parts)
    }
}

extension CloudVerification {
    /// Real delegated Graph writes are limited to a newly created, recorded synthetic fixture.
    public static func exercise(vault directory: URL) async throws {
        let vault = try MarkdownVault(root: directory)
        let session = try MarkdownSession(vault: vault)
        guard let graph = session.graph else { throw NotesError.invalid(session.message) }
        _ = try await graph.authorization.accessToken()
        let account = try await graph.authorization.identityKey()
        let run = UUID().uuidString
        let recordDirectory = try vault.safeURL(".o2n/validation/\(run)")
        try FileManager.default.createDirectory(at: recordDirectory, withIntermediateDirectories: true)
        var registry: [String: String] = ["run": run, "root": session.root, "classification": "synthetic-only", "verification": "started"]
        func record() throws { try JSONEncoder().encode(registry).write(to: recordDirectory.appendingPathComponent("registry.json"), options: .atomic) }
        try record()
        func create(_ path: String, body: Data, type: String = "application/json") async throws -> GraphItem {
            let data = try await graph.request(graph.url(root: session.root, path: path), method: "POST", body: body, contentType: type)
            return try JSONDecoder().decode(GraphItem.self, from: data)
        }
        let label = "O2N Synthetic Validation " + String(run.prefix(8))
        let notebook = try await create("notebooks", body: JSONEncoder().encode(["displayName": label]))
        registry["notebookID"] = notebook.id; try record()
        let section = try await create("notebooks/\(GraphClient.component(notebook.id))/sections", body: JSONEncoder().encode(["displayName": "Markdown roundtrip"]))
        registry["sectionID"] = section.id; try record()
        let initial = "<html><head><title>\(label)</title></head><body><div><p>Local base</p><p>Remote base</p><p><b>Bold</b> and <i>italic</i> <a href='https://example.com'>link</a></p><table><tr><td>Name</td><td>State</td></tr><tr><td>O2N</td><td>Ready</td></tr></table></div></body></html>"
        let page = try await create("sections/\(GraphClient.component(section.id))/pages", body: Data(initial.utf8), type: "text/html")
        registry["pageID"] = page.id; try record()
        let identity = PageIdentity(root: session.root, pageID: page.id, accountKey: account)
        let connection = ReconnectRemote(client: graph)
        let sync = NoteSync(vault: vault, remote: connection, diagrams: MermaidRenderer())
        var ledger = try await sync.open(identity)
        let png = try fixturePNG()
        let image = try vault.storeAsset(png, resourceURL: "", extension: "png")
        let base = try vault.markdown(ledger)
        let edited = base.replacingOccurrences(of: "Local base", with: "Local edited") + "\n![Synthetic image](\(image.path))\n\n```mermaid\nflowchart LR\n Local-->Cloud\n```\n"
        // A real native text view produces the source save before the cloud write.
        let editor = MarkdownSourceEditor(source: base, identity: ledger.id) { text in
            do { try vault.saveOffline(text, ledger: &ledger) } catch { session.message = error.localizedDescription }
        }
        let coordinator = editor.makeCoordinator(); let textView = editor.makeTextView(coordinator: coordinator)
        let hidden = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 600, height: 400), styleMask: [.borderless], backing: .buffered, defer: false)
        hidden.contentView = textView; hidden.makeFirstResponder(textView)
        textView.insertText(edited, replacementRange: NSRange(location: 0, length: textView.string.utf16.count))
        guard try vault.markdown(ledger) == edited, !hidden.isVisible else { throw NotesError.invalid("Synthetic native edit did not persist safely") }
        ledger = try await sync.sync(ledger.id)
        guard ledger.identity == identity, ledger.state == "synced", try vault.markdown(ledger).contains("```mermaid") else { throw NotesError.invalid("Formatted/image/diagram live roundtrip failed") }
        registry["formattedImageDiagramRoundtrip"] = "Graph API readback passed"; try record()
        // An independent vault must recover the diagram fence from downloaded source plus verified PNG hashes.
        let fresh = try MarkdownVault(root: directory.appendingPathComponent("recovered-\(run)"))
        let recovered = try await NoteSync(vault: fresh, remote: graph).open(identity)
        guard try fresh.markdown(recovered).contains("```mermaid") else { throw NotesError.invalid("Live diagram source recovery failed") }
        registry["diagramSourceRecovery"] = "passed"; try record()
        try await remoteReplace(graph: graph, identity: identity, text: "Remote base", replacement: "Remote external")
        ledger = try await sync.sync(ledger.id, allowPush: false)
        guard try vault.markdown(ledger).contains("Remote external") else { throw NotesError.invalid("External edit refresh failed") }
        await connection.setOnline(false)
        _ = try await sync.save(ledger.id, markdown: vault.markdown(ledger).replacingOccurrences(of: "Local edited", with: "Local offline"))
        do { _ = try await sync.sync(ledger.id); throw NotesError.invalid("Offline sync unexpectedly succeeded") }
        catch is URLError { }
        await connection.setOnline(true)
        try await remoteReplace(graph: graph, identity: identity, text: "Remote external", replacement: "Remote disjoint")
        ledger = try await sync.sync(ledger.id)
        let merged = try vault.markdown(ledger)
        guard merged.contains("Local offline"), merged.contains("Remote disjoint") else { throw NotesError.invalid("Live reconnect/disjoint merge failed") }
        registry["offlineReconnectDisjointMerge"] = "passed"; try record()
        _ = try await sync.save(ledger.id, markdown: merged.replacingOccurrences(of: "Local offline", with: "Local overlap"))
        try await remoteReplace(graph: graph, identity: identity, text: "Local offline", replacement: "Remote overlap")
        do { _ = try await sync.sync(ledger.id); throw NotesError.invalid("Overlap was not detected") }
        catch NotesError.conflict { }
        let conflict = try vault.load(ledger.id)
        guard conflict.state == "conflict", conflict.remoteRecovery != nil, try vault.markdown(conflict).contains("Local overlap") else { throw NotesError.invalid("Overlap recovery copies missing") }
        registry["overlapPreservation"] = "passed"; registry["verification"] = "Graph API acceptance passed; native OneNote visual proof not performed"
        try record()
        print("Native AppAuth/Graph synthetic API acceptance passed: same-page formatted/table/image/diagram readback, source recovery, external refresh, offline reconnect, disjoint merge and overlap preservation. These remote edits were API probes, separate from the official-editor test. Synthetic identities retained locally; no existing pages changed or test pages deleted.")
    }
    private static func remoteReplace(graph: GraphClient, identity: PageIdentity, text: String, replacement: String) async throws {
        let page = try await graph.fetch(identity)
        let decoded = try HTMLConversion().decode(page.html)
        guard let target = decoded.blocks.first(where: { $0.node.text == text && $0.editable }) else { throw NotesError.invalid("Synthetic remote edit anchor missing") }
        try await graph.update(identity, commands: [PageCommand(target: target.target, action: "replace", content: "<p>" + MarkdownConversion.escape(replacement) + "</p>")], parts: [])
    }
    static func fixturePNG() throws -> Data {
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 32, pixelsHigh: 32, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
              let context = NSGraphicsContext(bitmapImageRep: bitmap) else { throw NotesError.invalid("PNG fixture allocation failed") }
        NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = context
        NSColor.systemBlue.setFill(); NSRect(x: 0, y: 0, width: 32, height: 32).fill()
        NSGraphicsContext.restoreGraphicsState()
        guard let data = bitmap.representation(using: .png, properties: [:]) else { throw NotesError.invalid("PNG fixture encoding failed") }
        return data
    }
}
