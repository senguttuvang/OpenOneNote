import AppKit
import SwiftUI
import Foundation
import MarkdownNotes
import OneNoteGraph

extension CloudVerification {
    public static func fixtureStatus(vault directory: URL) async throws {
        let vault = try MarkdownVault(root: directory)
        let run = try String(contentsOf: vault.safeURL(".o2n/acceptance/current-run"), encoding: .utf8)
        guard UUID(uuidString: run) != nil else { throw NotesError.invalid("Invalid synthetic run") }
        let evidence = try vault.safeURL(".o2n/acceptance/\(run)")
        let registry = try JSONDecoder().decode([String: String].self, from: Data(contentsOf: evidence.appendingPathComponent("registry.json")))
        let session = try MarkdownSession(vault: vault)
        guard registry["classification"] == "synthetic-only", registry["root"] == session.root,
              let id = registry["pageID"], let graph = session.graph else { throw NotesError.invalid("No matching synthetic page") }
        let identity = PageIdentity(root: session.root, pageID: id, accountKey: try await graph.authorization.identityKey())
        let page = try await graph.fetch(identity)
        guard page.title == "O2N Cloud Acceptance " + String(run.prefix(8)) else { throw NotesError.invalid("Synthetic title mismatch") }
        try Data(page.html.utf8).write(to: evidence.appendingPathComponent("diagnostic-page.html"), options: .atomic)
        let metadata = try await graph.request(graph.url(root: session.root, path: "pages/\(GraphClient.component(id))?$select=id,links"))
        try metadata.write(to: evidence.appendingPathComponent("diagnostic-links.json"), options: .atomic)
        for (index, source) in try HTMLConversion().resourceURLs(page.html).enumerated() {
            guard let url = URL(string: source) else { continue }
            do { let data = try await graph.resource(url); print("Synthetic resource \(index): \(data.count) bytes") }
            catch { print("Synthetic resource \(index): \(error.localizedDescription)") }
        }
        print("Synthetic page HTML and links saved locally. No writes performed.")
    }
    /// Native O2N source edit/save/sync followed by a real official-client edit supplied externally.
    /// This process never simulates the official editor using Graph PATCH.
    public static func officialRoundtrip(vault directory: URL) async throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Cloud verification must stay hidden") }
        let vault = try MarkdownVault(root: directory)
        let session = try MarkdownSession(vault: vault)
        guard let graph = session.graph, session.root.hasPrefix("sites/") else { throw NotesError.invalid("Configure the verified SharePoint site and dedicated O2N identity first") }
        let account = try await graph.authorization.identityKey()
        let current = try vault.safeURL(".o2n/acceptance/current-run")
        let pending: [String: String]?
        if let previous = try? String(contentsOf: current, encoding: .utf8), UUID(uuidString: previous) != nil,
           let data = try? Data(contentsOf: vault.safeURL(".o2n/acceptance/\(previous)/registry.json")),
           let saved = try? JSONDecoder().decode([String: String].self, from: data),
           saved["status"] == "creating", saved["root"] == session.root, saved["run"] == previous,
           saved["classification"] == "synthetic-only" {
            pending = saved
        } else { pending = nil }
        let run = pending?["run"] ?? UUID().uuidString
        let label = "O2N Cloud Acceptance " + String(run.prefix(8))
        let outgoing = "O2N-TO-OFFICIAL-" + run
        let incoming = "OFFICIAL-TO-O2N-" + run
        let evidence = try vault.safeURL(".o2n/acceptance/\(run)")
        try FileManager.default.createDirectory(at: evidence, withIntermediateDirectories: true)
        var registry = pending ?? ["run": run, "root": session.root, "classification": "synthetic-only", "outgoingMarker": outgoing,
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
        let notebook: GraphItem
        if let id = registry["notebookID"] { notebook = GraphItem(id: id, displayName: label) }
        else { notebook = try await create("notebooks", data: JSONEncoder().encode(["displayName": label])) }
        registry["notebookID"] = notebook.id; try record()
        try await verify("notebooks/\(GraphClient.component(notebook.id))?$select=id,displayName", id: notebook.id, name: label)
        let section: GraphItem
        if let id = registry["sectionID"] { section = GraphItem(id: id, displayName: "Bidirectional test") }
        else { section = try await create("notebooks/\(GraphClient.component(notebook.id))/sections", data: JSONEncoder().encode(["displayName": "Bidirectional test"])) }
        registry["sectionID"] = section.id; try record()
        try await verify("sections/\(GraphClient.component(section.id))?$select=id,displayName", id: section.id, name: "Bidirectional test")
        let html = "<html><head><title>\(label)</title></head><body><div><p>Synthetic acceptance base</p><p>Official edit goes below this paragraph.</p></div></body></html>"
        let page: GraphItem
        if let id = registry["pageID"] { page = GraphItem(id: id, displayName: label) }
        else { page = try await create("sections/\(GraphClient.component(section.id))/pages", data: Data(html.utf8), type: "text/html") }
        registry["pageID"] = page.id; try record()
        let identity = PageIdentity(root: session.root, pageID: page.id, accountKey: account)
        let sync = NoteSync(vault: vault, remote: graph, diagrams: MermaidRenderer())
        let ledger: NoteLedger
        do { ledger = try await sync.open(identity) }
        catch { throw NotesError.invalid("Opening recorded synthetic page after creation: " + error.localizedDescription) }
        session.select(ledger.id)
        while session.busy { try await Task.sleep(for: .milliseconds(50)) }
        let image = try vault.storeAsset(fixturePNG(), resourceURL: "", extension: "png")
        let diagramSource = "flowchart LR\n O2N-->Official\n"
        registry["imageSHA256"] = image.hash
        registry["diagramSourceSHA256"] = MarkdownVault.hash(diagramSource)
        let window: NSWindow
        if session.source.contains(outgoing) {
            guard session.source.contains("**" + outgoing + "**"), session.source.contains("| O2N native |"),
                  session.source.contains(image.path), session.source.contains("```mermaid\n" + diagramSource) else {
                throw NotesError.invalid("Recorded native fixture is incomplete; source retained without another edit")
            }
            window = NSWindow(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        } else {
            window = try editRoundtripFixture(session: session, outgoing: outgoing, imagePath: image.path, diagramSource: diagramSource)
        }
        defer { withExtendedLifetime(window) {} }
        guard try vault.markdown(ledger) == session.source, !window.isVisible else { throw NotesError.invalid("Native rich/source edit/save failed") }
        registry["nativeEditPath"] = "default rich text and table; Markdown ribbon for image/diagram source"
        try record()
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

    /// Exercise the mounted default editor, ribbon formatting/table commands and Markdown projection.
    static func editRoundtripFixture(session: MarkdownSession, outgoing: String, imagePath: String, diagramSource: String) throws -> NSWindow {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Fixture editor must stay hidden") }
        let shell = NativeShellState(session: session)
        let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
        shell.window = window; window.contentView = host; host.frame = window.contentLayoutRect
        func settle() { host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.1)) }
        settle()
        guard !shell.markdownVisible, let rich = shell.richCommands.target else { throw NotesError.invalid("Default rich editor did not mount") }
        window.makeFirstResponder(rich)
        rich.insertText("\n" + outgoing + "\n", replacementRange: NSRange(location: rich.string.utf16.count, length: 0))
        rich.setSelectedRange((rich.string as NSString).range(of: outgoing)); shell.format("Bold"); settle()
        rich.setSelectedRange(NSRange(location: rich.string.utf16.count, length: 0))
        shell.richCommands.insertTable(rows: 2, columns: 2)
        let cell = (rich.string as NSString).range(of: "Cell")
        guard cell.location != NSNotFound else { throw NotesError.invalid("Native rich fixture table did not insert") }
        rich.insertText("O2N native", replacementRange: cell); settle()
        guard session.source.contains("**" + outgoing + "**"), session.source.contains("| O2N native |") else {
            throw NotesError.invalid("Default rich formatting/table save failed")
        }
        shell.perform("Markdown"); settle()
        guard shell.markdownVisible, let source = shell.sourceCommands.target else { throw NotesError.invalid("Markdown ribbon did not reveal its editor") }
        window.makeFirstResponder(source)
        let changed = session.source + "\n![Synthetic blue square](\(imagePath))\n\n```mermaid\n" + diagramSource + "```\n"
        source.insertText(changed, replacementRange: NSRange(location: 0, length: source.string.utf16.count)); settle()
        guard session.source == changed else { throw NotesError.invalid("Markdown fixture assets did not save") }
        shell.perform("Markdown"); settle()
        guard !shell.markdownVisible, shell.richCommands.target === rich, session.source == changed, !window.isVisible else {
            throw NotesError.invalid("Returning to rich editing changed source or replaced the native view")
        }
        return window
    }
}
