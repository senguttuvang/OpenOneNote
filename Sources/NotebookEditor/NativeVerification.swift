import AppKit
import SwiftUI
import NotebookCore
import NotebookPersistence

public enum EditorVerificationError: Error { case failed(String) }

@MainActor public enum NativeVerification {
    public static func fixture(at url: URL) throws -> NotebookSession {
        let content = NSMutableAttributedString(string: "Field Notes is a place for the team’s technical knowledge and delivery roadmap.\n", attributes: [.font: EditorTheme.bodyFont, .foregroundColor: EditorTheme.foreground])
        let table = NotebookTextView(); table.insertTable()
        content.append(table.attributedString())
        for (heading, body) in [
            ("Working together", "Keep decisions close to the work. Capture the context, explore the options, and agree on a small next step.\n"),
            ("Knowledge ownership", "Use this notebook for shared findings and practical guidance. Keep confidential information in the appropriate private workspace. Original references remain attached to their source.\n"),
            ("Learning and discovery", "Build a useful catalog of questions, experiments, and observations. Review what changed and record the evidence behind each decision.\n"),
            ("Related pages", "Goals and outcomes\nDelivery milestones\nResearch and findings\nDecisions and next steps\nOperating model\n")
        ] {
            content.append(NSAttributedString(string: heading + "\n", attributes: [.font: NSFont.systemFont(ofSize: 20), .foregroundColor: EditorTheme.link]))
            let style = NSMutableParagraphStyle(); style.paragraphSpacing = 10
            content.append(NSAttributedString(string: body, attributes: [.font: EditorTheme.bodyFont, .foregroundColor: EditorTheme.foreground, .paragraphStyle: style]))
        }
        let related = (content.string as NSString).range(of: "Goals and outcomes")
        content.addAttribute(.link, value: URL(string: "https://example.com/notes")!, range: related)
        let listStart = related.location
        let fixtureList = NotebookTextView(); fixtureList.textStorage?.setAttributedString(content)
        fixtureList.setSelectedRange(NSRange(location: listStart, length: content.length - listStart))
        fixtureList.toggleList(numbered: false)
        let rich = fixtureList.attributedString()
        let page = NotePage(title: "Field Notes — Project Home", blocks: [NoteBlock(x: 72, y: 32, width: 914, text: rich.string, height: 820, richText: try RichTextCodec.encode(rich))])
        let notebook = Notebook(title: "Field Notes", sections: [NoteSection(title: "Project Home", pages: [page]), NoteSection(title: "Research"), NoteSection(title: "Backlog"), NoteSection(title: "Learning")])
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONNotebookRepository(url: url).save(notebook)
        return NotebookSession(url: url)
    }

    public static func exerciseEditor(at url: URL) throws {
        let session = NotebookSession(url: url)
        guard let page = session.selectedPage, let block = page.blocks.first else { throw EditorVerificationError.failed("No initial page") }
        var failure: Error?
        let editor = RichTextEditor(text: block.text, richText: nil, undoManager: session.undoManager,
            onChange: { session.editText(pageID: page.id, blockID: block.id, text: $0, richText: $1) }, onError: { failure = $0 })
        let coordinator = editor.makeCoordinator()
        let view = editor.makeTextView(coordinator: coordinator)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 400), styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = view
        window.makeFirstResponder(view)
        let previous = view.string
        session.undoManager.beginUndoGrouping()
        view.insertText("தமிழ் — Native editing 👋", replacementRange: NSRange(location: 0, length: view.string.utf16.count))
        session.undoManager.endUndoGrouping()
        guard failure == nil, view.string == "தமிழ் — Native editing 👋", session.selectedPage?.blocks.first?.text == view.string else {
            throw EditorVerificationError.failed("Native edit did not reach the model: \(String(describing: failure))")
        }
        session.undoManager.undo()
        guard view.string == previous else { throw EditorVerificationError.failed("Native text undo failed") }
        session.undoManager.redo()
        let bold = NSSelectorFromString("toggleBoldface:")
        guard view.responds(to: bold), view.responds(to: NSSelectorFromString("toggleItalics:")) else {
            throw EditorVerificationError.failed("Native format actions unavailable")
        }
        view.setSelectedRange(NSRange(location: 0, length: view.string.utf16.count))
        view.perform(bold, with: nil)
        guard let encoded = session.selectedPage?.blocks.first?.richText,
              let font = try RichTextCodec.decode(encoded).attribute(.font, at: 0, effectiveRange: nil) as? NSFont,
              NSFontManager.shared.traits(of: font).contains(.boldFontMask) else {
            throw EditorVerificationError.failed("Native bold action was not persisted")
        }
        guard session.saveNow() else { throw EditorVerificationError.failed("Save failed") }
        let reopened = NotebookSession(url: url)
        guard reopened.notebook == session.notebook else { throw EditorVerificationError.failed("Reopen changed the notebook") }
        withExtendedLifetime(coordinator) {}
    }

    public static func renderInterface(session: NotebookSession, directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let commands = EditorCommands(session: session)
        NotebookMenus.install(commands: commands)
        for tab in ["Home", "Insert", "Draw", "View", "Table"] {
            commands.tab = tab
            try render(session: session, to: directory.appendingPathComponent("\(tab.lowercased())-1728.png"), width: 1728, height: 1088, commands: commands)
        }
        commands.tab = "Home"
        try render(session: session, to: directory.appendingPathComponent("home-960.png"), width: 960, height: 800, commands: commands)
        guard let native = NSApp.mainMenu else { throw EditorVerificationError.failed("Native menus missing") }
        let inventory = NotebookMenus.inventory(native)
        try JSONSerialization.data(withJSONObject: ["nativeMenuTitles": inventory, "ribbon": InterfaceCatalog.ribbon], options: [.prettyPrinted, .sortedKeys]).write(to: directory.appendingPathComponent("interface-inventory.json"))
        try gallery(ListGallery(numbered: false, formatting: commands.formatting, dismiss: {}), name: "bullets", width: 435, height: 180, directory: directory)
        try gallery(ListGallery(numbered: true, formatting: commands.formatting, dismiss: {}), name: "numbering", width: 435, height: 350, directory: directory)
        for kind in ["highlight", "font", "ink", "paper"] {
            try gallery(ColourGallery(kind: kind, choose: { _ in }), name: kind, width: kind == "highlight" ? 150 : 200, height: kind == "highlight" ? 265 : kind == "paper" ? 220 : 285, directory: directory)
        }
        try gallery(PaperGallery(commands: commands, dismiss: {}), name: "paper-style", width: 300, height: 255, directory: directory)
        try gallery(TableGrid(formatting: commands.formatting, dismiss: {}), name: "insert-table", width: 250, height: 225, directory: directory)
    }

    private static func gallery<V: View>(_ view: V, name: String, width: Double, height: Double, directory: URL) throws {
        let host = NSHostingView(rootView: view.preferredColorScheme(.dark))
        let size = NSSize(width: max(width, host.fittingSize.width), height: max(height, host.fittingSize.height))
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: size), styleMask: [.borderless], backing: .buffered, defer: false)
        host.frame = NSRect(origin: .zero, size: size); window.contentView = host
        host.layoutSubtreeIfNeeded(); window.display()
        guard let bitmap = host.bitmapImageRepForCachingDisplay(in: host.bounds) else { throw EditorVerificationError.failed("Gallery bitmap allocation failed") }
        host.cacheDisplay(in: host.bounds, to: bitmap)
        guard let png = bitmap.representation(using: .png, properties: [:]) else { throw EditorVerificationError.failed("Gallery encoding failed") }
        try png.write(to: directory.appendingPathComponent("gallery-\(name).png"), options: .atomic)
    }

    public static func render(session: NotebookSession, to url: URL, width: Double, height: Double, commands: EditorCommands? = nil) throws {
        guard width.isFinite, height.isFinite, width >= 960, width <= 2560, height >= 600, height <= 2000 else {
            throw EditorVerificationError.failed("Preview dimensions are outside the supported window range")
        }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: width, height: height), styleMask: [.borderless], backing: .buffered, defer: false)
        let host = NSHostingView(rootView: EditorView(session: session, commands: commands))
        host.frame = NSRect(x: 0, y: 0, width: width, height: height)
        window.contentView = host
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
        window.display()
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(width), pixelsHigh: Int(height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0) else { throw EditorVerificationError.failed("Cannot allocate native preview") }
        bitmap.size = NSSize(width: width, height: height)
        host.cacheDisplay(in: host.bounds, to: bitmap)
        guard let png = bitmap.representation(using: .png, properties: [:]) else { throw EditorVerificationError.failed("Cannot encode native preview") }
        try png.write(to: url, options: .atomic)
    }
}
