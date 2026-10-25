import Foundation
import Testing

private let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

private func forbiddenImports(in source: String, allowed: Set<String>) -> [String] {
    source.split(separator: "\n").compactMap { line in
        let parts = line.split(whereSeparator: { $0.isWhitespace })
        guard parts.count >= 2, parts[0] == "import" else { return nil }
        let module = String(parts[1])
        return allowed.contains(module) ? nil : module
    }
}

@Test func coreAndPersistenceKeepDependenciesInward() throws {
    for (target, allowed) in [
        ("NotebookCore", Set(["Foundation"])),
        ("NotebookPersistence", Set(["Foundation", "NotebookCore"]))
    ] {
        let directory = root.appendingPathComponent("Sources/" + target)
        let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }
        #expect(!files.isEmpty)
        #expect(files.count <= 15)
        for file in files {
            let source = try String(contentsOf: file, encoding: .utf8)
            #expect(forbiddenImports(in: source, allowed: allowed).isEmpty, "Unexpected dependency in \(file.lastPathComponent)")
            #expect(source.split(separator: "\n", omittingEmptySubsequences: false).count <= 700)
        }
    }
}

@Test func architectureRuleRejectsUIAndOutwardImports() {
    #expect(forbiddenImports(in: "import SwiftUI\nimport NotebookPersistence\nimport Foundation", allowed: ["Foundation"]) == ["SwiftUI", "NotebookPersistence"])
}
