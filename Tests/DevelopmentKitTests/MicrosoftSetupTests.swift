import Foundation
import Testing
import DevelopmentKit

private final class RegistrationRunner: ProcessRunning {
    var calls: [[String]] = []
    var patch: [String: Any]?
    var changeBeforePatch = false
    let callback = "msauth.dev.senguttuvang.OpenOneNote://auth"
    func run(_ tool: String, _ arguments: [String], at directory: URL, capture: Bool, timeout: TimeInterval, allowFailure: Bool, environment: [String: String]) throws -> ProcessResult {
        calls.append(arguments)
        let result: [String: Any]
        if arguments.first == "status" {
            result = ["appId": "11111111-1111-1111-1111-111111111111", "appTenant": "synthetic-tenant", "authType": "browser"]
        } else if arguments.contains("patch") {
            let index = try #require(arguments.firstIndex(of: "--body"))
            let url = URL(fileURLWithPath: String(arguments[index + 1].dropFirst()))
            patch = try JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
            return ProcessResult(exitCode: 0, stdout: "")
        } else if calls.count == 2 {
            result = ["value": [["id": "22222222-2222-2222-2222-222222222222", "publicClient": ["redirectUris": ["http://localhost"]]]]]
        } else { result = ["publicClient": ["redirectUris": patch != nil ? ["http://localhost", callback] : changeBeforePatch ? ["http://localhost", "msauth.another-approved-app://auth"] : ["http://localhost"]]] }
        return ProcessResult(exitCode: 0, stdout: String(decoding: try JSONSerialization.data(withJSONObject: result), as: UTF8.self))
    }
}

@Test @MainActor func callbackSetupPreservesRedirectsScopesAndRollback() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let runner = RegistrationRunner()
    let workflow = DevelopmentWorkflow(root: root, runner: runner)
    try workflow.microsoftSetup(cli: "/usr/bin/true", vault: root.appendingPathComponent("vault"), backupRoot: root.appendingPathComponent("backups"))
    #expect(runner.calls.count == 5)
    let patch = try #require(runner.patch)
    #expect(Set(patch.keys) == ["publicClient"])
    let client = try #require(patch["publicClient"] as? [String: Any])
    #expect(client["redirectUris"] as? [String] == ["http://localhost", runner.callback])
    let backup = try #require(FileManager.default.contentsOfDirectory(at: root.appendingPathComponent("backups"), includingPropertiesForKeys: nil).first)
    let restore = try JSONSerialization.jsonObject(with: Data(contentsOf: backup.appendingPathComponent("restore-public-client.json"))) as? [String: Any]
    #expect((restore?["publicClient"] as? [String: Any])?["redirectUris"] as? [String] == ["http://localhost"])
    #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("vault/.o2n/config/microsoft-client.json").path))
}

@Test @MainActor func callbackSetupRejectsConcurrentRegistrationChanges() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let runner = RegistrationRunner(); runner.changeBeforePatch = true
    let workflow = DevelopmentWorkflow(root: root, runner: runner)
    #expect(throws: DevelopmentError.self) {
        try workflow.microsoftSetup(cli: "/usr/bin/true", vault: root.appendingPathComponent("vault"), backupRoot: root.appendingPathComponent("backups"))
    }
    #expect(runner.patch == nil)
}
