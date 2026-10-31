import Foundation
import Security
import MarkdownNotes

public enum NativeSigning {
    /// Signature integrity is separate from user consent and actual Keychain/API acceptance.
    public static func verify() throws {
        guard let executable = Bundle.main.executableURL,
              Bundle.main.bundleIdentifier == "dev.senguttuvang.OpenOneNote" else {
            throw NotesError.unsupported("Use the packaged O2N app for native sign-in.")
        }
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(executable as CFURL, [], &code) == errSecSuccess, let code,
              SecStaticCodeCheckValidity(code, [], nil) == errSecSuccess else {
            throw NotesError.unsupported("O2N’s executable signature is invalid.")
        }
    }
}
