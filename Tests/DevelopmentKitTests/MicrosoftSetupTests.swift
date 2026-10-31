import Foundation
import Testing
import DevelopmentKit

private final class RegistrationRunner: ProcessRunning {
    var calls: [[String]] = []
    var existing = false
    var badTenant = false
    var broadPermission = false
    var callbacks = ["msauth.dev.senguttuvang.OpenOneNote://auth/callback"]
    let tenant = "11111111-1111-1111-1111-111111111111"
    let client = "22222222-2222-2222-2222-222222222222"
    let site = "synthetic.sharepoint.com,site,web"
    var registration: [String: Any] {
        ["id": "registration", "appId": client, "displayName": "OpenOneNote", "signInAudience": "AzureADMyOrg",
         "isFallbackPublicClient": true, "publicClient": ["redirectUris": callbacks],
         "passwordCredentials": [], "keyCredentials": [],
         "requiredResourceAccess": [["resourceAppId": "00000003-0000-0000-c000-000000000000", "resourceAccess": [["id": broadPermission ? "unapproved" : "615e26af-c38a-4150-ae3e-c3b0d4cb1d6a", "type": "Scope"]]]]]
    }
    func run(_ tool: String, _ arguments: [String], at directory: URL, capture: Bool, timeout: TimeInterval, allowFailure: Bool, environment: [String: String]) throws -> ProcessResult {
        calls.append(arguments)
        let result: Any
        switch Array(arguments.prefix(3)) {
        case ["account", "show", "--output"]: result = ["tenantId": badTenant ? "wrong" : tenant, "state": "Enabled"]
        case ["rest", "--method", "get"]: result = ["id": site, "webUrl": "https://synthetic.sharepoint.com"]
        case ["ad", "app", "list"]: result = existing ? [registration] : []
        case ["ad", "app", "create"]:
            let path = try #require(arguments.firstIndex(of: "--required-resource-access"))
            let bytes = try Data(contentsOf: URL(fileURLWithPath: String(arguments[path + 1].dropFirst())))
            let body = try #require(JSONSerialization.jsonObject(with: bytes) as? [[String: Any]])
            #expect(body.count == 1)
            #expect(arguments.contains("AzureADMyOrg"))
            result = registration
        case ["ad", "app", "show"]: result = registration
        case ["ad", "sp", "list"]: result = existing ? [["appId": client, "id": "principal", "servicePrincipalType": "Application"]] : []
        case ["ad", "sp", "create"]: result = ["appId": client, "id": "principal", "servicePrincipalType": "Application"]
        default: throw DevelopmentError.invalidArguments("Unexpected registration command")
        }
        return ProcessResult(exitCode: 0, stdout: String(decoding: try JSONSerialization.data(withJSONObject: result), as: UTF8.self))
    }
}

@Test @MainActor func dedicatedRegistrationCreatesOnlyNarrowPublicClientAndNoAdminConsent() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let runner = RegistrationRunner()
    try DevelopmentWorkflow(root: root, runner: runner).microsoftRegister(azure: "/usr/bin/true", vault: root, tenant: runner.tenant, siteID: runner.site)
    #expect(runner.calls.filter { $0.prefix(3) == ["ad", "app", "create"] }.count == 1)
    #expect(!runner.calls.contains { $0.contains("admin-consent") || $0.contains("update") || $0.contains("credential") })
    let config = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent(".o2n/config/microsoft-client.json"))) as? [String: String]
    #expect(config?["clientID"] == runner.client)
    #expect(config?["graphRoot"] == "sites/" + runner.site)
    #expect(config?["redirectURI"] == "msauth.dev.senguttuvang.OpenOneNote://auth/callback")
}

@Test @MainActor func dedicatedRegistrationPrefersExplicitPathAndRejectsUnregisteredReturnTargets() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let runner = RegistrationRunner(); runner.existing = true
    runner.callbacks.append("msauth.dev.senguttuvang.OpenOneNote://auth")
    try DevelopmentWorkflow(root: root, runner: runner).microsoftRegister(azure: "/usr/bin/true", vault: root, tenant: runner.tenant, siteID: runner.site)
    let config = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent(".o2n/config/microsoft-client.json"))) as? [String: String]
    #expect(config?["redirectURI"] == runner.callbacks.first)
    #expect(!runner.calls.contains { $0.contains("create") || $0.contains("update") })
    runner.callbacks.append("https://unregistered.invalid/return")
    #expect(throws: DevelopmentError.self) {
        try DevelopmentWorkflow(root: root, runner: runner).microsoftRegister(azure: "/usr/bin/true", vault: root, tenant: runner.tenant, siteID: runner.site)
    }
    #expect(!runner.calls.contains { $0.contains("update") })
}

@Test @MainActor func dedicatedRegistrationRetryReusesExactIdentityWithoutMutation() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let runner = RegistrationRunner(); runner.existing = true
    try DevelopmentWorkflow(root: root, runner: runner).microsoftRegister(azure: "/usr/bin/true", vault: root, tenant: runner.tenant, siteID: runner.site)
    #expect(!runner.calls.contains { $0.contains("create") || $0.contains("update") })
}

@Test @MainActor func dedicatedRegistrationRejectsWrongTenantAndUnexpectedExistingScopes() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    for wrongTenant in [true, false] {
        let runner = RegistrationRunner(); runner.badTenant = wrongTenant; runner.broadPermission = !wrongTenant; runner.existing = true
        #expect(throws: DevelopmentError.self) {
            try DevelopmentWorkflow(root: root, runner: runner).microsoftRegister(azure: "/usr/bin/true", vault: root, tenant: runner.tenant, siteID: runner.site)
        }
        #expect(!runner.calls.contains { $0.contains("create") || $0.contains("update") })
    }
}
