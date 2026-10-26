import AppKit
import SwiftUI
import MarkdownNotes

@MainActor public final class MarkdownApplication: NSObject, NSApplicationDelegate, NSWindowDelegate {
    public let session: MarkdownSession
    public var window: NSWindow?
    public init(vault: URL) throws { session = try MarkdownSession(vault: MarkdownVault(root: vault)) }
    public func applicationDidFinishLaunching(_ notification: Notification) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "O2N · Markdown"; window.minSize = NSSize(width: 900, height: 600)
        let controller = NSHostingController(rootView: MarkdownEditorView(session: session))
        window.contentViewController = controller; window.delegate = self
        self.window = window
        let menu = NSMenu(); let appItem = NSMenuItem(); let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit O2N", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu; menu.addItem(appItem)
        let fileItem = NSMenuItem(); let file = NSMenu(title: "File")
        file.addItem(withTitle: "New local note", action: #selector(newLocal(_:)), keyEquivalent: "n").target = self
        file.addItem(withTitle: "Open local Markdown…", action: #selector(openLocal(_:)), keyEquivalent: "o").target = self
        file.addItem(withTitle: "Save locally", action: #selector(saveLocally(_:)), keyEquivalent: "s").target = self
        file.addItem(withTitle: "Sync page", action: #selector(syncPage(_:)), keyEquivalent: "").target = self
        fileItem.submenu = file; menu.addItem(fileItem)
        let editItem = NSMenuItem(); let edit = NSMenu(title: "Edit")
        for (title, action, key) in [("Undo", "undo:", "z"), ("Cut", "cut:", "x"), ("Copy", "copy:", "c"), ("Paste", "paste:", "v"), ("Select All", "selectAll:", "a")] {
            edit.addItem(withTitle: title, action: NSSelectorFromString(action), keyEquivalent: key)
        }
        editItem.submenu = edit; menu.addItem(editItem); NSApp.mainMenu = menu
        window.center(); window.makeKeyAndOrderFront(nil)
        session.startBackgroundRefresh()
        // Normal explicit app launch may show a window; tests never call this lifecycle callback.
    }
    public func windowShouldClose(_ sender: NSWindow) -> Bool { session.save() }
    @objc private func saveLocally(_ sender: Any?) { if !session.busy { session.save() } }
    @objc private func syncPage(_ sender: Any?) { if !session.busy { session.sync() } }
    @objc private func newLocal(_ sender: Any?) { session.newLocal() }
    @objc private func openLocal(_ sender: Any?) { session.openLocal() }
    public func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard session.save() else { return .terminateCancel }
        session.stopBackgroundRefresh(); session.cancel(); return .terminateNow
    }
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
