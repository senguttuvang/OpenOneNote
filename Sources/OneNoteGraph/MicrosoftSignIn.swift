import AppKit
import Foundation
@preconcurrency import MSAL
import MarkdownNotes

/// O2N owns its delegated identity through MSAL. No token is persisted by O2N or logged.
@MainActor public final class MicrosoftSignIn: GraphAuthorization {
    private let application: MSALPublicClientApplication
    private var account: MSALAccount?
    public static let scopes = ["https://graph.microsoft.com/Notes.ReadWrite"]

    public init(clientID: String, tenant: String = "common", redirectURI: String) throws {
        let redirect = URLComponents(string: redirectURI)
        let isLoopback = redirect?.scheme == "http" && redirect?.host == "localhost"
        let isNative = redirect?.scheme?.hasPrefix("msauth.") == true && redirect?.host == "auth"
        guard !clientID.isEmpty, UUID(uuidString: clientID) != nil,
              tenant.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "-") }), !tenant.isEmpty,
              redirect?.user == nil, redirect?.password == nil, redirect?.fragment == nil,
              isLoopback || isNative else {
            throw NotesError.invalid("Configure a sanctioned Microsoft public-client registration and registered redirect URI.")
        }
        let authority = try MSALAADAuthority(url: URL(string: "https://login.microsoftonline.com/\(tenant)")!)
        let config = MSALPublicClientApplicationConfig(clientId: clientID, redirectUri: redirectURI, authority: authority)
        config.cacheConfig.keychainSharingGroup = try NativeSigning.privateKeychainGroup()
        application = try MSALPublicClientApplication(configuration: config)
        // Never silently choose between multiple identities.
        let accounts = try application.allAccounts()
        account = accounts.count == 1 ? accounts[0] : nil
    }
    public func accessToken() async throws -> String {
        guard let account else { throw NotesError.authenticationRequired }
        let parameters = MSALSilentTokenParameters(scopes: Self.scopes, account: account)
        let token: String = try await withCheckedThrowingContinuation { continuation in
            application.acquireTokenSilent(with: parameters) { result, _ in
                guard let result else { continuation.resume(throwing: NotesError.authenticationRequired); return }
                continuation.resume(returning: result.accessToken)
            }
        }
        try Task.checkCancellation(); return token
    }
    public func identityKey() async throws -> String {
        guard let identifier = account?.identifier else { throw NotesError.authenticationRequired }
        return MarkdownVault.hash(identifier)
    }
    /// Invoke only from the user's Sign In action. Background verification never opens consent UI.
    public func signIn(presenting controller: NSViewController) async throws {
        let web = MSALWebviewParameters(authPresentationViewController: controller)
        let parameters = MSALInteractiveTokenParameters(scopes: Self.scopes, webviewParameters: web)
        parameters.promptType = .selectAccount
        let result: MSALResult = try await withCheckedThrowingContinuation { continuation in
            application.acquireToken(with: parameters) { result, _ in
                guard let result else { continuation.resume(throwing: NotesError.authenticationRequired); return }
                continuation.resume(returning: result)
            }
        }
        try Task.checkCancellation()
        account = result.account
    }
    public func cancel() { _ = MSALPublicClientApplication.cancelCurrentWebAuthSession() }
}
