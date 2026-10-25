import Foundation
import CryptoKit

@MainActor public struct DevelopmentWorkflow {
    public let root: URL
    public let runner: any ProcessRunning
    public init(root: URL, runner: any ProcessRunning = NativeProcessRunner()) { self.root = root; self.runner = runner }

    @discardableResult public func run(_ tool: String, _ arguments: [String], capture: Bool = false,
                                       allowFailure: Bool = false, environment: [String: String] = [:]) throws -> ProcessResult {
        try runner.run(tool, arguments, at: root, capture: capture, timeout: 1200, allowFailure: allowFailure, environment: environment)
    }

    public func releaseDirectory() throws -> URL {
        let result = try run("swift", ["build", "-c", "release", "--show-bin-path"], capture: true)
        guard result.stdout.hasPrefix("/"), !result.stdout.contains("\n") else { throw DevelopmentError.invalidArguments("Invalid SwiftPM build directory") }
        return URL(fileURLWithPath: result.stdout)
    }

    public func build() throws { try run("swift", ["build", "-c", "release", "--jobs", "2"]) }

    public func check() throws {
        try run("swift", ["test", "--jobs", "2"])
        try build()
        let bin = try releaseDirectory()
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent("OpenOneNote-check-\(UUID())")
        try FileManager.default.createDirectory(at: temporary, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temporary) }
        let notebook = temporary.appendingPathComponent("notebook.json")
        try run(bin.appendingPathComponent("openonenote").path, ["create-demo", notebook.path])
        try run(bin.appendingPathComponent("openonenote").path, ["inspect", notebook.path])
        let duplicate = try run(bin.appendingPathComponent("openonenote").path, ["create-demo", notebook.path], allowFailure: true)
        guard duplicate.exitCode != 0 else { throw DevelopmentError.invalidArguments("Demo creation overwrote an existing file") }
        let native = bin.appendingPathComponent("OpenOneNoteMac").path
        try run(native, ["--self-test", temporary.appendingPathComponent("native/notebook.json").path])
        for width in [1728, 1280, 960] { try run(native, ["--render-preview", temporary.appendingPathComponent("preview-\(width).png").path, "\(width)"]) }
        guard try run(native, ["--notebook"], allowFailure: true).exitCode != 0,
              try run(native, ["--render-preview", temporary.appendingPathComponent("invalid.png").path, "invalid"], allowFailure: true).exitCode != 0 else {
            throw DevelopmentError.invalidArguments("Native app accepted invalid arguments")
        }
        let research = bin.appendingPathComponent("onenote-research").path
        guard try run(research, [], allowFailure: true).exitCode != 0 else { throw DevelopmentError.invalidArguments("Research CLI accepted missing arguments") }
        let fixture = temporary.appendingPathComponent("Fixture.app/Contents")
        try FileManager.default.createDirectory(at: fixture, withIntermediateDirectories: true)
        let sample = fixture.appendingPathComponent("sample")
        try Data("abc".utf8).write(to: sample)
        let inventory = temporary.appendingPathComponent("inventory.json")
        let json = "[{\"path\":\"Contents/sample\",\"kind\":\"file\",\"bytes\":3,\"sha256\":\"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad\"}]"
        try Data(json.utf8).write(to: inventory)
        try run(research, ["verify", fixture.deletingLastPathComponent().path, inventory.path])
        try Data("xyz".utf8).write(to: sample)
        guard try run(research, ["verify", fixture.deletingLastPathComponent().path, inventory.path], allowFailure: true).exitCode != 0 else {
            throw DevelopmentError.invalidArguments("Evidence verifier accepted modified bytes")
        }
        try run("git", ["diff", "--check", "--", ".", ":!research"])
        try run("git", ["diff", "--cached", "--check", "--", ".", ":!research"])
        print("Swift tests, release build, native edit/format/undo/reopen, native renders, CLI rejection and evidence integrity checks passed")
    }

    public nonisolated static func validateLabel(_ value: String) throws {
        guard !value.isEmpty, value != ".", value != "..", value.unicodeScalars.allSatisfy({
            CharacterSet.alphanumerics.contains($0) || "._-".unicodeScalars.contains($0)
        }) else { throw DevelopmentError.invalidArguments("Version label must contain only letters, digits, dots, underscores, or hyphens") }
    }

    public func digest(_ url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url); defer { try? handle.close() }
        var hash = SHA256()
        while let data = try handle.read(upToCount: 1024 * 1024), !data.isEmpty { hash.update(data: data) }
        return hash.finalize().map { String(format: "%02x", $0) }.joined()
    }

    public func archive(_ input: URL, to output: URL) throws {
        guard !FileManager.default.fileExists(atPath: output.path) else { throw DevelopmentError.outputExists(output.path) }
        try FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)
        let partial = output.deletingPathExtension().appendingPathExtension("partial.gz")
        guard !FileManager.default.fileExists(atPath: partial.path) else { throw DevelopmentError.outputExists(partial.path) }
        try run("tar", ["-czf", partial.path, "-C", input.deletingLastPathComponent().path, input.lastPathComponent], environment: ["COPYFILE_DISABLE": "1"])
        try run("gzip", ["-t", partial.path])
        try FileManager.default.moveItem(at: partial, to: output)
        let relative = output.path.replacingOccurrences(of: root.path + "/", with: "")
        try Data("\(digest(output))  \(relative)\n".utf8).write(to: output.appendingPathExtension("sha256"))
    }
}
