import Foundation
import Testing
import DevelopmentKit

private struct BundleSignatureRunner: ProcessRunning {
    func run(_ tool: String, _ arguments: [String], at directory: URL, capture: Bool, timeout: TimeInterval, allowFailure: Bool, environment: [String: String]) throws -> ProcessResult {
        #expect(tool == "codesign")
        #expect(arguments.prefix(3) == ["--verify", "--deep", "--strict"])
        return ProcessResult(exitCode: 0, stdout: "") // Synthetic signature boundary, not real signing proof.
    }
}

private func fixtureBundle(_ path: URL, bytes: String, identifier: String = "dev.senguttuvang.OpenOneNote") throws {
    let contents = path.appendingPathComponent("Contents")
    try FileManager.default.createDirectory(at: contents.appendingPathComponent("MacOS"), withIntermediateDirectories: true)
    let plist = ["CFBundleIdentifier": identifier, "CFBundleName": "OpenOneNote", "CFBundleExecutable": "OpenOneNoteMac", "CFBundlePackageType": "APPL"]
    try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0).write(to: contents.appendingPathComponent("Info.plist"))
    try Data(bytes.utf8).write(to: contents.appendingPathComponent("MacOS/OpenOneNoteMac"))
}

@Test @MainActor func appInstallPreservesPreviousBundleAndLeavesNoteFilesUntouched() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let source = root.appendingPathComponent("dist/OpenOneNote.app")
    let target = root.appendingPathComponent("Applications/OpenOneNote.app")
    let backups = root.appendingPathComponent("backups")
    try fixtureBundle(source, bytes: "new synthetic executable")
    try fixtureBundle(target, bytes: "prior synthetic executable")
    let notes = root.appendingPathComponent("notes.md")
    try Data("User notes stay intact".utf8).write(to: notes)
    try DevelopmentWorkflow(root: root, runner: BundleSignatureRunner()).installApp(destination: target, backupRoot: backups, runningBundles: [])
    #expect(try String(contentsOf: target.appendingPathComponent("Contents/MacOS/OpenOneNoteMac"), encoding: .utf8) == "new synthetic executable")
    let backup = try #require(FileManager.default.contentsOfDirectory(at: backups, includingPropertiesForKeys: nil).first)
    #expect(try String(contentsOf: backup.appendingPathComponent("OpenOneNote.app/Contents/MacOS/OpenOneNoteMac"), encoding: .utf8) == "prior synthetic executable")
    #expect(try String(contentsOf: notes, encoding: .utf8) == "User notes stay intact")
    let manifest = try JSONDecoder().decode([String: String].self, from: Data(contentsOf: backup.appendingPathComponent("manifest.json")))
    #expect(manifest["state"] == "installed and verified")
    #expect(manifest["priorBundlePreserved"] == "true")
}

@Test @MainActor func appInstallRejectsActiveOrUnrelatedApplicationsBeforeReplacement() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let source = root.appendingPathComponent("dist/OpenOneNote.app")
    let target = root.appendingPathComponent("Applications/OpenOneNote.app")
    try fixtureBundle(source, bytes: "new")
    try fixtureBundle(target, bytes: "unrelated", identifier: "test.unrelated")
    let workflow = DevelopmentWorkflow(root: root, runner: BundleSignatureRunner())
    for running in [[target], []] {
        #expect(throws: DevelopmentError.self) { try workflow.installApp(destination: target, backupRoot: root.appendingPathComponent("backups"), runningBundles: running) }
    }
    #expect(try String(contentsOf: target.appendingPathComponent("Contents/MacOS/OpenOneNoteMac"), encoding: .utf8) == "unrelated")
    #expect(!FileManager.default.fileExists(atPath: root.appendingPathComponent("backups").path))
}
