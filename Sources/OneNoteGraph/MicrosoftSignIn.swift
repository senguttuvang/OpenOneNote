import AppKit
import Foundation
@preconcurrency import AppAuth
import MarkdownNotes

// SDK callback results are transferred once to the owning main actor, then never shared.
private struct DiscoveredMicrosoftService: @unchecked Sendable { let value: OIDServiceConfiguration }
private struct MicrosoftAuthorizationResponse: @unchecked Sendable { let value: OIDAuthorizationResponse }
private struct MicrosoftTokenResponse: @unchecked Sendable { let value: OIDTokenResponse }

/// Dedicated public-client authorization-code/PKCE identity. SDK tokens stay inside this adapter.
@MainActor public final class MicrosoftSignIn: GraphAuthorization {
    private let clientID: String
    private let issuer: URL
    private let redirect: URL
    private let store: any MicrosoftCredentialStore
    private var state: OIDAuthState?
    private var flow: (any OIDExternalUserAgentSession)?
    private var cacheFailure: Error?
    public var progress: (@MainActor (String) -> Void)?
    public static let scopes = ["openid", "profile", "offline_access", "https://graph.microsoft.com/Notes.ReadWrite.All"]
    public static let storageScopes = ["https://graph.microsoft.com/Files.Read", "https://graph.microsoft.com/Sites.Read.All"]
    public func account() async throws -> MicrosoftAccount {
        let key = try await identityKey()
        guard let raw = state?.lastTokenResponse?.idToken, let token = OIDIDToken(idTokenString: raw), token.issuer == issuer else { throw NotesError.authenticationRequired }
        let claims = token.claims
        let email = claims["preferred_username"] as? String ?? claims["email"] as? String ?? ""
        let name = claims["name"] as? String ?? (email.isEmpty ? "Microsoft account" : email)
        let granted = Set((state?.scope ?? "").split(separator: " ").map { String($0).replacingOccurrences(of: "https://graph.microsoft.com/", with: "") })
        return MicrosoftAccount(key: key, name: name, email: email, storageConnected: granted.contains("Sites.Read.All") && granted.contains("Files.Read"))
    }
    private static let configureNetworking: Void = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil; configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 60; configuration.timeoutIntervalForResource = 120
        OIDURLSessionProvider.setSession(URLSession(configuration: configuration))
    }()

    public init(clientID: String, tenant: String, redirectURI: String,
                store: (any MicrosoftCredentialStore)? = nil) throws {
        try Self.validate(clientID: clientID, tenant: tenant, redirectURI: redirectURI)
        _ = Self.configureNetworking
        self.clientID = clientID
        issuer = URL(string: "https://login.microsoftonline.com/\(tenant.lowercased())/v2.0")!
        redirect = URL(string: redirectURI)!
        self.store = store ?? MicrosoftKeychainStore(clientID: clientID, tenant: tenant)
        do { try restore(allowInteraction: false) } catch { cacheFailure = error }
    }
    public static func validate(clientID: String, tenant: String, redirectURI: String) throws {
        guard UUID(uuidString: clientID) != nil, UUID(uuidString: tenant) != nil,
              ["msauth.dev.senguttuvang.OpenOneNote://auth", "msauth.dev.senguttuvang.OpenOneNote://auth/callback"].contains(redirectURI) else {
            throw NotesError.invalid("Use O2N’s dedicated single-tenant public-client registration and exact registered native callback.")
        }
    }
    private func restore(allowInteraction: Bool) throws {
        guard let data = try store.load(allowInteraction: allowInteraction) else { return }
        guard let value = try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data),
              value.lastAuthorizationResponse.request.clientID.caseInsensitiveCompare(clientID) == .orderedSame,
              value.lastAuthorizationResponse.request.redirectURL == redirect,
              value.lastAuthorizationResponse.request.configuration.issuer == issuer else {
            throw NotesError.invalid("O2N OAuth archive does not match the selected registration. Credentials were preserved.")
        }
        state = value; cacheFailure = nil
    }
    private func persist(_ state: OIDAuthState, allowInteraction: Bool = false) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: state, requiringSecureCoding: true)
        try store.save(data, allowInteraction: allowInteraction)
    }
    public func accessToken() async throws -> String {
        if let cacheFailure { throw cacheFailure }
        guard let state, state.isAuthorized, Self.hasRequiredNotesScope(state.scope) else { throw NotesError.authenticationRequired }
        let token: String = try await withCheckedThrowingContinuation { continuation in
            state.performAction { @Sendable accessToken, _, _ in
                guard let accessToken else { continuation.resume(throwing: NotesError.authenticationRequired); return }
                continuation.resume(returning: accessToken)
            }
        }
        try Task.checkCancellation()
        try persist(state)
        guard Self.hasRequiredNotesScope(state.scope) else { throw NotesError.authenticationRequired }
        return token
    }
    public func identityKey() async throws -> String {
        _ = try await accessToken()
        guard let raw = state?.lastTokenResponse?.idToken, let token = OIDIDToken(idTokenString: raw),
              token.issuer == issuer, !token.subject.isEmpty else { throw NotesError.authenticationRequired }
        return MarkdownVault.hash(issuer.absoluteString + ":" + token.subject)
    }
    public func notesScopeSummary() -> (readWrite: Bool, readWriteAll: Bool) {
        let scopes = Set((state?.scope ?? "").split(separator: " ").map(String.init))
        return (scopes.contains("Notes.ReadWrite") || scopes.contains("https://graph.microsoft.com/Notes.ReadWrite"),
                scopes.contains("Notes.ReadWrite.All") || scopes.contains("https://graph.microsoft.com/Notes.ReadWrite.All"))
    }
    nonisolated static func hasRequiredNotesScope(_ scope: String?) -> Bool {
        let values = Set((scope ?? "").split(separator: " ").map(String.init))
        return values.contains("Notes.ReadWrite.All") || values.contains("https://graph.microsoft.com/Notes.ReadWrite.All")
    }
    /// Only explicit sign-in may present browser or Keychain consent UI.
    public func signIn(presenting controller: NSViewController, connectStorage: Bool = false) async throws {
        progress?("Starting native OAuth; checking O2N’s own Keychain state.")
        guard let window = controller.view.window else { throw NotesError.invalid("Sign-in needs an O2N window.") }
        if cacheFailure != nil { try restore(allowInteraction: true) }
        let existingToken = (state?.lastTokenResponse?.idToken).flatMap { OIDIDToken(idTokenString: $0) }
        if state?.isAuthorized == true {
            do {
                _ = try await accessToken()
                if !connectStorage { return }
                if try await account().storageConnected { return }
            }
            catch NotesError.authenticationRequired { /* User initiated renewal after silent auth failed. */ }
        }
        progress?("Discovering Microsoft’s tenant-specific OAuth configuration.")
        let discovered: DiscoveredMicrosoftService = try await withCheckedThrowingContinuation { continuation in
            OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { @Sendable configuration, _ in
                guard let configuration else { continuation.resume(throwing: NotesError.invalid("Microsoft OAuth discovery failed.")); return }
                continuation.resume(returning: DiscoveredMicrosoftService(value: configuration))
            }
        }
        let configuration = discovered.value
        guard configuration.issuer == issuer,
              configuration.authorizationEndpoint.host == "login.microsoftonline.com",
              configuration.tokenEndpoint.host == "login.microsoftonline.com",
              configuration.authorizationEndpoint.scheme == "https", configuration.tokenEndpoint.scheme == "https" else {
            throw NotesError.invalid("Unexpected Microsoft OAuth endpoints.")
        }
        let request = Self.authorizationRequest(configuration: configuration, clientID: clientID, redirect: redirect, connectStorage: connectStorage)
        progress?("Presenting system-browser authorization with PKCE; awaiting the user callback.")
        let browser = MicrosoftBrowserAgent(window: window) { [weak self] in self?.progress?($0) }
        let response: MicrosoftAuthorizationResponse = try await withCheckedThrowingContinuation { continuation in
            flow = OIDAuthorizationService.present(request, externalUserAgent: browser) { @Sendable value, error in
                guard let value else {
                    continuation.resume(throwing: Self.authorizationFailure(error)); return
                }
                continuation.resume(returning: MicrosoftAuthorizationResponse(value: value))
            }
        }
        defer { flow = nil }
        progress?("Browser callback validated by AppAuth; redeeming the authorization code with Microsoft.")
        guard let exchange = response.value.tokenExchangeRequest() else { throw NotesError.invalid("Microsoft returned no authorization-code exchange request.") }
        let token: MicrosoftTokenResponse = try await withCheckedThrowingContinuation { continuation in
            OIDAuthorizationService.perform(exchange, originalAuthorizationResponse: response.value) { @Sendable value, error in
                guard let value else { continuation.resume(throwing: Self.authorizationFailure(error)); return }
                continuation.resume(returning: MicrosoftTokenResponse(value: value))
            }
        }
        let value = OIDAuthState(authorizationResponse: response.value, tokenResponse: token.value)
        if connectStorage, let existingToken {
            guard let raw = token.value.idToken, let returned = OIDIDToken(idTokenString: raw),
                  returned.issuer == existingToken.issuer, returned.subject == existingToken.subject else {
                throw NotesError.unsupported("A different Microsoft account was selected. Your connected account was preserved. Try again with that account.")
            }
        }
        progress?("Native code exchange completed; saving O2N’s Keychain archive.")
        try Task.checkCancellation()
        try persist(value, allowInteraction: true); state = value; cacheFailure = nil
        _ = try await identityKey()
        progress?("Dedicated native identity and Keychain save verified.")
    }
    public func cancel() { flow?.cancel(); flow = nil }
    public func signOut() throws {
        cancel(); try store.remove(); state = nil; cacheFailure = nil
    }
    @discardableResult public func resume(_ url: URL) -> Bool {
        let scheme = url.scheme?.caseInsensitiveCompare(redirect.scheme ?? "") == .orderedSame
        let host = url.host == redirect.host
        let path = url.path == redirect.path
        progress?("Native return received; scheme/host/path match: \(scheme)/\(host)/\(path); active flow: \(flow != nil).")
        guard scheme, host, path, let flow else { return false }
        do { try flow.resumeExternalUserAgentFlow(url); return true }
        catch {
            let value = error as NSError
            progress?("AppAuth rejected native return (\(value.domain):\(value.code)).")
            return false
        }
    }
    static func authorizationRequest(configuration: OIDServiceConfiguration, clientID: String, redirect: URL, connectStorage: Bool = false) -> OIDAuthorizationRequest {
        OIDAuthorizationRequest(configuration: configuration, clientId: clientID, clientSecret: nil,
                                scopes: Self.scopes + (connectStorage ? Self.storageScopes : []), redirectURL: redirect, responseType: OIDResponseTypeCode,
                                additionalParameters: ["prompt": "select_account"])
    }
    nonisolated static func authorizationFailure(_ error: Error?) -> NotesError {
        let value = error as NSError?
        let response = value?.userInfo[OIDOAuthErrorResponseErrorKey] as? [String: Any]
        let identifier = (response?["error"] as? String).flatMap { source in
            source.allSatisfy { $0.isASCII && ($0.isLetter || $0 == "_") } ? source : nil
        }
        let codes = response?["error_codes"] as? [Int] ?? []
        let details = [identifier, codes.isEmpty ? nil : "AADSTS " + codes.map(String.init).joined(separator: ",")].compactMap { $0 }.joined(separator: "; ")
        return .unsupported("Native Microsoft authorization failed (\(value?.domain ?? "unknown"):\(value?.code ?? -1)\(details.isEmpty ? "" : "; " + details)). Existing consent and credentials were retained.")
    }
}
