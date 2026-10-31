import AppKit
import Foundation

extension DevelopmentWorkflow {
    /// Install only the verified O2N bundle. Notes, settings and Keychain items are never copied or changed.
    public func installApp(destination: URL? = nil, backupRoot: URL? = nil, runningBundles: [URL]? = nil) throws {
        let files = FileManager.default
        let home = files.homeDirectoryForCurrentUser
        let source = root.appendingPathComponent("dist/OpenOneNote.app")
        let target = destination ?? home.appendingPathComponent("Applications/OpenOneNote.app")
        let identifier = "dev.senguttuvang.OpenOneNote"
        let running = runningBundles ?? NSWorkspace.shared.runningApplications.filter { $0.bundleIdentifier == identifier }.compactMap(\.bundleURL)
        guard running.isEmpty else { throw DevelopmentError.invalidArguments("Save and quit O2N before installing; no running application was terminated") }
        guard target.lastPathComponent == "OpenOneNote.app", Bundle(url: source)?.bundleIdentifier == identifier,
              source.resolvingSymlinksInPath() != target.resolvingSymlinksInPath() else {
            throw DevelopmentError.invalidArguments("Install source/target must be distinct O2N app bundles")
        }
        let existed = files.fileExists(atPath: target.path)
        if existed, try target.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink == true {
            throw DevelopmentError.invalidArguments("Refusing to replace an application symlink")
        }
        guard !existed || Bundle(url: target)?.bundleIdentifier == identifier else { throw DevelopmentError.invalidArguments("Refusing to replace an unrelated application") }
        try run("codesign", ["--verify", "--deep", "--strict", source.path])
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let backup = (backupRoot ?? home.appendingPathComponent("Backups/OpenOneNote")).appendingPathComponent("\(stamp)-app-install-\(UUID().uuidString.prefix(8))")
        try files.createDirectory(at: backup, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        if existed { try files.copyItem(at: target, to: backup.appendingPathComponent("OpenOneNote.app")) }
        let sourceHash = try digest(source.appendingPathComponent("Contents/MacOS/OpenOneNoteMac"))
        var receipt = ["source": source.path, "target": target.path, "purpose": "Preserve the prior O2N application before installing the verified dedicated-OAuth build",
                       "sourceBinarySHA256": sourceHash, "priorBundlePreserved": String(existed), "state": "prepared",
                       "restore": "With separate rollback authority, save/quit O2N and replace only the installed app bundle from this backup. Notes/settings/Keychain are outside this backup and install.",
                       "verification": "Source and installed deep/strict signature plus executable SHA-256; active O2N instances must be absent"]
        func record() throws { try JSONEncoder().encode(receipt).write(to: backup.appendingPathComponent("manifest.json"), options: .atomic) }
        try record()
        try files.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
        let staging = target.deletingLastPathComponent().appendingPathComponent(".OpenOneNote-install-\(UUID()).app")
        try files.copyItem(at: source, to: staging)
        defer { if files.fileExists(atPath: staging.path) { try? files.removeItem(at: staging) } }
        try run("codesign", ["--verify", "--deep", "--strict", staging.path])
        if runningBundles == nil, NSWorkspace.shared.runningApplications.contains(where: { $0.bundleIdentifier == identifier }) {
            throw DevelopmentError.invalidArguments("O2N started during installation; original bundle and backup retained")
        }
        if existed { _ = try files.replaceItemAt(target, withItemAt: staging) }
        else { try files.moveItem(at: staging, to: target) }
        try run("codesign", ["--verify", "--deep", "--strict", target.path])
        guard try digest(target.appendingPathComponent("Contents/MacOS/OpenOneNoteMac")) == sourceHash else {
            throw DevelopmentError.invalidArguments("Installed executable checksum mismatch; prior bundle backup retained")
        }
        receipt["state"] = "installed and verified"; try record()
        print("Installed verified O2N at \(target.path). Prior app and restore manifest: \(backup.path). Notes, settings and credentials preserved; no app was activated.")
    }
}
