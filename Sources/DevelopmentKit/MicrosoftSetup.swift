import Foundation

extension DevelopmentWorkflow {
    /// Provision only O2N's separate public client, using the existing same-tenant Azure CLI context.
    /// No shared registration changes, secrets, application roles or tenant-wide consent.
    public func microsoftRegister(azure: String, vault: URL, tenant: String, siteID: String) throws {
        guard azure.hasPrefix("/"), FileManager.default.isExecutableFile(atPath: azure),
              UUID(uuidString: tenant) != nil, !siteID.isEmpty, !siteID.contains("/"), !siteID.contains("?"), !siteID.contains("#") else {
            throw DevelopmentError.invalidArguments("Supply Azure CLI, intended tenant UUID and exact verified SharePoint site ID")
        }
        func json(_ arguments: [String]) throws -> Any {
            let output = try run(azure, arguments + ["--output", "json"], capture: true).stdout
            guard let bytes = output.data(using: .utf8) else { throw DevelopmentError.invalidArguments("Invalid Azure metadata encoding") }
            return try JSONSerialization.jsonObject(with: bytes)
        }
        let context = try json(["account", "show"]) as? [String: Any]
        guard (context?["tenantId"] as? String)?.lowercased() == tenant.lowercased(), context?["state"] as? String == "Enabled" else {
            throw DevelopmentError.invalidArguments("Azure CLI is not signed into the intended enabled tenant")
        }
        let encoded = siteID.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let site = try json(["rest", "--method", "get", "--url", "https://graph.microsoft.com/v1.0/sites/\(encoded)?$select=id,webUrl"]) as? [String: Any]
        guard site?["id"] as? String == siteID, let web = site?["webUrl"] as? String,
              let host = URL(string: web)?.host, host.hasSuffix(".sharepoint.com") else {
            throw DevelopmentError.invalidArguments("SharePoint target identity did not match; no registration changed")
        }
        let name = "OpenOneNote"
        let callback = "msauth.dev.senguttuvang.OpenOneNote://auth"
        let resource = "00000003-0000-0000-c000-000000000000"
        let permission = "615e26af-c38a-4150-ae3e-c3b0d4cb1d6a" // delegated Notes.ReadWrite
        let matches = try json(["ad", "app", "list", "--display-name", name]) as? [[String: Any]] ?? []
        let exact = matches.filter { $0["displayName"] as? String == name }
        guard exact.count <= 1 else { throw DevelopmentError.invalidArguments("Multiple O2N registrations exist; resolve their identities before provisioning") }
        let directory = vault.appendingPathComponent(".o2n/config")
        guard directory.resolvingSymlinksInPath().path.hasPrefix(vault.resolvingSymlinksInPath().path + "/") else { throw DevelopmentError.invalidArguments("Configuration escapes vault") }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let manifest = [["resourceAppId": resource, "resourceAccess": [["id": permission, "type": "Scope"]]]] as [[String: Any]]
        let permissions = directory.appendingPathComponent("delegated-permissions.json")
        try JSONSerialization.data(withJSONObject: manifest, options: [.prettyPrinted, .sortedKeys]).write(to: permissions, options: .atomic)
        let app: [String: Any]
        if let existing = exact.first { app = existing }
        else {
            guard let created = try json(["ad", "app", "create", "--display-name", name, "--sign-in-audience", "AzureADMyOrg",
                                          "--is-fallback-public-client", "true", "--public-client-redirect-uris", callback,
                                          "--required-resource-access", "@" + permissions.path]) as? [String: Any] else {
                throw DevelopmentError.invalidArguments("Azure did not return the created registration; rediscover before retrying")
            }
            app = created
            // Record immediately so an interrupted provisioning run can rediscover safely.
            try JSONSerialization.data(withJSONObject: ["appId": app["appId"] ?? "", "id": app["id"] ?? ""], options: [.sortedKeys]).write(to: directory.appendingPathComponent("registration-identity.json"), options: .atomic)
        }
        guard let clientID = app["appId"] as? String, UUID(uuidString: clientID) != nil else { throw DevelopmentError.invalidArguments("O2N registration has no valid client ID") }
        let readback = try json(["ad", "app", "show", "--id", clientID]) as? [String: Any] ?? [:]
        let access = readback["requiredResourceAccess"] as? [[String: Any]] ?? []
        let scopes = access.first?["resourceAccess"] as? [[String: Any]] ?? []
        guard readback["displayName"] as? String == name, readback["signInAudience"] as? String == "AzureADMyOrg",
              readback["isFallbackPublicClient"] as? Bool == true,
              (readback["publicClient"] as? [String: Any])?["redirectUris"] as? [String] == [callback],
              access.count == 1, access.first?["resourceAppId"] as? String == resource,
              scopes.count == 1, scopes.first?["id"] as? String == permission, scopes.first?["type"] as? String == "Scope",
              (readback["passwordCredentials"] as? [Any] ?? []).isEmpty,
              (readback["keyCredentials"] as? [Any] ?? []).isEmpty else {
            throw DevelopmentError.invalidArguments("Existing/readback O2N registration does not match the narrow public-client contract; no overwrite attempted")
        }
        let principals = try json(["ad", "sp", "list", "--filter", "appId eq '\(clientID)'"]) as? [[String: Any]] ?? []
        guard principals.count <= 1 else { throw DevelopmentError.invalidArguments("Ambiguous O2N service principal") }
        let principal = try principals.first ?? (json(["ad", "sp", "create", "--id", clientID]) as? [String: Any] ?? [:])
        guard principal["appId"] as? String == clientID, principal["servicePrincipalType"] as? String == "Application" else {
            throw DevelopmentError.invalidArguments("O2N service principal metadata did not match")
        }
        let config = ["clientID": clientID, "tenant": tenant.lowercased(), "redirectURI": callback, "graphRoot": "sites/" + siteID]
        try JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys]).write(to: directory.appendingPathComponent("microsoft-client.json"), options: .atomic)
        let evidence: [String: Any] = ["clientID": clientID, "tenant": tenant, "siteID": siteID, "siteURL": web,
                                      "registrationID": readback["id"] ?? "", "servicePrincipalID": principal["id"] ?? "",
                                      "delegatedScopes": ["Notes.ReadWrite"], "callback": callback,
                                      "consent": "User consent pending; no admin consent granted", "verifiedAt": ISO8601DateFormatter().string(from: Date())]
        try JSONSerialization.data(withJSONObject: evidence, options: [.prettyPrinted, .sortedKeys]).write(to: directory.appendingPathComponent("registration-verification.json"), options: .atomic)
        print("Dedicated O2N single-tenant public client and service principal verified. Notes.ReadWrite only; no secret or tenant-wide consent. Public metadata saved locally. User Sign in is next.")
    }
}
