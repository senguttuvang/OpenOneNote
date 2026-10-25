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
