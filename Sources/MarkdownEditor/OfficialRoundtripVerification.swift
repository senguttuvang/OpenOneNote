import AppKit
import Foundation
import MarkdownNotes
import OneNoteGraph

extension CloudVerification {
    /// Native O2N source edit/save/sync followed by a real official-client edit supplied externally.
    /// This process never simulates the official editor using Graph PATCH.
    public static func officialRoundtrip(vault directory: URL) async throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Cloud verification must stay hidden") }
        let vault = try MarkdownVault(root: directory)
        let session = try MarkdownSession(vault: vault)
        guard let graph = session.graph, session.root.hasPrefix("sites/") else { throw NotesError.invalid("Configure the verified SharePoint site and dedicated O2N identity first") }
        let account = try await graph.authorization.identityKey()
        let run = UUID().uuidString
        let label = "O2N Cloud Acceptance " + String(run.prefix(8))
        let outgoing = "O2N_TO_OFFICIAL_" + run
        let incoming = "OFFICIAL_TO_O2N_" + run
        let evidence = try vault.safeURL(".o2n/acceptance/\(run)")
        try FileManager.default.createDirectory(at: evidence, withIntermediateDirectories: true)
        var registry = ["run": run, "root": session.root, "classification": "synthetic-only", "outgoingMarker": outgoing,
                        "expectedOfficialMarker": incoming, "status": "creating", "startedAt": ISO8601DateFormatter().string(from: Date())]
        func record() throws {
            try JSONEncoder().encode(registry).write(to: evidence.appendingPathComponent("registry.json"), options: .atomic)
            try Data(run.utf8).write(to: vault.safeURL(".o2n/acceptance/current-run"), options: .atomic)
        }
        try record()
        func create(_ path: String, data: Data, type: String = "application/json") async throws -> GraphItem {
            try JSONDecoder().decode(GraphItem.self, from: await graph.request(graph.url(root: session.root, path: path), method: "POST", body: data, contentType: type))
        }
        func verify(_ path: String, id: String, name: String) async throws {
            let value = try JSONDecoder().decode(GraphItem.self, from: await graph.request(graph.url(root: session.root, path: path)))
            guard value.id == id, value.name == name else { throw NotesError.invalid("Synthetic target identity changed; no write attempted") }
        }
        let notebook = try await create("notebooks", data: JSONEncoder().encode(["displayName": label]))
        registry["notebookID"] = notebook.id; try record()
        try await verify("notebooks/\(GraphClient.component(notebook.id))?$select=id,displayName", id: notebook.id, name: label)
        let section = try await create("notebooks/\(GraphClient.component(notebook.id))/sections", data: JSONEncoder().encode(["displayName": "Bidirectional test"]))
        registry["sectionID"] = section.id; try record()
        try await verify("sections/\(GraphClient.component(section.id))?$select=id,displayName", id: section.id, name: "Bidirectional test")
        let html = "<html><head><title>\(label)</title></head><body><div><p>Synthetic acceptance base</p><p>Official edit goes below this paragraph.</p></div></body></html>"
        let page = try await create("sections/\(GraphClient.component(section.id))/pages", data: Data(html.utf8), type: "text/html")
        registry["pageID"] = page.id; try record()
        let identity = PageIdentity(root: session.root, pageID: page.id, accountKey: account)
        let sync = NoteSync(vault: vault, remote: graph, diagrams: MermaidRenderer())
        let ledger = try await sync.open(identity)
        session.select(ledger.id)
        while session.busy { try await Task.sleep(for: .milliseconds(50)) }
        // Use the actual source editor and application's save callback, not a direct file mutation.
        let editor = MarkdownSourceEditor(source: session.source, identity: ledger.id, onChange: session.edit)
        let coordinator = editor.makeCoordinator()
        defer { withExtendedLifetime(coordinator) {} }
        let text = editor.makeTextView(coordinator: coordinator)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 600), styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = text; window.makeFirstResponder(text)
        let image = try vault.storeAsset(fixturePNG(), resourceURL: "", extension: "png")
        let diagramSource = "flowchart LR\n O2N-->Official\n"
        registry["imageSHA256"] = image.hash
        registry["diagramSourceSHA256"] = MarkdownVault.hash(diagramSource)
        let changed = session.source + "\n**" + outgoing + "**\n\n| Client | State |\n| --- | --- |\n| O2N native | Synced |\n\n![Synthetic blue square](\(image.path))\n\n```mermaid\n" + diagramSource + "```\n"
        text.insertText(changed, replacementRange: NSRange(location: 0, length: text.string.utf16.count))
        guard session.source == changed, try vault.markdown(ledger) == changed, !window.isVisible else { throw NotesError.invalid("Native source edit/save failed") }
        let before = try await graph.fetch(identity)
        guard before.id == page.id, before.title == label else { throw NotesError.invalid("Synthetic page identity changed before native sync") }
        session.sync()
        while session.busy { try await Task.sleep(for: .milliseconds(50)) }
        guard session.selected?.state == "synced", session.source.contains(outgoing) else { throw NotesError.invalid("Native O2N sync failed: " + session.message) }
        let readback = try await graph.fetch(identity)
        guard readback.id == page.id, readback.html.contains(outgoing), readback.html.contains("<table"),
              readback.html.contains("<img"), readback.html.contains("<object"), session.source.contains("```mermaid") else {
            throw NotesError.invalid("Native Graph readback lost marker/table/image/diagram")
        }
        struct PageLinks: Decodable {
            struct Link: Decodable { let href: String }
            struct Links: Decodable { let oneNoteWebUrl: Link; let oneNoteClientUrl: Link }
            let id: String; let links: Links
        }
        let metadata = try JSONDecoder().decode(PageLinks.self, from: await graph.request(graph.url(root: session.root, path: "pages/\(GraphClient.component(page.id))?$select=id,links")))
        guard metadata.id == page.id else { throw NotesError.invalid("Page links identity mismatch") }
        registry["webURL"] = metadata.links.oneNoteWebUrl.href; registry["nativeURL"] = metadata.links.oneNoteClientUrl.href
        registry["localID"] = ledger.id.uuidString; registry["nativePushReadbackAt"] = ISO8601DateFormatter().string(from: Date())
        registry["status"] = "native push verified; waiting for official-client edit"; try record()
        try MarkdownVerification.render(session: session, to: evidence.appendingPathComponent("native-after-push.png"), width: 1280)
        print("Native O2N edit/save/sync and same-page Graph table/image/diagram readback passed. Synthetic links and expected official marker recorded locally. Waiting for the actual official OneNote editor.")
        session.startBackgroundRefresh()
        defer { session.stopBackgroundRefresh(); session.cancel() }
        let deadline = Date().addingTimeInterval(1800)
        while Date() < deadline {
            try await Task.sleep(for: .seconds(2)); try Task.checkCancellation()
            guard session.source.contains(incoming) else { continue }
            let detectedAt = Date()
            let final = try await graph.fetch(identity)
            let all = try await graph.list(root: session.root, path: "sections/\(GraphClient.component(section.id))/pages?$select=id,title&$top=100")
            guard final.id == page.id, all.count == 1, all.first?.id == page.id,
                  final.html.contains(outgoing), final.html.contains(incoming), final.html.contains("<table"),
                  final.html.contains("<img"), final.html.contains("<object"), session.source.contains("```mermaid"),
                  session.preview.blocks.contains(where: { $0.text.contains(incoming) }) else { throw NotesError.invalid("Final same-page content/preview/duplicate check failed") }
            // A fresh vault verifies downloaded bytes and source recovery independently of this editor's cache.
            let fresh = try MarkdownVault(root: evidence.appendingPathComponent("independent-recovery"))
            let recovered = try await NoteSync(vault: fresh, remote: graph).open(identity)
            let recoveredSource = try fresh.markdown(recovered)
            guard recoveredSource.contains("```mermaid\n" + diagramSource + "```"),
                  recovered.assets.contains(where: { $0.hash == image.hash }),
                  recoveredSource.contains(outgoing), recoveredSource.contains(incoming) else {
                throw NotesError.invalid("Official edit changed or lost image/diagram source; both vaults and fixture retained")
            }
            registry["independentImageAndSourceRecovery"] = "passed after official edit"
            registry["officialMarkerDetectedAt"] = ISO8601DateFormatter().string(from: detectedAt)
            registry["status"] = "native detected official marker; official UI evidence must be recorded separately"
            try record()
            try MarkdownVerification.render(session: session, to: evidence.appendingPathComponent("native-after-official-edit.png"), width: 1280)
            print("O2N polling pulled the official marker into native Markdown and reading preview. Same page ID, one page, both markers, table, image bytes and diagram source preserved. Official editor provenance/rendering is a separate UI check.")
            return
        }
        throw NotesError.invalid("Official editor marker was not observed within 30 minutes; fixture and local evidence retained")
    }
}
