import AppKit
import Foundation
import MarkdownNotes
import OneNoteGraph

@MainActor public enum CloudVerification {
    public static func signingStatus() throws {
        _ = try NativeSigning.privateKeychainGroup()
        print("Developer signature and O2N private Keychain entitlement verified. Native user sign-in is a separate step.")
    }
    public static func status(vault: URL) async throws {
        let session = try MarkdownSession(vault: MarkdownVault(root: vault))
        guard let graph = session.graph else { throw NotesError.invalid("Native Microsoft configuration was not accepted: " + session.message) }
        _ = try await graph.authorization.accessToken()
        let notebooks = try await graph.list(root: "me", path: "notebooks?$top=1")
        print("Native MSAL delegated Notes access verified; hierarchy request succeeded (\(notebooks.count) sampled notebook). No cloud writes performed.")
    }
}
