import Foundation
import CryptoKit

struct Entry: Codable {
    let path: String
    let kind: String
    let bytes: Int?
    let sha256: String?
    let destination: String?
}

enum ResearchError: Error { case usage, unsafeDestination, command(String, Int32), invalidBundle, mismatch(String) }

func digest(_ url: URL) throws -> String {
    let handle = try FileHandle(forReadingFrom: url)
    defer { try? handle.close() }
    var hash = SHA256()
    while let chunk = try handle.read(upToCount: 1024 * 1024), !chunk.isEmpty { hash.update(data: chunk) }
    return hash.finalize().map { String(format: "%02x", $0) }.joined()
}

func command(_ executable: String, _ arguments: [String], to output: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    // Scope captures to static bundle data. No account stores, process memory, or network traffic.
    let file = output.appendingPathExtension("partial")
    guard FileManager.default.createFile(atPath: file.path, contents: nil) else { throw ResearchError.unsafeDestination }
    let handle = try FileHandle(forWritingTo: file)
    process.standardOutput = handle
    process.standardError = handle
    defer { try? handle.close() }
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { throw ResearchError.command(executable, process.terminationStatus) }
    try FileManager.default.moveItem(at: file, to: output)
}

func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    try encoder.encode(value).write(to: url, options: .atomic)
}

func capture(bundle: URL, output: URL) throws {
    let fm = FileManager.default
    guard bundle.pathExtension == "app", fm.fileExists(atPath: bundle.appendingPathComponent("Contents/Info.plist").path) else {
        throw ResearchError.invalidBundle
    }
    guard !output.path.hasPrefix(bundle.path + "/"), output != bundle, !fm.fileExists(atPath: output.path) else {
        throw ResearchError.unsafeDestination
    }
    try fm.createDirectory(at: output, withIntermediateDirectories: true)
    let keys: Set<URLResourceKey> = [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey]
    var enumerationError: Error?
    guard let enumerator = fm.enumerator(at: bundle, includingPropertiesForKeys: Array(keys), errorHandler: { _, error in
        enumerationError = error
        return false
    }) else { throw ResearchError.invalidBundle }
    var entries: [Entry] = []
    var binaries: [String] = []
    for case let url as URL in enumerator {
        let values = try url.resourceValues(forKeys: keys)
        let relative = String(url.path.dropFirst(bundle.path.count + 1))
        if values.isSymbolicLink == true {
            entries.append(Entry(path: relative, kind: "symlink", bytes: nil, sha256: nil,
                                 destination: try fm.destinationOfSymbolicLink(atPath: url.path)))
        } else if values.isRegularFile == true {
            entries.append(Entry(path: relative, kind: "file", bytes: values.fileSize, sha256: try digest(url), destination: nil))
            let handle = try FileHandle(forReadingFrom: url)
            let prefix = try handle.read(upToCount: 4) ?? Data()
            try handle.close()
            let magic = prefix.map { String(format: "%02x", $0) }.joined()
            if ["cafebabe", "bebafeca", "cffaedfe", "feedfacf", "cefaedfe", "feedface", "cafebabf"].contains(magic) {
                binaries.append(relative)
            }
        }
    }
    if let enumerationError { throw enumerationError }
    entries.sort { $0.path < $1.path }
    try writeJSON(entries, to: output.appendingPathComponent("bundle-inventory.json"))
    try writeJSON(binaries.sorted(), to: output.appendingPathComponent("mach-o-files.json"))
    try fm.copyItem(at: bundle.appendingPathComponent("Contents/Info.plist"), to: output.appendingPathComponent("Info.plist"))
    let infoData = try Data(contentsOf: bundle.appendingPathComponent("Contents/Info.plist"))
    guard let info = try PropertyListSerialization.propertyList(from: infoData, format: nil) as? [String: Any],
          let executableName = info["CFBundleExecutable"] as? String,
          !executableName.contains("/") else { throw ResearchError.invalidBundle }
    let executable = bundle.appendingPathComponent("Contents/MacOS/" + executableName).path
    let commands: [(String, String, [String])] = [
        ("file", "/usr/bin/file", [executable]),
        ("signature", "/usr/bin/codesign", ["-dv", "--verbose=4", bundle.path]),
        ("signature-verification", "/usr/bin/codesign", ["--verify", "--deep", "--strict", "--verbose=2", bundle.path]),
        ("entitlements", "/usr/bin/codesign", ["-d", "--entitlements", ":-", bundle.path]),
        ("dependencies-arm64", "/usr/bin/otool", ["-arch", "arm64", "-L", executable]),
        ("load-commands-arm64", "/usr/bin/otool", ["-arch", "arm64", "-l", executable]),
        ("symbols-arm64", "/usr/bin/nm", ["-arch", "arm64", "-m", executable]),
        ("objc-metadata-arm64", "/usr/bin/otool", ["-arch", "arm64", "-ov", executable]),
        ("strings", "/usr/bin/strings", ["-a", executable]),
        ("disassembly-arm64", "/usr/bin/xcrun", ["llvm-objdump", "--arch=arm64", "--disassemble", executable])
    ]
    var recorded: [[String: String]] = []
    for (name, tool, arguments) in commands {
        print("Capturing \(name)")
        try command(tool, arguments, to: output.appendingPathComponent(name + ".txt"))
        recorded.append(["artifact": name + ".txt", "tool": tool, "arguments": arguments.joined(separator: " ")])
    }
    let assembly = output.appendingPathComponent("disassembly-arm64.txt")
    try command("/usr/bin/gzip", ["-c", assembly.path], to: assembly.appendingPathExtension("gz"))
    try fm.removeItem(at: assembly)
    let dependencies = output.appendingPathComponent("frameworks")
    try fm.createDirectory(at: dependencies, withIntermediateDirectories: true)
    for relative in binaries.sorted() where relative.hasPrefix("Contents/Frameworks/") {
        let name = relative.replacingOccurrences(of: "/", with: "__")
        try command("/usr/bin/otool", ["-arch", "arm64", "-L", bundle.appendingPathComponent(relative).path],
                    to: dependencies.appendingPathComponent(name + ".txt"))
    }
    try writeJSON(recorded, to: output.appendingPathComponent("commands.json"))
    try writeJSON([
        "capturedAt": ISO8601DateFormatter().string(from: Date()),
        "bundleName": bundle.lastPathComponent,
        "version": info["CFBundleShortVersionString"] as? String ?? "unknown",
        "build": info["CFBundleVersion"] as? String ?? "unknown",
        "executableSHA256": try digest(URL(fileURLWithPath: executable)),
        "scope": "Static application bundle only; no notebook caches, Keychain, account data, or runtime traffic.",
        "disassemblyScope": "Full arm64 main executable disassembly, compressed; no source reconstruction implied."
    ], to: output.appendingPathComponent("provenance.json"))
    print("Captured \(entries.count) file/link entries and \(binaries.count) Mach-O candidates")
}

func verify(bundle: URL, inventory: URL) throws {
    let entries = try JSONDecoder().decode([Entry].self, from: Data(contentsOf: inventory))
    for entry in entries {
        guard !entry.path.hasPrefix("/"), !entry.path.split(separator: "/").contains("..") else {
            throw ResearchError.mismatch("Unsafe inventory path")
        }
        let url = bundle.appendingPathComponent(entry.path)
        if entry.kind == "symlink" {
            guard try FileManager.default.destinationOfSymbolicLink(atPath: url.path) == entry.destination else {
                throw ResearchError.mismatch(entry.path)
            }
        } else {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
            guard values.isRegularFile == true, values.isSymbolicLink != true, values.fileSize == entry.bytes,
                  try digest(url) == entry.sha256 else { throw ResearchError.mismatch(entry.path) }
        }
    }
    print("Verified \(entries.count) captured files and symlinks against SHA-256 inventory")
}

func summarize(extraction: URL, output: URL) throws {
    guard !FileManager.default.fileExists(atPath: output.path) else { throw ResearchError.unsafeDestination }
    let entries = try JSONDecoder().decode([Entry].self, from: Data(contentsOf: extraction.appendingPathComponent("bundle-inventory.json")))
    let binaries = try JSONDecoder().decode([String].self, from: Data(contentsOf: extraction.appendingPathComponent("mach-o-files.json")))
    let metadata = try String(contentsOf: extraction.appendingPathComponent("objc-metadata-arm64.txt"), encoding: .utf8)
    let names = metadata.split(separator: "\n").compactMap { line -> String? in
        let parts = line.split(whereSeparator: { $0.isWhitespace })
        guard parts.count == 3, parts[0] == "name", parts[1].hasPrefix("0x"),
              parts[2].first?.isLetter == true else { return nil }
        return String(parts[2])
    }
    let classesAndProtocols = Set(names).sorted()
    let paths = entries.map(\.path)
    let regular = entries.filter { $0.kind == "file" }
    let summary: [String: Any] = [
        "fileAndSymlinkEntries": entries.count,
        "regularFiles": regular.count,
        "symlinks": entries.filter { $0.kind == "symlink" }.count,
        "regularFileBytes": regular.reduce(0) { $0 + ($1.bytes ?? 0) },
        "machOCandidates": binaries.count,
        "uniqueObjCNames": classesAndProtocols.count,
        "jsBundles": paths.filter { $0.hasSuffix(".jsbundle") },
        "electronPackagingMarkers": paths.filter {
            let lower = $0.lowercased()
            return lower.contains("electron.framework") || lower.hasSuffix("app.asar") || lower.contains("chromium framework.framework")
        },
        "swiftMainImports": try String(contentsOf: extraction.appendingPathComponent("symbols-arm64.txt"), encoding: .utf8)
            .split(separator: "\n").filter { $0.contains("_$s") }.map(String.init),
        "objcNames": classesAndProtocols
    ]
    let data = try JSONSerialization.data(withJSONObject: summary, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
    try data.write(to: output, options: .atomic)
    print("Summarized \(entries.count) entries and \(classesAndProtocols.count) Objective-C class/protocol names")
}

do {
    let arguments = Array(CommandLine.arguments.dropFirst())
    guard arguments.count == 3 else { throw ResearchError.usage }
    switch arguments[0] {
    case "capture":
        try capture(bundle: URL(fileURLWithPath: arguments[1]).resolvingSymlinksInPath(),
                    output: URL(fileURLWithPath: arguments[2]).resolvingSymlinksInPath())
    case "verify":
        try verify(bundle: URL(fileURLWithPath: arguments[1]).resolvingSymlinksInPath(),
                   inventory: URL(fileURLWithPath: arguments[2]))
    case "summarize":
        try summarize(extraction: URL(fileURLWithPath: arguments[1]), output: URL(fileURLWithPath: arguments[2]))
    default: throw ResearchError.usage
    }
} catch {
    FileHandle.standardError.write(Data("Research operation failed: \(error)\nUsage: onenote-research <capture|verify|summarize> <bundle|extraction> <output|inventory.json>\n".utf8))
    exit(1)
}
