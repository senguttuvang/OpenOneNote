import Foundation
import Security
import MarkdownNotes

public enum NativeSigning {
    /// Inspect only this executable's signature. Never probe another app's credentials or Keychain items.
    public static func privateKeychainGroup() throws -> String {
        guard let executable = Bundle.main.executableURL, let bundleID = Bundle.main.bundleIdentifier else {
            throw NotesError.unsupported("Native Microsoft sign-in requires the packaged, developer-signed O2N app.")
        }
        var code: SecStaticCode?
        guard SecStaticCodeCreateWithPath(executable as CFURL, [], &code) == errSecSuccess, let code,
              SecStaticCodeCheckValidity(code, [], nil) == errSecSuccess else {
            throw NotesError.unsupported("O2N's executable signature is invalid.")
        }
        var information: CFDictionary?
        guard SecCodeCopySigningInformation(code, SecCSFlags(rawValue: kSecCSSigningInformation), &information) == errSecSuccess,
              let values = information as? [String: Any],
              let team = values[kSecCodeInfoTeamIdentifier as String] as? String,
              let entitlements = values[kSecCodeInfoEntitlementsDict as String] as? [String: Any],
              let groups = entitlements["keychain-access-groups"] as? [String], groups.contains(team + "." + bundleID) else {
            throw NotesError.unsupported("Native Microsoft sign-in requires an Apple developer-signed build with O2N's private Keychain entitlement. This build supports offline editing; configure native credential caching with an approved identity/profile.")
        }
        return team + "." + bundleID
    }
}
