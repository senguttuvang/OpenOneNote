import Foundation
import Testing
import MarkdownNotes
import DevelopmentKit

@Test @MainActor func startupDemoIsLocalOnlyAndRefusesToReplaceExistingContent() throws {
    let parent = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: false)
    defer { try? FileManager.default.removeItem(at: parent) }
    let output = parent.appendingPathComponent("demo")
    let workflow = DevelopmentWorkflow(root: parent)
    let count = try workflow.createDemoVault(at: output)
    let vault = try MarkdownVault(root: output)
    let pages = try vault.ledgers()
    #expect(count == 17)
    #expect(pages.count == count)
    #expect(Set(pages.compactMap { $0.hierarchy?.last }).count == 6)
    #expect(pages.allSatisfy { $0.identity.root == "local" && $0.state == "local-only" })
    #expect(!FileManager.default.fileExists(atPath: output.appendingPathComponent(".o2n/config").path))
    let brief = try #require(pages.first { $0.title == "01 Product brief" })
    #expect(try vault.markdown(brief).contains("Onboarding completion"))
    let flow = try #require(pages.first { $0.title == "02 Onboarding flow" })
    #expect(try vault.markdown(flow).contains("```mermaid"))
    #expect(throws: DevelopmentError.self) { try workflow.createDemoVault(at: output) }
    #expect(try vault.ledgers().count == count)
    #expect(try vault.markdown(brief) == brief.baselineMarkdown)
    let link = parent.appendingPathComponent("dangling")
    try FileManager.default.createSymbolicLink(at: link, withDestinationURL: parent.appendingPathComponent("absent"))
    #expect(throws: DevelopmentError.self) { try workflow.createDemoVault(at: link) }
    #expect(!FileManager.default.fileExists(atPath: parent.appendingPathComponent("absent").path))
}
