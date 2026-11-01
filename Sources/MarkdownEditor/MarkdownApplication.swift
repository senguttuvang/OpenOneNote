import AppKit
import SwiftUI
import MarkdownNotes
import OneNoteGraph

@MainActor public final class MarkdownApplication: NSObject, NSApplicationDelegate, NSWindowDelegate {
    public let session: MarkdownSession
    public var window: NSWindow?
    private var presentations: [NativeShellState] = []
    private var wakeObserver: NSObjectProtocol?
    public init(vault: URL, sharedMicrosoftWorkspace: URL? = nil) throws {
        session = try MarkdownSession(vault: MarkdownVault(root: vault))
        if session.microsoftConfiguration == nil {
            let shared = sharedMicrosoftWorkspace ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("OpenOneNote/Markdown")
            let source = try MarkdownVault(root: shared).safeURL(".o2n/config/microsoft-client.json")
            if FileManager.default.fileExists(atPath: source.path) {
                let configuration = try JSONDecoder().decode(MicrosoftConfiguration.self, from: Data(contentsOf: source))
                session.root = configuration.graphRoot ?? "me"
                session.configure(clientID: configuration.clientID, tenant: configuration.tenant, redirect: configuration.redirectURI, persist: false)
            }
        }
    }
    public func applicationDidFinishLaunching(_ notification: Notification) {
        openWindow()
        session.startBackgroundRefresh()
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.session.refreshSelectedPage() }
        }
    }
    private func openWindow() {
        let shell = NativeShellState(session: session)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.title = "OpenOneNote"; window.minSize = NSSize(width: 960, height: 600)
        window.titleVisibility = .hidden; window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        let controller = NSHostingController(rootView: MarkdownEditorView(session: session, presentation: shell))
        controller.safeAreaRegions = []
        window.contentViewController = controller; window.delegate = self
        shell.window = window; shell.newWindow = { [weak self] in self?.openWindow() }
        presentations.append(shell); self.window = window
        NativeShellMenus.install(shell: shell)
        window.center(); window.makeKeyAndOrderFront(nil)
        // Explicit user launch/window commands may show windows; verification never invokes this lifecycle.
    }
    public func windowShouldClose(_ sender: NSWindow) -> Bool { session.save() }
    public func windowWillClose(_ notification: Notification) {
        guard let closed = notification.object as? NSWindow else { return }
        presentations.removeAll { $0.window === closed }
        window = presentations.last?.window
    }
    public func applicationDidBecomeActive(_ notification: Notification) { session.refreshSelectedPage() }
    public func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { _ = session.signIn?.resume(url) }
    }
    public func windowDidBecomeKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow, let shell = presentations.first(where: { $0.window === window }) {
            self.window = window; NativeShellMenus.install(shell: shell)
        }
        session.refreshSelectedPage()
    }
    public func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard session.save() else { return .terminateCancel }
        if let wakeObserver { NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver) }
        session.stopBackgroundRefresh(); session.cancel(); return .terminateNow
    }
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
