import Foundation

/// Verified SDK identity projected for presentation, without exposing tokens or raw claims.
public struct MicrosoftAccount: Equatable, Sendable {
    public let key: String
    public let name: String
    public let email: String
    public let storageConnected: Bool
    public init(key: String, name: String, email: String, storageConnected: Bool) {
        self.key = key; self.name = name; self.email = email; self.storageConnected = storageConnected
    }
    public var initials: String { name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased() }
}
