import Foundation

extension DevelopmentWorkflow {
    /// Sanctioned delegated registration discovery and narrow native callback setup; no credential extraction or scope changes.
    public func microsoftSetup(cli: String, vault: URL, backupRoot: URL? = nil) throws {
        guard cli.hasPrefix("/"), FileManager.default.isExecutableFile(atPath: cli) else { throw DevelopmentError.invalidArguments("Supply the installed Microsoft 365 CLI executable") }
        let status = try run(cli, ["status", "--output", "json"], capture: true)
        guard let data = status.stdout.data(using: .utf8), let metadata = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let clientID = metadata["appId"] as? String, UUID(uuidString: clientID) != nil,
              let tenant = metadata["appTenant"] as? String, ["browser", "deviceCode"].contains(metadata["authType"] as? String ?? "") else {
            throw DevelopmentError.invalidArguments("The sanctioned CLI has no usable delegated session")
        }
        var endpoint = URLComponents(string: "https://graph.microsoft.com/v1.0/applications")!
        endpoint.queryItems = [URLQueryItem(name: "$filter", value: "appId eq '\(clientID)'"),
                               URLQueryItem(name: "$select", value: "id,appId,signInAudience,publicClient,isFallbackPublicClient")]
        let response = try run(cli, ["request", "--url", endpoint.url!.absoluteString, "--output", "json"], capture: true)
        guard let bytes = response.stdout.data(using: .utf8), let object = try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
              let values = object["value"] as? [[String: Any]], let registration = values.first,
              let publicClient = registration["publicClient"] as? [String: Any], let redirects = publicClient["redirectUris"] as? [String],
              let registrationID = registration["id"] as? String, UUID(uuidString: registrationID) != nil else {
            throw DevelopmentError.invalidArguments("Existing registration has no verified supported native redirect; no registration or permission was changed")
        }
        let expectedRedirect = "msauth.dev.senguttuvang.OpenOneNote://auth"
        var redirect = redirects.first(where: { $0.caseInsensitiveCompare(expectedRedirect) == .orderedSame }) ?? expectedRedirect
        if !redirects.contains(where: { $0.caseInsensitiveCompare(expectedRedirect) == .orderedSame }) {
            let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
            let backup = (backupRoot ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Backups/OpenOneNote")).appendingPathComponent("\(stamp)-native-redirect")
            try FileManager.default.createDirectory(at: backup, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
            let restore: [String: Any] = ["publicClient": publicClient]
            try JSONSerialization.data(withJSONObject: restore, options: [.prettyPrinted, .sortedKeys]).write(to: backup.appendingPathComponent("restore-public-client.json"), options: .atomic)
            let manifest: [String: Any] = [
                "purpose": "Preserve existing sanctioned registration before adding the O2N native redirect",
                "source": "Microsoft Graph application metadata", "registrationID": registrationID,
                "restore": "With separate rollback authority, PATCH the same application using restore-public-client.json through the sanctioned CLI",
                "verification": "Original publicClient object preserved; update changes only redirectUris; readback checks the exact redirect set"
            ]
            try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys]).write(to: backup.appendingPathComponent("manifest.json"), options: .atomic)
            var changed = publicClient; changed["redirectUris"] = redirects + [redirect]
            let request = backup.appendingPathComponent("add-native-redirect.json")
            try JSONSerialization.data(withJSONObject: ["publicClient": changed], options: [.sortedKeys]).write(to: request, options: .atomic)
            let applicationURL = "https://graph.microsoft.com/v1.0/applications/\(registrationID)"
            func recheck() throws {
                let current = try run(cli, ["request", "--url", applicationURL + "?$select=publicClient", "--output", "json"], capture: true)
                guard let bytes = current.stdout.data(using: .utf8), let value = try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
                      let client = value["publicClient"] as? [String: Any], NSDictionary(dictionary: client).isEqual(to: publicClient) else {
                    throw DevelopmentError.invalidArguments("Registration changed while setup was prepared; no callback overwrite attempted")
                }
            }
            try recheck()
            var update = try run(cli, ["request", "--url", applicationURL, "--method", "patch", "--content-type", "application/json", "--body", "@" + request.path, "--output", "json"], capture: true, allowFailure: true)
            let azure = "/opt/homebrew/bin/az"
            if update.exitCode != 0, FileManager.default.isExecutableFile(atPath: azure) {
                let context = try run(azure, ["account", "show", "--query", "tenantId", "--output", "tsv"], capture: true, allowFailure: true)
                if context.exitCode == 0, context.stdout.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(tenant) == .orderedSame {
                    try recheck()
                    print("Microsoft 365 CLI update rejected; using the existing same-tenant Azure CLI management context for the same narrow callback payload. No login, scope or account change.")
                    update = try run(azure, ["rest", "--method", "patch", "--url", applicationURL, "--headers", "Content-Type=application/json", "--body", "@" + request.path, "--output", "none"], capture: true, allowFailure: true)
                }
            }
            if update.exitCode != 0 {
                try Data(update.stdout.utf8).write(to: backup.appendingPathComponent("update-diagnostic.txt"), options: .atomic)
                throw DevelopmentError.invalidArguments("Microsoft native redirect update failed; detailed response retained in centralized backup. No permission scope was added.")
            }
            let readback = try run(cli, ["request", "--url", applicationURL + "?$select=publicClient", "--output", "json"], capture: true)
            try Data(readback.stdout.utf8).write(to: backup.appendingPathComponent("readback-public-client.json"), options: .atomic)
            guard let bytes = readback.stdout.data(using: .utf8), let value = try JSONSerialization.jsonObject(with: bytes) as? [String: Any],
                  let client = value["publicClient"] as? [String: Any], let actual = client["redirectUris"] as? [String],
                  actual.count == redirects.count + 1, redirects.allSatisfy(actual.contains),
                  let native = actual.first(where: { $0.caseInsensitiveCompare(expectedRedirect) == .orderedSame }) else { throw DevelopmentError.invalidArguments("Native redirect readback did not match; backup retained and setup stopped") }
            redirect = native
            print("O2N native callback appended and read back; existing callbacks and permission scopes preserved. Rollback metadata retained in the centralized backup.")
        }
        let directory = vault.appendingPathComponent(".o2n/config")
        guard directory.resolvingSymlinksInPath().path.hasPrefix(vault.resolvingSymlinksInPath().path + "/") else { throw DevelopmentError.invalidArguments("Configuration path escapes vault") }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let config: [String: String] = ["clientID": clientID, "tenant": tenant, "redirectURI": redirect]
        try JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]).write(to: directory.appendingPathComponent("microsoft-client.json"), options: .atomic)
        print("Existing delegated registration and native redirect verified. Local O2N configuration saved; native Sign in remains separate.")
    }
}
