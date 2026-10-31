import Foundation
import Testing
import OneNoteGraph

@Test func graphServiceFailureRetainsOnlySafeMachineCodes() throws {
    let body = Data(#"{"error":{"code":"accessDenied","message":"private account, URL and credential text","innerError":{"code":"private-value"}}}"#.utf8)
    let failure = try #require(GraphServiceFailure(status: 403, body: body))
    #expect(failure.code == "accessDenied")
    #expect(failure.status == 403)
    #expect(!failure.localizedDescription.contains("private"))
    for code in ["https://private.invalid/token", "private value", String(repeating: "x", count: 81), ""] {
        let invalid = try JSONSerialization.data(withJSONObject: ["error": ["code": code]])
        #expect(GraphServiceFailure(status: 403, body: invalid) == nil)
    }
    #expect(GraphServiceFailure(status: 403, body: Data("not-json".utf8)) == nil)
}
