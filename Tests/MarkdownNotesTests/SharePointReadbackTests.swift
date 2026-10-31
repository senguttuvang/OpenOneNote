import Foundation
import Testing
import MarkdownNotes
import OneNoteGraph

@Test func formattedOneNoteTableWhitespaceDoesNotBecomeCells() throws {
    let html = """
    <body><div id="outer"><table id="table">
      <tr id="header">
        <td>Column 1</td>
        <td>Column 2</td>
      </tr>
      <tr id="row">
        <td>O2N native</td>
        <td>Cell</td>
      </tr>
    </table></div></body>
    """
    let codec = MarkdownConversion()
    let decoded = try HTMLConversion().decode(html)
    let expected = "| Column 1 | Column 2 |\n| --- | --- |\n| O2N native | Cell |\n"
    #expect(codec.markdown(decoded.document) == expected)
    #expect(try codec.parse(codec.markdown(decoded.document)).blocks == codec.parse(expected).blocks)
}

private struct ResourceAuthorization: GraphAuthorization {
    func accessToken() async throws -> String { "synthetic-not-a-credential" }
    func identityKey() async throws -> String { "synthetic" }
}
private actor ResourceTransport: GraphTransport {
    var urls: [URL] = []
    func send(_ request: URLRequest) throws -> GraphResponse {
        urls.append(try #require(request.url))
        return GraphResponse(data: Data([1, 2, 3]), status: 200)
    }
}
@Test func returnedSharePointResourceRouteUsesPublicGraphSiteEndpoint() async throws {
    let transport = ResourceTransport()
    let client = GraphClient(authorization: ResourceAuthorization(), transport: transport)
    let returned = URL(string: "https://graph.microsoft.com/v1.0/siteCollections/example.sharepoint.com,site,web/onenote/resources/1-image!1-section/$value")!
    #expect(try await client.resource(returned) == Data([1, 2, 3]))
    let sent = await transport.urls
    #expect(sent.count == 1)
    #expect(sent[0].absoluteString == returned.absoluteString.replacingOccurrences(of: "/siteCollections/", with: "/sites/"))
    await #expect(throws: NotesError.self) {
        try await client.resource(URL(string: "https://evil.example/v1.0/siteCollections/site/onenote/resources/image/$value")!)
    }
    #expect(await transport.urls.count == 1)
}
