import Foundation
import Testing
import MarkdownNotes
import MarkdownEditor
import OneNoteGraph

private struct CreationAuthorization: GraphAuthorization {
    func accessToken() async throws -> String { "synthetic" }
    func identityKey() async throws -> String { "synthetic" }
}
private actor CreationTransport: GraphTransport {
    private var responses: [GraphResponse]
    private(set) var requests: [URLRequest] = []
    init(_ responses: [GraphResponse]) { self.responses = responses }
    func send(_ request: URLRequest) throws -> GraphResponse {
        requests.append(request)
        guard !responses.isEmpty else { throw NotesError.invalid("Unexpected creation request") }
        return responses.removeFirst()
    }
}

@Test @MainActor func addCloudPageStaysInSelectedNotebookAndSection() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    let transport = CreationTransport([
        GraphResponse(data: Data(#"{"id":"new-cloud-page","title":"Untitled Page"}"#.utf8), status: 201),
        GraphResponse(data: Data(#"{"id":"new-cloud-page","title":"Untitled Page"}"#.utf8), status: 200),
        GraphResponse(data: Data("<body><p id='empty'></p></body>".utf8), status: 200)
    ])
    session.graph = GraphClient(authorization: CreationAuthorization(), transport: transport)
    session.root = "sites/synthetic"; session.remoteNotebookName = "Selected cloud notebook"
    session.notebooks = [GraphItem(id: "book", displayName: "Selected cloud notebook")]; session.notebookID = "book"
    session.sections = [GraphItem(id: "first", displayName: "First"), GraphItem(id: "chosen", displayName: "Chosen section")]
    session.sectionID = "chosen"
    let shell = NativeShellState(session: session)
    shell.createPage()
    for _ in 0..<3000 { if !session.busy { break }; try await Task.sleep(for: .milliseconds(1)) }
    #expect(!session.busy)
    shell.followSelection()
    #expect(shell.notebook == "Selected cloud notebook")
    #expect(shell.section == "Chosen section")
    #expect(session.selected?.identity.root == "sites/synthetic")
    #expect(session.selected?.identity.pageID == "new-cloud-page")
    #expect(session.selected?.identity.accountKey == "synthetic")
    #expect(session.selected?.hierarchy == ["Selected cloud notebook", "Chosen section"])
    #expect(session.notes.count == 1)
    #expect(!session.notes.contains { $0.identity.root == "local" })
    let requests = await transport.requests
    #expect(requests.filter { $0.httpMethod == "POST" }.count == 1)
    #expect(requests.first?.url?.path.hasSuffix("/sections/chosen/pages") == true)
}

@Test @MainActor func cloudCreationWithoutConnectedSectionDoesNotSwitchToLocalNotebook() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    session.remoteNotebookName = "Selected cloud notebook"
    let shell = NativeShellState(session: session); shell.createPage()
    #expect(shell.notebook == "Selected cloud notebook")
    #expect(session.notes.isEmpty)
    #expect(session.message.contains("choose a section"))
}

@Test @MainActor func localAddPageWithoutSelectedPageKeepsCurrentNotebookAndSection() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = try MarkdownSession(vault: MarkdownVault(root: directory))
    let shell = NativeShellState(session: session); shell.notebook = "Chosen local notebook"; shell.section = "Chosen section"
    shell.createPage()
    #expect(session.selected?.hierarchy == ["Chosen local notebook", "Chosen section"])
    #expect(shell.notebook == "Chosen local notebook")
}

@Test @MainActor func cloudPagePostFailurePreservesSelectionAndDoesNotRetryOrCreateLocalPage() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    var original = try vault.createLocal()
    original.identity = PageIdentity(root: "sites/synthetic", pageID: "original", accountKey: "synthetic")
    original.hierarchy = ["Cloud", "Section"]; try vault.saveLedger(original)
    let session = try MarkdownSession(vault: vault); session.select(original.id)
    let transport = CreationTransport([GraphResponse(data: Data(), status: 503)])
    session.graph = GraphClient(authorization: CreationAuthorization(), transport: transport)
    session.root = "sites/synthetic"; session.remoteNotebookName = "Cloud"
    session.notebooks = [GraphItem(id: "book", displayName: "Cloud")]; session.notebookID = "book"
    session.sections = [GraphItem(id: "section", displayName: "Section")]; session.sectionID = "section"
    let shell = NativeShellState(session: session); shell.createPage()
    for _ in 0..<3000 { if !session.busy { break }; try await Task.sleep(for: .milliseconds(1)) }
    #expect(session.selectedID == original.id)
    #expect(shell.notebook == "Cloud")
    #expect(session.notes.count == 1)
    #expect(try vault.markdown(original) == original.baselineMarkdown)
    #expect(await transport.requests.count == 1)
}
