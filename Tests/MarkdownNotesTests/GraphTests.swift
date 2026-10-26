import Foundation
import Testing
import MarkdownNotes
import MarkdownEditor
@testable import OneNoteGraph

private struct SyntheticAuthorization: GraphAuthorization {
    func accessToken() async throws -> String { "synthetic-not-a-credential" }
    func identityKey() async throws -> String { "synthetic-account" }
}
private actor ScriptedTransport: GraphTransport {
    var responses: [GraphResponse]
    var requests: [URLRequest] = []
    init(_ responses: [GraphResponse]) { self.responses = responses }
    func send(_ request: URLRequest) throws -> GraphResponse {
        requests.append(request)
        guard !responses.isEmpty else { throw NotesError.invalid("Unexpected test request") }
        return responses.removeFirst()
    }
}
@Test func graphBoundaryRejectsRedirectAndTokenBearingURLs() throws {
    for source in ["http://graph.microsoft.com/v1.0/me/onenote", "https://evil.example/v1.0/me", "https://graph.microsoft.com.evil.example/v1.0/me", "https://graph.microsoft.com/v1.0/me?access_token=synthetic", "https://user@graph.microsoft.com/v1.0/me"] {
        #expect(throws: NotesError.self) { try GraphClient.validate(URL(string: source)!) }
    }
    let client = GraphClient(authorization: SyntheticAuthorization())
    #expect(try client.url(root: "sites/synthetic-site", path: "notebooks").absoluteString.contains("sites/synthetic%2Dsite/onenote/notebooks"))
    #expect(throws: NotesError.self) { try client.url(root: "me/../../users", path: "notebooks") }
    #expect(throws: NotesError.self) { try GraphClient.component("../secret") }
}
@Test func graphPaginationAndRetryAfter() async throws {
    let next = "https://graph.microsoft.com/v1.0/me/onenote/notebooks?$skip=1"
    let transport = ScriptedTransport([
        GraphResponse(data: Data(), status: 429, retryAfter: "0"),
        GraphResponse(data: Data("{\"value\":[{\"id\":\"one\",\"displayName\":\"First\"}],\"@odata.nextLink\":\"\(next)\"}".utf8), status: 200),
        GraphResponse(data: Data("{\"value\":[{\"id\":\"two\",\"displayName\":\"Second\"}]}".utf8), status: 200)
    ])
    let client = GraphClient(authorization: SyntheticAuthorization(), transport: transport)
    #expect(try await client.list(root: "me", path: "notebooks").map(\.id) == ["one", "two"])
    #expect(await transport.requests.count == 3)
    #expect(GraphClient.retryDelay("12") == 12)
    #expect(GraphClient.retryDelay("Wed, 21 Oct 2015 07:28:00 GMT", now: Date(timeIntervalSince1970: 0)) != nil)
}
@Test func graphRejectsHostilePaginationAndDoesNotRetryWrites() async throws {
    let transport = ScriptedTransport([GraphResponse(data: Data("{\"value\":[],\"@odata.nextLink\":\"https://evil.example/steal\"}".utf8), status: 200)])
    let client = GraphClient(authorization: SyntheticAuthorization(), transport: transport)
    await #expect(throws: NotesError.self) { try await client.list(root: "me", path: "notebooks") }
    #expect(await transport.requests.count == 1)
    let writes = ScriptedTransport([GraphResponse(data: Data(), status: 503)])
    let writer = GraphClient(authorization: SyntheticAuthorization(), transport: writes)
    await #expect(throws: NotesError.http(503)) {
        try await writer.update(PageIdentity(pageID: "synthetic", accountKey: "synthetic-account"), commands: [PageCommand(target: "p1", action: "replace", content: "<p>Updated</p>")], parts: [])
    }
    #expect(await writes.requests.count == 1)
}
@Test func multipartContainsExactBinaryBytes() throws {
    let bytes = Data([0, 1, 255, 13, 10])
    let body = try GraphClient.multipart(commands: [PageCommand(target: "img1", action: "replace", content: "<img src=\"name:asset-0\" />")], parts: [BinaryPart(name: "asset-0", mimeType: "image/png", bytes: bytes)], boundary: "synthetic-boundary")
    #expect(body.range(of: bytes) != nil)
    #expect(body.range(of: Data("name=\"Commands\"".utf8)) != nil)
    #expect(body.suffix(24) == Data("--synthetic-boundary--\r\n".utf8).suffix(24))
    #expect(throws: NotesError.self) { try GraphClient.multipart(commands: [], parts: [BinaryPart(name: "bad\r\n", mimeType: "image/png", bytes: bytes)], boundary: "boundary") }
}

@Test func graphRefusesDifferentAccountBeforeNetwork() async throws {
    let transport = ScriptedTransport([])
    let client = GraphClient(authorization: SyntheticAuthorization(), transport: transport)
    await #expect(throws: NotesError.authenticationRequired) {
        try await client.fetch(PageIdentity(pageID: "synthetic", accountKey: "other-account"))
    }
    #expect(await transport.requests.isEmpty)
}

@Test @MainActor func cancelledGraphOperationDoesNotSendNetworkRequest() async throws {
    let transport = ScriptedTransport([GraphResponse(data: Data("{\"value\":[]}".utf8), status: 200)])
    let client = GraphClient(authorization: SyntheticAuthorization(), transport: transport)
    let task = Task { try await client.list(root: "me", path: "notebooks") }
    task.cancel()
    await #expect(throws: CancellationError.self) { try await task.value }
    #expect(await transport.requests.isEmpty)
}

@Test @MainActor func refreshedRemoteSourceBecomesTheNextNativeEditSnapshot() async throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let ledger = NoteLedger(identity: PageIdentity(pageID: "synthetic-page", accountKey: "synthetic-account"), title: "Synthetic", baseline: try MarkdownConversion().parse("Original\n"), markdown: "Original\n", htmlHash: "old", assets: [])
    try vault.create(ledger)
    let transport = ScriptedTransport([
        GraphResponse(data: Data("{\"id\":\"synthetic-page\",\"title\":\"Synthetic\"}".utf8), status: 200),
        GraphResponse(data: Data("<body><div id='outer'><p id='p'>Remote refresh</p></div></body>".utf8), status: 200)
    ])
    let session = try MarkdownSession(vault: vault); session.select(ledger.id)
    session.graph = GraphClient(authorization: SyntheticAuthorization(), transport: transport)
    session.sync()
    let deadline = Date().addingTimeInterval(3)
    while session.busy && Date() < deadline { try await Task.sleep(for: .milliseconds(10)) }
    #expect(!session.busy)
    #expect(session.source == "Remote refresh\n")
    session.edit("Next local edit\n")
    #expect(session.selected?.externalRecoveryMarkdown == nil)
    #expect(try vault.markdown(ledger) == "Next local edit\n")
}
