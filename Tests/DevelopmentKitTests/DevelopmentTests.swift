import Foundation
import Testing
import DevelopmentKit

@Test func processArgumentsAreLiteralAndExitFailuresPropagate() throws {
    let directory = FileManager.default.temporaryDirectory
    let runner = NativeProcessRunner()
    let literal = "$(echo SHOULD_NOT_RUN); $HOME"
    let result = try runner.run("/usr/bin/printf", ["%s", literal], at: directory, capture: true)
    #expect(result.stdout == literal)
    #expect(result.exitCode == 0)
    #expect(throws: (any Error).self) { try runner.run("/usr/bin/false", [], at: directory) }
}

@Test func versionLabelsCannotEscapeEvidenceDirectories() throws {
    try DevelopmentWorkflow.validateLabel("16.114.1-build_2")
    for label in ["", ".", "..", "../escape", "a/b", "a b", "$(touch file)"] {
        #expect(throws: (any Error).self) { try DevelopmentWorkflow.validateLabel(label) }
    }
}

@Test func subprocessDeadlineFailsAndTerminatesOwnedChild() throws {
    #expect(throws: (any Error).self) {
        try NativeProcessRunner().run("/bin/sleep", ["10"], at: FileManager.default.temporaryDirectory, timeout: 0.05)
    }
}

@Test func authoredAutomationContainsNoShellScripts() throws {
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    for name in ["Sources", "Tools"] {
        let directory = root.appendingPathComponent(name)
        let enumerator = try #require(FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil))
        let shellFiles = enumerator.compactMap { $0 as? URL }.filter { $0.pathExtension == "sh" }
        #expect(shellFiles.isEmpty, "Project automation must be Swift: \(shellFiles.map(\.lastPathComponent))")
    }
}

@Test func offlineIndexExcludesEvidenceBinariesAndRejectsStaleSource() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent("OpenOneNoteIndex-\(UUID())")
    defer { try? FileManager.default.removeItem(at: root) }
    for path in ["Sources", "research/decompiled", "research/originals", "research/assets"] {
        try FileManager.default.createDirectory(at: root.appendingPathComponent(path), withIntermediateDirectories: true)
    }
    let source = root.appendingPathComponent("Sources/Editor.swift")
    try Data("func editSelection() {}".utf8).write(to: source)
    try Data("void ONPageView() {}".utf8).write(to: root.appendingPathComponent("research/decompiled/page.c"))
    try Data("private reference".utf8).write(to: root.appendingPathComponent("research/assets/reference.txt"))
    try Data("version https://git-lfs.github.com/spec/v1\n".utf8).write(to: root.appendingPathComponent("Sources/pointer.txt"))
    let index = try SourceIndex.build(root: root, revision: "fixture")
    #expect(index.documents.count == 2)
    #expect(index.search("editSelection").first?.path == "Sources/Editor.swift")
    #expect(index.search("ONPageView").count == 1)
    #expect(index.search("private").isEmpty)
    try index.verify(root: root)
    let encoded = try JSONEncoder().encode(index)
    let tampered = String(decoding: encoded, as: UTF8.self).replacingOccurrences(of: "func editSelection() {}", with: "func forgedResult() {}")
    let forged = try JSONDecoder().decode(SourceIndex.self, from: Data(tampered.utf8))
    #expect(throws: (any Error).self) { try forged.verify(root: root) }
    try Data("changed".utf8).write(to: source)
    #expect(throws: (any Error).self) { try index.verify(root: root) }
    let fresh = try SourceIndex.build(root: root, revision: "fixture")
    try Data("new file".utf8).write(to: root.appendingPathComponent("Sources/Added.swift"))
    #expect(throws: (any Error).self) { try fresh.verify(root: root) }
}

@Test func signingProfileMustAuthorizeExactO2NTeamAndKeychainGroup() throws {
    let team = "SYNTHETIC"
    let app = team + ".dev.senguttuvang.OpenOneNote"
    let now = Date(timeIntervalSince1970: 1000)
    var profile: [String: Any] = ["ExpirationDate": Date(timeIntervalSince1970: 2000), "TeamIdentifier": [team], "Entitlements": ["com.apple.application-identifier": app, "keychain-access-groups": [app]]]
    try DevelopmentWorkflow.validateSigningProfile(profile, team: team, now: now)
    #expect(throws: DevelopmentError.self) { try DevelopmentWorkflow.validateSigningProfile(profile, team: "OTHER", now: now) }
    profile["ExpirationDate"] = Date(timeIntervalSince1970: 500)
    #expect(throws: DevelopmentError.self) { try DevelopmentWorkflow.validateSigningProfile(profile, team: team, now: now) }
    profile["ExpirationDate"] = Date(timeIntervalSince1970: 2000)
    profile["Entitlements"] = ["com.apple.application-identifier": app, "keychain-access-groups": [team + ".another-app"]]
    #expect(throws: DevelopmentError.self) { try DevelopmentWorkflow.validateSigningProfile(profile, team: team, now: now) }
}
