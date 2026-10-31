import Foundation
import Testing
@preconcurrency import AppAuth
import MarkdownNotes
@testable import OneNoteGraph

private final class MemoryCredentials: MicrosoftCredentialStore, @unchecked Sendable {
    private let lock = NSLock()
    private var bytes: Data?
    private var interactions: [Bool] = []
    init(_ bytes: Data? = nil) { self.bytes = bytes }
    func load(allowInteraction: Bool) -> Data? { lock.withLock { interactions.append(allowInteraction); return bytes } }
    func save(_ data: Data, allowInteraction: Bool) { lock.withLock { interactions.append(allowInteraction); bytes = data } }
    var data: Data? { lock.withLock { bytes } }
    var allowedInteraction: Bool { lock.withLock { interactions.contains(true) } }
}

@Test @MainActor func microsoftPublicClientRequestHasPKCEStateNonceAndOfflineAccessWithoutSecret() throws {
    let configuration = OIDServiceConfiguration(authorizationEndpoint: URL(string: "https://login.microsoftonline.com/synthetic/oauth2/v2.0/authorize")!,
                                                tokenEndpoint: URL(string: "https://login.microsoftonline.com/synthetic/oauth2/v2.0/token")!)
    let request = MicrosoftSignIn.authorizationRequest(configuration: configuration, clientID: "synthetic-client",
                                                       redirect: URL(string: "msauth.dev.senguttuvang.OpenOneNote://auth")!)
    #expect(request.responseType == "code")
    #expect(request.clientSecret == nil)
    #expect(request.codeChallengeMethod == "S256")
    #expect((request.codeVerifier?.count ?? 0) >= 43)
    #expect(!(request.state ?? "").isEmpty)
    #expect(!(request.nonce ?? "").isEmpty)
    #expect(request.scope?.split(separator: " ").contains("offline_access") == true)
    #expect(!MicrosoftSignIn.scopes.contains(where: { $0.contains("Sites.") || $0.contains("ReadWrite.All") }))
}

@Test @MainActor func missingNativeCredentialNeverPromptsOrCreatesAFileCache() async throws {
    let store = MemoryCredentials()
    let auth = try MicrosoftSignIn(clientID: "11111111-1111-1111-1111-111111111111", tenant: "22222222-2222-2222-2222-222222222222",
                                   redirectURI: "msauth.dev.senguttuvang.OpenOneNote://auth", store: store)
    await #expect(throws: NotesError.authenticationRequired) { try await auth.accessToken() }
    #expect(store.data == nil)
    #expect(!store.allowedInteraction)
}

@Test @MainActor func malformedNativeArchiveFailsWithoutDiscardingOrReplacingCredentials() async throws {
    let bytes = Data("synthetic malformed secure archive".utf8)
    let store = MemoryCredentials(bytes)
    let auth = try MicrosoftSignIn(clientID: "11111111-1111-1111-1111-111111111111", tenant: "22222222-2222-2222-2222-222222222222",
                                   redirectURI: "msauth.dev.senguttuvang.OpenOneNote://auth", store: store)
    await #expect(throws: (any Error).self) { try await auth.accessToken() }
    #expect(store.data == bytes)
    #expect(!store.allowedInteraction)
}
