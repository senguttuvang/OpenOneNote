import AppKit
import SwiftUI
import NotebookEditor
import MarkdownEditor

@MainActor private final class ApplicationDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let session: NotebookSession
    let commands: EditorCommands
    let inspection: Bool
    var windows: [NSWindow] = []
    init(session: NotebookSession, inspection: Bool = false) { self.session = session; commands = EditorCommands(session: session); self.inspection = inspection }
    func applicationDidFinishLaunching(_ notification: Notification) {
        commands.newWindow = { [weak self] in self?.makeWindow() }
        NotebookMenus.install(commands: commands)
        makeWindow()
    }
    private func makeWindow() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: inspection ? 1728 : 1280, height: inspection ? 1088 : 800), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.title = inspection ? "OpenOneNote — UI Inspection" : "OpenOneNote"
        window.titleVisibility = .hidden; window.titlebarAppearsTransparent = true
        window.minSize = NSSize(width: 960, height: 640); window.appearance = NSAppearance(named: .darkAqua)
        let host = NSHostingView(rootView: EditorView(session: session, commands: commands))
        host.safeAreaRegions = []
        window.contentView = host; window.delegate = self
        windows.append(window); window.center()
        if inspection { window.orderBack(nil) }
        else { window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
        Task { @MainActor [weak window] in
            guard let window, let root = window.contentView else { return }
            root.layoutSubtreeIfNeeded()
            @MainActor func editor(in view: NSView) -> NotebookTextView? {
                if let text = view as? NotebookTextView { return text }
                for child in view.subviews { if let text = editor(in: child) { return text } }
                return nil
            }
            if let text = editor(in: root) { window.initialFirstResponder = text; window.makeFirstResponder(text) }
        }
    }
    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? { session.undoManager }
    func windowShouldClose(_ sender: NSWindow) -> Bool { sender.makeFirstResponder(nil); return session.notebook == nil || session.saveNow() }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        windows.forEach { $0.makeFirstResponder(nil) }
        return session.notebook == nil || session.saveNow() ? .terminateNow : .terminateCancel
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
        if arguments.first == "--cloud-status" || arguments.first == "--cloud-self-test" || arguments.first == "--cloud-roundtrip" || arguments.first == "--cloud-diagnose" || arguments.first == "--cloud-fixture-status" {
            app.setActivationPolicy(.prohibited)
            guard arguments.count == 2 else { FileHandle.standardError.write(Data("Expected configured vault directory\n".utf8)); exit(1) }
            Task { @MainActor in
                do {
                    let vault = URL(fileURLWithPath: arguments[1])
                    if arguments[0] == "--cloud-status" { try await CloudVerification.status(vault: vault) }
                    else if arguments[0] == "--cloud-diagnose" { try await CloudVerification.diagnose(vault: vault) }
                    else if arguments[0] == "--cloud-fixture-status" { try await CloudVerification.fixtureStatus(vault: vault) }
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
        if arguments.first == "--self-test" || arguments.first == "--render-preview" || arguments.first == "--render-interface" {
            app.setActivationPolicy(.prohibited)
            do {
                guard arguments.count >= 2, arguments.count <= 3 else { throw EditorVerificationError.failed("Expected output path and optional preview width") }
                let output = URL(fileURLWithPath: arguments[1])
                if arguments[0] == "--self-test" { try NativeVerification.exerciseEditor(at: output); print("Native text edit, undo/redo, save and reopen passed") }
                else {
                    let width: Double
                    if arguments.count == 3 { guard let value = Double(arguments[2]) else { throw EditorVerificationError.failed("Preview width must be a number") }; width = value }
                    else { width = 1728 }
                    let fixture = FileManager.default.temporaryDirectory.appendingPathComponent("OpenOneNote-\(UUID()).json")
                    defer { try? FileManager.default.removeItem(at: fixture) }
                    let session = try NativeVerification.fixture(at: fixture)
                    if arguments[0] == "--render-interface" { try NativeVerification.renderInterface(session: session, directory: output) }
                    else { try NativeVerification.render(session: session, to: output, width: width, height: width == 1728 ? 1088 : 800) }
                    print("Rendered native interface")
                }
            } catch { FileHandle.standardError.write(Data("Native verification failed: \(error)\n".utf8)); exit(1) }
            return
        }
        let inspection = arguments.first == "--inspect-ui"
        if !inspection && !arguments.contains("--legacy") && !arguments.contains("--notebook") {
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
        if inspection {
            guard arguments.count == 2 else { FileHandle.standardError.write(Data("--inspect-ui requires a new synthetic notebook path\n".utf8)); exit(1) }
            dataURL = URL(fileURLWithPath: arguments[1])
            guard !FileManager.default.fileExists(atPath: dataURL.path) else { FileHandle.standardError.write(Data("Inspection refuses to replace an existing notebook\n".utf8)); exit(1) }
        } else if let index = arguments.firstIndex(of: "--notebook") {
            guard arguments.count > index + 1 else { FileHandle.standardError.write(Data("--notebook requires a file path\n".utf8)); exit(1) }
            dataURL = URL(fileURLWithPath: arguments[index + 1])
        } else { dataURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("OpenOneNote/notebook.json") }
        app.setActivationPolicy(inspection ? .prohibited : .regular)
        do {
            let session = inspection ? try NativeVerification.fixture(at: dataURL) : NotebookSession(url: dataURL)
            let delegate = ApplicationDelegate(session: session, inspection: inspection)
            app.delegate = delegate
            withExtendedLifetime(delegate) { app.run() }
        } catch { FileHandle.standardError.write(Data("Native startup failed: \(error)\n".utf8)); exit(1) }
    }
}
