import Foundation
import Security
import LocalAuthentication
import MarkdownNotes

/// AppAuth owns renewal. Its secure archive lives only in an app-private macOS login Keychain item.
public protocol MicrosoftCredentialStore: Sendable {
    func load(allowInteraction: Bool) throws -> Data?
    func save(_ data: Data, allowInteraction: Bool) throws
}

public struct MicrosoftKeychainStore: MicrosoftCredentialStore {
    private let account: String
    private static let service = "dev.senguttuvang.OpenOneNote.oauth"
    public init(clientID: String, tenant: String) {
        account = MarkdownVault.hash(clientID.lowercased() + ":" + tenant.lowercased())
    }
    private var query: [String: Any] {
        [kSecClass as String: kSecClassGenericPassword,
         kSecAttrService as String: Self.service, kSecAttrAccount as String: account,
         kSecAttrSynchronizable as String: false]
    }
    public func load(allowInteraction: Bool = false) throws -> Data? {
        var request = query
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        if !allowInteraction {
            let context = LAContext(); context.interactionNotAllowed = true
            request[kSecUseAuthenticationContext as String] = context
        }
        var result: CFTypeRef?
        let status = SecItemCopyMatching(request as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else { throw Self.failure(status) }
        return data
    }
    public func save(_ data: Data, allowInteraction: Bool) throws {
        let update = [kSecValueData as String: data]
        var request = query
        if !allowInteraction {
            let context = LAContext(); context.interactionNotAllowed = true
            request[kSecUseAuthenticationContext as String] = context
        }
        let status = SecItemUpdate(request as CFDictionary, update as CFDictionary)
        if status == errSecItemNotFound {
            var item = request
            item[kSecValueData as String] = data
            item[kSecAttrLabel as String] = "O2N Microsoft delegated sign-in"
            let added = SecItemAdd(item as CFDictionary, nil)
            guard added == errSecSuccess else { throw Self.failure(added) }
        } else if status != errSecSuccess { throw Self.failure(status) }
    }
    private static func failure(_ status: OSStatus) -> NotesError {
        .unsupported("O2N Keychain access failed (\(status)). Use Sign in to authorize access to O2N’s own item; credentials were preserved. No file cache was created.")
    }
}
