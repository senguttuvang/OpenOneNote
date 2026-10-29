import Foundation

public struct MicrosoftConfiguration: Codable, Sendable {
    public let clientID: String
    public let tenant: String
    public let redirectURI: String
    public let graphRoot: String?
    public init(clientID: String, tenant: String, redirectURI: String, graphRoot: String? = nil) {
        self.clientID = clientID; self.tenant = tenant; self.redirectURI = redirectURI; self.graphRoot = graphRoot
    }
}
