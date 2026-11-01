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
    func remove() { lock.withLock { bytes = nil } }
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
    #expect(MicrosoftSignIn.scopes == ["openid", "profile", "offline_access", "https://graph.microsoft.com/Notes.ReadWrite.All"])
}

@Test func personalNotesGrantCannotSilentlySatisfySharedNotebookAccess() {
    #expect(!MicrosoftSignIn.hasRequiredNotesScope("openid profile Notes.ReadWrite"))
    #expect(!MicrosoftSignIn.hasRequiredNotesScope("Sites.ReadWrite.All Files.ReadWrite.All"))
    #expect(!MicrosoftSignIn.hasRequiredNotesScope(nil))
    #expect(MicrosoftSignIn.hasRequiredNotesScope("openid profile Notes.ReadWrite.All"))
    #expect(MicrosoftSignIn.hasRequiredNotesScope("https://graph.microsoft.com/Notes.ReadWrite.All"))
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

@Test @MainActor func storageConsentIsExplicitAndDoesNotExpandDefaultNotesScope() throws {
    let configuration = OIDServiceConfiguration(authorizationEndpoint: URL(string: "https://login.microsoftonline.com/synthetic/authorize")!, tokenEndpoint: URL(string: "https://login.microsoftonline.com/synthetic/token")!)
    let ordinary = MicrosoftSignIn.authorizationRequest(configuration: configuration, clientID: "synthetic", redirect: URL(string: "msauth.dev.senguttuvang.OpenOneNote://auth")!)
    let storage = MicrosoftSignIn.authorizationRequest(configuration: configuration, clientID: "synthetic", redirect: URL(string: "msauth.dev.senguttuvang.OpenOneNote://auth")!, connectStorage: true)
    #expect(ordinary.scope?.contains("Sites.Read.All") == false)
    #expect(ordinary.scope?.contains("Files.Read") == false)
    #expect(storage.scope?.contains("Sites.Read.All") == true)
    #expect(storage.scope?.contains("Files.Read") == true)
    #expect(storage.scope?.contains("Sites.ReadWrite") == false)
    #expect(storage.clientSecret == nil && storage.codeChallengeMethod == "S256")
}

@Test @MainActor func explicitSignOutRemovesOnlyOwnCredentialAndClearsIdentity() async throws {
    let own = MemoryCredentials(Data("synthetic-invalid".utf8))
    let other = MemoryCredentials(Data("other-account".utf8))
    let auth = try MicrosoftSignIn(clientID: "11111111-1111-1111-1111-111111111111", tenant: "22222222-2222-2222-2222-222222222222", redirectURI: "msauth.dev.senguttuvang.OpenOneNote://auth", store: own)
    #expect(own.data != nil)
    try auth.signOut()
    #expect(own.data == nil)
    #expect(other.data == Data("other-account".utf8))
    await #expect(throws: NotesError.authenticationRequired) { try await auth.account() }
    #expect(!own.allowedInteraction)
}
