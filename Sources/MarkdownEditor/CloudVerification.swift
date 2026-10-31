import AppKit
import Carbon
import Foundation
import MarkdownNotes
import OneNoteGraph

@MainActor public enum CloudVerification {
    /// Dedicated human-only consent window. It never opens an existing notebook or edits content.
    public static func signIn(vault: URL, authenticationReady: ((MicrosoftSignIn) -> Void)? = nil) async throws {
        let session = try MarkdownSession(vault: MarkdownVault(root: vault))
        guard let auth = session.signIn else { throw NotesError.invalid(session.message) }
        authenticationReady?(auth)
        auth.progress = { FileHandle.standardError.write(Data(($0 + "\n").utf8)) }
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 480, height: 160), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "O2N · Microsoft consent"
        let controller = NSViewController()
        controller.view = NSTextField(wrappingLabelWithString: "Sign in to the dedicated OpenOneNote registration using your PearlThoughts account. Approve only delegated Notes access. This window closes when sign-in completes.")
        window.contentViewController = controller
        window.center(); window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true) // Human-only consent command; hidden verification never enters this path.
        defer { window.orderOut(nil) }
        try await auth.signIn(presenting: controller)
        try await status(vault: vault)
        print("Native dedicated-registration sign-in completed; OAuth state persisted in O2N’s macOS Keychain item.")
    }
    public static func signingStatus() throws {
        try NativeSigning.verify()
        print("O2N signature integrity verified. AppAuth uses an app-private macOS Keychain item; consent, persistence and API acceptance are separate checks.")
    }
    public static func status(vault: URL) async throws {
        let session = try MarkdownSession(vault: MarkdownVault(root: vault))
        guard let graph = session.graph else { throw NotesError.invalid("Native Microsoft configuration was not accepted: " + session.message) }
        _ = try await graph.authorization.accessToken()
        let notebooks = try await graph.list(root: session.root, path: "notebooks?$top=1")
        print("Native AppAuth delegated Notes access verified; hierarchy request succeeded (\(notebooks.count) sampled notebook). No cloud writes performed.")
    }
}

/// A LaunchServices URL callback must reach the same retained AppAuth session that initiated it.
@MainActor public final class CloudSignInApplication: NSObject, NSApplicationDelegate {
    private let vault: URL
    private var authentication: MicrosoftSignIn?
    public init(vault: URL) { self.vault = vault }
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Match AppAuth's macOS sample: accessory helpers must explicitly receive GetURL events.
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(handleGetURL(_:withReplyEvent:)),
                                                     forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        Task { @MainActor in
            do {
                try await CloudVerification.signIn(vault: vault) { self.authentication = $0 }
                exit(0)
            } catch {
                FileHandle.standardError.write(Data("O2N sign-in: \(error.localizedDescription)\n".utf8)); exit(2)
            }
        }
    }
    @objc private func handleGetURL(_ event: NSAppleEventDescriptor, withReplyEvent reply: NSAppleEventDescriptor) {
        guard let value = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: value) else { return }
        let accepted = authentication?.resume(url) ?? false
        FileHandle.standardError.write(Data("Native GetURL AppleEvent received; matched active OAuth flow: \(accepted).\n".utf8))
    }
    public func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            let accepted = authentication?.resume(url) ?? false
            FileHandle.standardError.write(Data("Native URL event received; matched active OAuth flow: \(accepted).\n".utf8))
        }
    }
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    public func applicationWillTerminate(_ notification: Notification) {
        authentication?.cancel()
        NSAppleEventManager.shared().removeEventHandler(forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
}
