import Foundation

public struct MicrosoftConfiguration: Codable, Sendable {
    public let clientID: String
    public let tenant: String
    public let redirectURI: String
    public init(clientID: String, tenant: String, redirectURI: String) {
        self.clientID = clientID; self.tenant = tenant; self.redirectURI = redirectURI
    }
}
