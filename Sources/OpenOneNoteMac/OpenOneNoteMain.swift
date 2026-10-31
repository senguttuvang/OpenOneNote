import AppKit
import SwiftUI
import NotebookEditor
import MarkdownEditor

@MainActor private final class ApplicationDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let session: NotebookSession
    var window: NSWindow?
    init(session: NotebookSession) { self.session = session }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "OpenOneNote"; window.minSize = NSSize(width: 960, height: 640)
        window.appearance = NSAppearance(named: .darkAqua)
        window.contentView = NSHostingView(rootView: EditorView(session: session)); window.delegate = self
        self.window = window
        installMenus()
        window.center(); window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? { session.undoManager }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.makeFirstResponder(nil)
        return session.notebook == nil || session.saveNow()
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        window?.makeFirstResponder(nil)
        return session.notebook == nil || session.saveNow() ? .terminateNow : .terminateCancel
    }
    @objc func saveNotebook(_ sender: Any?) { session.saveNow() }
    @objc func newPage(_ sender: Any?) { session.addPage() }

    private func installMenus() {
        let menu = NSMenu()
        func submenu(_ title: String) -> NSMenu {
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            let child = NSMenu(title: title); item.submenu = child; menu.addItem(item); return child
        }
        let app = submenu("OpenOneNote")
        app.addItem(withTitle: "About OpenOneNote", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        app.addItem(.separator())
        app.addItem(withTitle: "Quit OpenOneNote", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        let file = submenu("File")
        file.addItem(withTitle: "New Page", action: #selector(newPage(_:)), keyEquivalent: "n").target = self
        file.addItem(withTitle: "Save", action: #selector(saveNotebook(_:)), keyEquivalent: "s").target = self
        let edit = submenu("Edit")
        edit.addItem(withTitle: "Undo", action: NSSelectorFromString("undo:"), keyEquivalent: "z")
        let redo = edit.addItem(withTitle: "Redo", action: NSSelectorFromString("redo:"), keyEquivalent: "z"); redo.keyEquivalentModifierMask = [.command, .shift]
        edit.addItem(.separator())
        for (title, action, key) in [("Cut", "cut:", "x"), ("Copy", "copy:", "c"), ("Paste", "paste:", "v"), ("Select All", "selectAll:", "a")] {
            edit.addItem(withTitle: title, action: NSSelectorFromString(action), keyEquivalent: key)
        }
        let format = submenu("Format")
        format.addItem(withTitle: "Bold", action: NSSelectorFromString("toggleBoldface:"), keyEquivalent: "b")
        format.addItem(withTitle: "Italic", action: NSSelectorFromString("toggleItalics:"), keyEquivalent: "i")
        format.addItem(withTitle: "Underline", action: NSSelectorFromString("underline:"), keyEquivalent: "u")
        format.addItem(withTitle: "Show Fonts", action: #selector(NSFontManager.orderFrontFontPanel(_:)), keyEquivalent: "t").target = NSFontManager.shared
        NSApp.mainMenu = menu
    }
}

@main @MainActor private struct OpenOneNoteMain {
    static func main() {
        let app = NSApplication.shared
        let arguments = Array(CommandLine.arguments.dropFirst())
        if arguments.first == "--cloud-sign-in" {
            app.setActivationPolicy(.accessory)
            guard arguments.count == 2 else { FileHandle.standardError.write(Data("Expected configured vault directory\n".utf8)); exit(1) }
            let delegate = CloudSignInApplication(vault: URL(fileURLWithPath: arguments[1]))
            app.delegate = delegate
            withExtendedLifetime(delegate) { app.run() }
            return
        }
        if arguments.first == "--signing-status" {
            app.setActivationPolicy(.prohibited)
            do {
                guard arguments.count == 1 else { throw EditorVerificationError.failed("Signing status takes no extra arguments") }
                try CloudVerification.signingStatus()
            } catch { FileHandle.standardError.write(Data("Native signing capability: \(error.localizedDescription)\n".utf8)); exit(2) }
            return
        }
        if arguments.first == "--cloud-status" || arguments.first == "--cloud-self-test" || arguments.first == "--cloud-roundtrip" || arguments.first == "--cloud-diagnose" {
            app.setActivationPolicy(.prohibited)
            guard arguments.count == 2 else { FileHandle.standardError.write(Data("Expected configured vault directory\n".utf8)); exit(1) }
            Task { @MainActor in
                do {
                    let vault = URL(fileURLWithPath: arguments[1])
                    if arguments[0] == "--cloud-status" { try await CloudVerification.status(vault: vault) }
                    else if arguments[0] == "--cloud-diagnose" { try await CloudVerification.diagnose(vault: vault) }
                    else if arguments[0] == "--cloud-roundtrip" { try await CloudVerification.officialRoundtrip(vault: vault) }
                    else { try await CloudVerification.exercise(vault: vault) }
                    exit(0)
                }
                catch { FileHandle.standardError.write(Data("Native cloud status: \(error.localizedDescription)\n".utf8)); exit(2) }
            }
            CFRunLoopRun(); return
        }
        if arguments.first == "--diagram-self-test" {
            app.setActivationPolicy(.prohibited)
            guard arguments.count == 2 else { FileHandle.standardError.write(Data("Expected diagram fixture directory\n".utf8)); exit(1) }
            Task { @MainActor in
                do { try await DiagramVerification.exercise(at: URL(fileURLWithPath: arguments[1])); exit(0) }
                catch { FileHandle.standardError.write(Data("Diagram verification failed: \(error)\n".utf8)); exit(1) }
            }
            CFRunLoopRun()
            return
        }
        if arguments.first == "--markdown-self-test" {
            app.setActivationPolicy(.prohibited)
            do {
                guard arguments.count == 2 else { throw EditorVerificationError.failed("Expected Markdown fixture directory") }
                try MarkdownVerification.exercise(at: URL(fileURLWithPath: arguments[1]))
                print("Hidden Markdown edit/undo/reopen/render passed")
            } catch { FileHandle.standardError.write(Data("Markdown verification failed: \(error)\n".utf8)); exit(1) }
            return
        }
        if arguments.first == "--self-test" || arguments.first == "--render-preview" {
            app.setActivationPolicy(.prohibited)
            do {
                guard arguments.count >= 2, arguments.count <= 3 else { throw EditorVerificationError.failed("Expected output path and optional preview width") }
                let output = URL(fileURLWithPath: arguments[1])
                if arguments[0] == "--self-test" { try NativeVerification.exerciseEditor(at: output); print("Native text edit, undo/redo, save and reopen passed") }
                else {
                    let width: Double
                    if arguments.count == 3 {
                        guard let value = Double(arguments[2]) else { throw EditorVerificationError.failed("Preview width must be a number") }
                        width = value
                    } else { width = 1280 }
                    let fixture = FileManager.default.temporaryDirectory.appendingPathComponent("OpenOneNote-\(UUID()).json")
                    defer { try? FileManager.default.removeItem(at: fixture) }
                    let session = try NativeVerification.fixture(at: fixture)
                    try NativeVerification.render(session: session, to: output, width: width, height: width == 1728 ? 1088 : 800)
                    print("Rendered native preview")
                }
            } catch { FileHandle.standardError.write(Data("Native verification failed: \(error)\n".utf8)); exit(1) }
            return
        }
        if !arguments.contains("--legacy") && !arguments.contains("--notebook") {
            do {
                guard arguments.isEmpty || (arguments.count == 2 && arguments[0] == "--vault") else {
                    throw EditorVerificationError.failed("Use --vault <directory>, --legacy or --notebook <file>")
                }
                let vault = arguments.isEmpty
                    ? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("OpenOneNote/Markdown")
                    : URL(fileURLWithPath: arguments[1])
                app.setActivationPolicy(.regular)
                let delegate = try MarkdownApplication(vault: vault)
                app.delegate = delegate
                withExtendedLifetime(delegate) { app.run() }
            } catch { FileHandle.standardError.write(Data("Markdown workspace failed: \(error)\n".utf8)); exit(1) }
            return
        }
        let dataURL: URL
        if let index = arguments.firstIndex(of: "--notebook") {
            guard arguments.count > index + 1 else {
                FileHandle.standardError.write(Data("--notebook requires a file path\n".utf8)); exit(1)
            }
            dataURL = URL(fileURLWithPath: arguments[index + 1])
        }
        else { dataURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("OpenOneNote/notebook.json") }
        app.setActivationPolicy(.regular)
        let delegate = ApplicationDelegate(session: NotebookSession(url: dataURL))
        app.delegate = delegate
        withExtendedLifetime(delegate) { app.run() }
    }
}
