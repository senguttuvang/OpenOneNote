import Foundation

extension DevelopmentWorkflow {
    public nonisolated static func validateSigningProfile(_ profile: [String: Any], team: String, now: Date = Date()) throws {
        let application = team + ".dev.senguttuvang.OpenOneNote"
        guard let expiration = profile["ExpirationDate"] as? Date, expiration > now,
              let teams = profile["TeamIdentifier"] as? [String], teams.contains(team),
              let entitlements = profile["Entitlements"] as? [String: Any],
              let applicationID = entitlements["com.apple.application-identifier"] as? String ?? entitlements["application-identifier"] as? String,
              applicationID == application || applicationID == team + ".*",
              let groups = entitlements["keychain-access-groups"] as? [String], groups.contains(application) || groups.contains(team + ".*") else {
            throw DevelopmentError.invalidArguments("Provisioning profile is expired or does not authorize this O2N app/team/private Keychain group")
        }
    }
}
