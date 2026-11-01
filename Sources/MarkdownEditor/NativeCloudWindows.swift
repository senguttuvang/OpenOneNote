import AppKit
import SwiftUI

/// Agent verification builds these windows hidden; ordinary user actions present them.
@MainActor final class NativeCloudWindows: NSObject, NSWindowDelegate {
    private weak var shell: NativeShellState?
    private var controllers: [String: NSWindowController] = [:]
    init(shell: NativeShellState) { self.shell = shell }
    func present(_ surface: NativeShellSheet) {
        guard let shell else { return }
        let browser = surface == .notebooks
        let key = browser ? "notebooks" : "storage"
        if let existing = controllers[key]?.window {
            if NSApp.activationPolicy() != .prohibited { existing.makeKeyAndOrderFront(nil) }
            return
        }
        let size = browser ? NSSize(width: 1280, height: 800) : NSSize(width: 580, height: 700)
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: size), styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        window.title = browser ? "Open Notebook" : "Storage Accounts"
        window.minSize = browser ? NSSize(width: 960, height: 600) : size
        window.isReleasedWhenClosed = false; window.delegate = self
        let close: () -> Void = { [weak window] in window?.performClose(nil) }
        if browser { window.contentViewController = NSHostingController(rootView: NativeNotebookBrowser(shell: shell, closeWindow: close)) }
        else { window.contentViewController = NSHostingController(rootView: NativeStorageAccounts(shell: shell, closeWindow: close)) }
        controllers[key] = NSWindowController(window: window)
        if NSApp.activationPolicy() != .prohibited { window.center(); window.makeKeyAndOrderFront(nil) }
    }
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if let key = controllers.first(where: { $0.value.window === window })?.key { controllers.removeValue(forKey: key) }
        window.contentViewController = nil
    }
}
