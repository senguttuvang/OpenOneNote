import Security
import Testing
@testable import OneNoteGraph

@Test func silentLegacyKeychainInteractionIsRestoredEvenOnFailure() throws {
    enum SyntheticFailure: Error { case expected }
    var original = DarwinBoolean(false)
    #expect(SecKeychainGetUserInteractionAllowed(&original) == errSecSuccess)
    #expect(throws: SyntheticFailure.self) {
        try MicrosoftKeychainStore.withInteraction(false) {
            var current = DarwinBoolean(true)
            #expect(SecKeychainGetUserInteractionAllowed(&current) == errSecSuccess)
            #expect(!current.boolValue)
            throw SyntheticFailure.expected
        }
    }
    var restored = DarwinBoolean(false)
    #expect(SecKeychainGetUserInteractionAllowed(&restored) == errSecSuccess)
    #expect(restored.boolValue == original.boolValue)
}
