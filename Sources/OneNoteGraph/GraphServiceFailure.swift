import Foundation

/// Only the provider's bounded machine identifier may leave the transport error body.
/// Messages, inner errors, URLs, headers and account/site information remain private.
public struct GraphServiceFailure: Error, LocalizedError, Equatable, Sendable {
    public let status: Int
    public let code: String
    public init?(status: Int, body: Data) {
        struct Envelope: Decodable {
            struct Failure: Decodable { let code: String }
            let error: Failure
        }
        guard let value = try? JSONDecoder().decode(Envelope.self, from: body).error.code,
              !value.isEmpty, value.utf8.count <= 80,
              value.allSatisfy({ $0.isASCII && ($0.isLetter || $0.isNumber || "_.-".contains($0)) }) else { return nil }
        self.status = status; code = value
    }
    public var errorDescription: String? {
        "Microsoft Graph returned HTTP \(status) (\(code)). Local notes are retained."
    }
}
