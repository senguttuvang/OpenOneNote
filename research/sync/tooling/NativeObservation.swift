import Foundation
import AppKit

// No launch, activation, Accessibility action, page navigation, or process attachment.
// A targeted lsof read observes OS descriptors; listing scans emit marker booleans only.
@main struct NativeObservation {
    static func main() throws {
        let fm = FileManager.default
        let root = URL(fileURLWithPath: fm.currentDirectoryPath)
        guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.microsoft.onenote.mac").first else { throw DevelopmentError.invalidArguments("OneNote is not running; will not launch it") }
        let foreground = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "unknown"
        let runner = NativeProcessRunner()
        let support = fm.homeDirectoryForCurrentUser.appendingPathComponent("Library/Containers/com.microsoft.onenote.mac/Data/Library/Application Support/Microsoft User Data/OneNote/15.0")
        let descriptors = try runner.run("lsof", ["-a", "-p", String(app.processIdentifier), "-Fn"], at: root, capture: true, timeout: 20).stdout
        var counts: [String: Int] = [:]
        let directories = ["cache", "Backup", "FullTextSearchIndex", "AccessibilityCheckerIndex", "MasterIndex", "NoteTags", "RecentSearches", "ServerListings"]
        for line in descriptors.split(separator: "\n") where line.hasPrefix("n" + support.path + "/") {
            let relative = line.dropFirst(support.path.count + 2)
            let first = String(relative.split(separator: "/").first ?? "unknown")
            counts[directories.contains(first) ? first : "other", default: 0] += 1
        }
        let network = try runner.run("lsof", ["-a", "-p", String(app.processIdentifier), "-iTCP", "-nP", "-Fn"], at: root, capture: true, timeout: 20, allowFailure: true).stdout
        let connections = network.split(separator: "\n").filter { $0.hasPrefix("n") && $0.contains("->") }
        var matches = 0, checked = 0
        for file in try fm.contentsOfDirectory(at: support.appendingPathComponent("ServerListings"), includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey]) {
            let values = try file.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
            guard values.isRegularFile == true, (values.fileSize ?? 0) < 100_000 else { continue }
            let data = try Data(contentsOf: file)
            checked += 1
            if [String.Encoding.utf8, .utf16LittleEndian, .utf16BigEndian].contains(where: { encoding in
                guard let marker = "OpenOneNote Sync Research 20261026 Synthetic".data(using: encoding) else { return false }
                return data.range(of: marker) != nil
            }) { matches += 1 }
        }
        let result: [String: Any] = ["capturedAt": ISO8601DateFormatter().string(from: Date()), "foregroundBundle": foreground, "foregroundUnchangedDuringProbe": NSWorkspace.shared.frontmostApplication?.bundleIdentifier == foreground, "oneNoteActive": app.isActive, "oneNoteHidden": app.isHidden, "openDescriptorsByDirectory": counts, "tcpConnections": connections.count, "tcpRemote443Connections": connections.filter { $0.hasSuffix(":443") }.count, "serverListingFilesChecked": checked, "syntheticTitleListingMatches": matches, "nativeEditPerformed": false, "networkPayloadCaptured": false]
        print(String(decoding: try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys]), as: UTF8.self))
    }
}
