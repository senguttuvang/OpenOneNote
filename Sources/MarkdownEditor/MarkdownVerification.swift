import AppKit
import SwiftUI
import MarkdownNotes

@MainActor public enum MarkdownVerification {
    public static func exercise(at directory: URL) throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Native verification must prohibit activation") }
        let vault = try MarkdownVault(root: directory)
        let codec = MarkdownConversion()
        let source = "A synthetic notebook for native interface verification. All content is generated locally.\n\n| Person | Project role |\n| --- | --- |\n| Avery | Project priorities and acceptance |\n| Morgan | Consulting and technical review |\n| Riley | Operations collaboration |\n| Jordan | Application support |\n\n## Project outcomes\n\nPreserve customer journeys, content and recovery while improving the application. Use the linked strategy, findings and delivery plan for detail.\n\n## Knowledge ownership\n\nThe notebook holds team-safe findings and roadmap material. Private information remains outside the synthetic verification vault.\n\n## Learning catalog and integration\n\n[Knowledge Hub](https://example.com/knowledge) — project learning resources and the proposed pilot.\n\n## Related pages\n\n- [Goals and outcomes](https://example.com/goals)\n- [Delivery milestones](https://example.com/milestones)\n- [Source evidence](https://example.com/evidence)\n"
        var ledger = NoteLedger(identity: PageIdentity(root: "local", pageID: "synthetic-local"), title: "Project — Home", baseline: try codec.parse(source), markdown: source, htmlHash: "fixture", assets: [])
        ledger.state = "local-only"; ledger.hierarchy = ["Synthetic Notebook", "00 Project Home"]
        try vault.create(ledger)
        for name in ["Cost Optimization", "Backlog", "Learning and Integration"] {
            var other = try vault.createLocal(); other.hierarchy = ["Synthetic Notebook", name]; try vault.saveLedger(other)
        }
        let session = try MarkdownSession(vault: vault); session.select(ledger.id)
        let commands = MarkdownTextCommands()
        var editor = MarkdownSourceEditor(source: source, identity: ledger.id, onChange: session.edit); editor.commands = commands
        let coordinator = editor.makeCoordinator(); let view = editor.makeTextView(coordinator: coordinator)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = view; window.makeFirstResponder(view)
        view.undoManager?.beginUndoGrouping()
        view.insertText("# தமிழ் — Offline edit\n", replacementRange: NSRange(location: 0, length: view.string.utf16.count))
        view.undoManager?.endUndoGrouping()
        guard session.source == view.string, try vault.markdown(ledger) == view.string else { throw NotesError.invalid("Native source edit did not persist") }
        view.undoManager?.undo()
        guard view.string == source else { throw NotesError.invalid("Markdown native undo failed") }
        view.undoManager?.redo()
        let reopened = try MarkdownSession(vault: vault); reopened.select(ledger.id)
        guard reopened.source == view.string else { throw NotesError.invalid("Markdown reopen failed") }
        session.edit(source)
        if var restored = session.selected { restored.title = "Project — Home"; try vault.saveLedger(restored); session.replace(restored) }
        let shell = NativeShellState(session: session)
        for width in [1728.0, 1280.0, 960.0] { try render(session: session, to: directory.appendingPathComponent("preview-\(Int(width)).png"), width: width) }
        for tab in ["Insert", "Draw", "View", "Markdown"] {
            shell.tab = tab
            try capture(MarkdownEditorView(session: session, presentation: shell), to: directory.appendingPathComponent("ribbon-\(tab.lowercased()).png"), width: 1280, height: 800)
        }
        shell.tab = "Home"
        try capture(MarkdownEditorView(session: session, presentation: shell), to: directory.appendingPathComponent("preview-light.png"), width: 1280, height: 800, dark: false)
        for mode in MarkdownEditorMode.allCases {
            shell.mode = mode
            try capture(MarkdownEditorView(session: session, presentation: shell), to: directory.appendingPathComponent("mode-\(mode.rawValue.lowercased()).png"), width: 1280, height: 800)
        }
        for surface in [NativeShellSheet.account, .notebooks, .settings, .recovery] {
            try capture(NativeAccountSurfaces(shell: shell, surface: surface), to: directory.appendingPathComponent("dialog-\(surface.rawValue).png"), width: 900, height: 600)
        }
        if var note = session.selected {
            let original = note
            note.remoteRecovery = try codec.parse("# Remote synthetic copy\n\nA preserved remote change.\n")
            note.state = "conflict"; session.replace(note)
            try capture(NativeAccountSurfaces(shell: shell, surface: .recovery), to: directory.appendingPathComponent("dialog-conflict.png"), width: 1000, height: 600)
            session.replace(original)
        }
        try capture(NativeListGallery(numbered: false, shell: shell, dismiss: {}), to: directory.appendingPathComponent("gallery-bullets.png"), width: 460, height: 220)
        try capture(NativeListGallery(numbered: true, shell: shell, dismiss: {}), to: directory.appendingPathComponent("gallery-numbering.png"), width: 460, height: 370)
        for kind in ["highlight", "font", "paper", "ink"] {
            try capture(NativeColourGallery(kind: kind), to: directory.appendingPathComponent("gallery-\(kind).png"), width: 360, height: 390)
        }
        try capture(NativeTableGallery(shell: shell, dismiss: {}), to: directory.appendingPathComponent("gallery-table.png"), width: 300, height: 260)
        try capture(NativePaperGallery(), to: directory.appendingPathComponent("gallery-ruling.png"), width: 420, height: 260)
        try modeTransitions(session: session)
        try profileNativeEdits(session: session, directory: directory)
        guard !window.isVisible, NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Native test changed focus policy") }
    }
    private static func profileNativeEdits(session: MarkdownSession, directory: URL) throws {
        let original = session.source
        let paragraph = "## Synthetic section\n\nA long note keeps Unicode தமிழ், a [link](https://example.com), **formatting**, and ordinary prose.\n\n"
        let source = String(repeating: paragraph, count: 400) + String(repeating: "```mermaid\nflowchart LR\n A[Start] --> B[Finish]\n```\n\n", count: 5)
        session.edit(source)
        let editor = MarkdownSourceEditor(source: source, identity: session.selectedID, onChange: session.edit)
        let coordinator = editor.makeCoordinator(); let view = editor.makeTextView(coordinator: coordinator)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = view; window.makeFirstResponder(view)
        var milliseconds: [Double] = []
        for _ in 0..<10 {
            let start = DispatchTime.now().uptimeNanoseconds
            view.insertText("x", replacementRange: NSRange(location: view.string.utf16.count, length: 0))
            milliseconds.append(Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000)
        }
        guard session.source == view.string, try session.vault.markdown(require(session.selected, "Missing profile note")) == view.string,
              !window.isVisible else { throw NotesError.invalid("Long-note native edits did not persist") }
        let report: [String: Any] = ["scope": "Debug/release native NSTextView insertion, Markdown parsing and synchronous local persistence; excludes preview layout, Mermaid PNG regeneration and human typing latency", "sourceUTF8Bytes": source.utf8.count, "paragraphs": 400, "diagramFences": 5, "sampleMilliseconds": milliseconds, "activationPolicy": "prohibited; hidden owned window"]
        try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys]).write(to: directory.appendingPathComponent("native-edit-profile.json"))
        session.edit(original)
    }
    private static func modeTransitions(session: MarkdownSession) throws {
        let shell = NativeShellState(session: session)
        let host = NSHostingView(rootView: MarkdownEditorView(session: session, presentation: shell))
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = host; host.frame = window.contentLayoutRect
        host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        let editor = try require(shell.editor.target, "Source view was not mounted in Read mode")
        shell.mode = .write; RunLoop.main.run(until: Date().addingTimeInterval(0.1))
        let range = (editor.string as NSString).range(of: "synthetic")
        editor.setSelectedRange(range); shell.format("Bold")
        let formatted = editor.string
        for mode in [MarkdownEditorMode.read, .split, .write] {
            shell.mode = mode; host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.1))
            guard shell.editor.target === editor, editor.string == formatted,
                  editor.selectedRange().length == range.length,
                  editor.undoManager?.canUndo == true else { throw NotesError.invalid("Mode transition lost source editor, selection or undo") }
        }
        editor.undoManager?.undo()
        guard !editor.string.contains("**synthetic**"), !window.isVisible else { throw NotesError.invalid("Mode transition native undo failed") }
        editor.setSelectedRange((editor.string as NSString).range(of: "| Person"))
        guard shell.tableContext else { throw NotesError.invalid("Table selection did not expose contextual ribbon") }
        shell.mode = .read
        guard !shell.tableContext else { throw NotesError.invalid("Table ribbon remained in reading mode") }
    }
    private static func require<T>(_ value: T?, _ reason: String) throws -> T {
        guard let value else { throw NotesError.invalid(reason) }; return value
    }
    public static func render(session: MarkdownSession, to url: URL, width: Double) throws {
        try capture(MarkdownEditorView(session: session), to: url, width: width, height: width == 1728 ? 1088 : 800)
    }
    private static func capture<Content: View>(_ content: Content, to url: URL, width: Double, height: Double, dark: Bool = true) throws {
        guard NSApp.activationPolicy() == .prohibited else { throw NotesError.invalid("Preview requires prohibited activation") }
        let host = NSHostingView(rootView: content.environment(\.colorScheme, dark ? .dark : .light).background(NativePalette(dark ? .dark : .light).canvas))
        host.safeAreaRegions = []
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: width, height: height), styleMask: [.borderless], backing: .buffered, defer: false)
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua); window.contentView = host
        host.appearance = window.appearance
        host.frame = NSRect(x: 0, y: 0, width: width, height: height)
        host.layoutSubtreeIfNeeded(); RunLoop.main.run(until: Date().addingTimeInterval(0.25)); window.display()
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(width), pixelsHigh: Int(height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { throw NotesError.invalid("Cannot allocate Markdown preview") }
        bitmap.size = host.frame.size; host.cacheDisplay(in: host.bounds, to: bitmap)
        guard let data = bitmap.representation(using: .png, properties: [:]) else { throw NotesError.invalid("Cannot encode Markdown preview") }
        try data.write(to: url, options: .atomic)
        guard !window.isVisible else { throw NotesError.invalid("Verification window became visible") }
    }
}
