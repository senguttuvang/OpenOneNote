import Foundation
import Testing
@testable import MarkdownNotes

@Test func markdownSemanticRoundtrip() throws {
    let source = """
    # Heading

    Text **bold** and *italic* with [link](https://example.com).

    - first
    - second

    3. three
    4. four

    | Name | Value |
    | --- | --- |
    | alpha | beta |

    ```swift
    let answer = 42
    ```

    ![Synthetic image](.assets/abc.png)
    """
    let codec = MarkdownConversion()
    let parsed = try codec.parse(source)
    #expect(try codec.parse(codec.markdown(parsed)).blocks == parsed.blocks)
    let html = codec.html(parsed)
    #expect(html.contains("<table>"))
    #expect(html.contains("<strong>bold</strong>"))
    #expect(html.contains("<img"))
}

@Test func malformedHTMLAndProtectedObjects() throws {
    let html = "<html><body><div id='outer'><p id='p1'>One <b>bold<p id='p2'>Two &amp; three</p><iframe src='https://example.com'></iframe></div></body></html>"
    let decoded = try HTMLConversion().decode(html)
    #expect(!decoded.blocks.isEmpty)
    #expect(decoded.blocks.contains(where: { !$0.editable }))
    #expect(!decoded.warnings.isEmpty)
    #expect(throws: NotesError.self) { try HTMLConversion().commands(from: decoded, to: NoteDocument(blocks: [])) }
}

@Test func unsupportedMarkdownAndUnsafeDestinationsFail() throws {
    let codec = MarkdownConversion()
    #expect(throws: NotesError.self) { try codec.parse("<script>alert(1)</script>") }
    #expect(throws: NotesError.self) { try codec.parse("![bad](../secret.png)") }
    #expect(throws: NotesError.self) { try codec.parse("[bad](https://example.com/?access_token=secret)") }
    #expect(!MarkdownConversion.safeAsset(".assets/../../secret"))
    #expect(!MarkdownConversion.safeLink("javascript:alert(1)"))
    #expect(try DiagramSource.source(codec.parse("```mermaid\ngraph TD; A-->B\n```").blocks[0]) != nil)
}

@Test func disjointAndOverlappingMerge() throws {
    #expect(try SequenceMerge.merge(base: ["a", "b", "c"], local: ["A", "b", "c"], remote: ["a", "b", "C"]) == ["A", "b", "C"])
    #expect(try SequenceMerge.merge(base: ["a", "b"], local: ["x", "a", "b"], remote: ["a", "b", "y"]) == ["x", "a", "b", "y"])
    #expect(throws: NotesError.conflict) { try SequenceMerge.merge(base: ["a"], local: ["local"], remote: ["remote"]) }
    #expect(throws: NotesError.conflict) { try SequenceMerge.merge(base: ["a"], local: ["x", "a"], remote: ["y", "a"]) }
    #expect(try SequenceMerge.merge(base: ["a"], local: ["b"], remote: ["b"]) == ["b"])
}

@Test func vaultIdentityOfflineRecoveryAndPathSafety() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    var ledger = NoteLedger(identity: PageIdentity(pageID: "synthetic"), title: "../../bad name", baseline: NoteDocument(blocks: []), markdown: "# Original\n", htmlHash: "hash", assets: [])
    try vault.create(ledger)
    try vault.saveOffline("# Offline\n", ledger: &ledger)
    #expect(try vault.load(ledger.id).pendingMarkdown == "# Offline\n")
    #expect(try vault.markdown(ledger) == "# Offline\n")
    #expect(try vault.ledgers().count == 1)
    #expect(throws: NotesError.self) { try vault.safeURL("../secret") }
    let outside = root.deletingLastPathComponent().appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: outside, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: outside) }
    try FileManager.default.createSymbolicLink(at: root.appendingPathComponent("escape"), withDestinationURL: outside)
    #expect(throws: NotesError.self) { try vault.safeURL("escape/note.md") }
    let asset = try vault.storeAsset(Data([1, 2, 3]), resourceURL: "synthetic", extension: "bin")
    #expect(try vault.asset(asset.path) == Data([1, 2, 3]))
    #expect(asset.hash == MarkdownVault.hash(Data([1, 2, 3])))
}

@Test func explicitResolutionKeepsRecoveryHistory() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let codec = MarkdownConversion()
    var ledger = NoteLedger(identity: PageIdentity(pageID: "synthetic"), title: "Test", baseline: try codec.parse("Base\n"), markdown: "Base\n", htmlHash: "base", assets: [])
    try vault.create(ledger)
    try vault.saveOffline("Local\n", ledger: &ledger)
    ledger.remoteRecovery = try codec.parse("Remote\n"); ledger.state = "conflict"; try vault.saveLedger(ledger)
    try vault.resolve(&ledger, editedMarkdown: "Combined\n")
    #expect(ledger.baseline.blocks.first?.text == "Remote")
    #expect(ledger.recoveryVersions?.first?.localMarkdown == "Local\n")
    #expect(ledger.recoveryVersions?.first?.baseline.blocks.first?.text == "Base")
    #expect(try vault.markdown(ledger) == "Combined\n")
}

@Test func changedAddressedAssetIsRejectedAndContainersStayBounded() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let record = try vault.storeAsset(Data([1]), resourceURL: "synthetic", extension: "bin")
    try Data([2]).write(to: vault.safeURL(record.path))
    #expect(throws: NotesError.self) { try vault.asset(record.path) }
    let document = try HTMLConversion().decode("<body><div id='outer1'><p id='p1'>First</p></div><div id='outer2'><p id='p2'>Second</p></div></body>")
    #expect(document.warnings.count == 1)
    #expect(throws: NotesError.self) { try HTMLConversion().commands(from: document, to: NoteDocument(blocks: [])) }
}

@Test func remoteResourceCannotOverwriteModifiedLocalBytes() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let original = Data([1, 2, 3])
    let stored = try vault.storeAsset(original, resourceURL: "synthetic", extension: "png")
    try Data([9, 8, 7]).write(to: vault.safeURL(stored.path))
    #expect(throws: NotesError.conflict) { try vault.storeAsset(original, resourceURL: "synthetic", extension: "png") }
    #expect(try Data(contentsOf: vault.safeURL(stored.path)) == Data([9, 8, 7]))
}

@Test func interruptedRemotePullRecoversIntentWithoutRevertingRemote() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let codec = MarkdownConversion()
    var ledger = NoteLedger(identity: PageIdentity(pageID: "synthetic"), title: "Test", baseline: try codec.parse("Old\n"), markdown: "Old\n", htmlHash: "old", assets: [])
    try vault.create(ledger)
    ledger.state = "materializing"; ledger.pendingMarkdown = "Remote new\n"
    ledger.materializationPreviousHash = MarkdownVault.hash("Old\n")
    ledger.baseline = try codec.parse("Remote new\n"); try vault.saveLedger(ledger)
    try vault.recover(&ledger)
    #expect(try vault.markdown(ledger) == "Remote new\n")
    #expect(ledger.state == "synced")
    ledger.state = "materializing"; ledger.pendingMarkdown = "Remote newer\n"
    ledger.materializationPreviousHash = MarkdownVault.hash("Remote new\n"); try vault.saveLedger(ledger)
    try vault.writeMarkdown("External local edit\n", ledger: ledger)
    #expect(throws: NotesError.conflict) { try vault.recover(&ledger) }
    #expect(try vault.markdown(ledger) == "External local edit\n")
    #expect(try vault.load(ledger.id).pendingMarkdown == "Remote newer\n")
}

@Test func movedMarkdownDoesNotRecreateOldPathAndRelinkKeepsIdentity() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    var ledger = NoteLedger(identity: PageIdentity(pageID: "synthetic"), title: "Moved", baseline: try MarkdownConversion().parse("Original\n"), markdown: "Original\n", htmlHash: "base", assets: [])
    try vault.create(ledger)
    let oldPath = ledger.relativePath
    try FileManager.default.moveItem(at: vault.safeURL(oldPath), to: vault.safeURL("Renamed.md"))
    #expect(throws: NotesError.self) { try vault.saveOffline("New local\n", ledger: &ledger) }
    #expect(!FileManager.default.fileExists(atPath: try vault.safeURL(oldPath).path))
    try vault.relink(&ledger, path: "Renamed.md", preservedLocal: "Unsaved recovery\n")
    #expect(ledger.identity.pageID == "synthetic")
    #expect(ledger.relativePath == "Renamed.md")
    #expect(ledger.recoveryVersions?.last?.localMarkdown == "Unsaved recovery\n")
    #expect(try vault.markdown(ledger) == "Original\n")
}

@Test func ordinaryMarkdownIsAdoptedWithoutRewriteOrDuplicateIdentity() throws {
    let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: root) }
    let vault = try MarkdownVault(root: root)
    let source = "# Portable note\n\nKeep **my** punctuation.\n"
    try Data(source.utf8).write(to: vault.safeURL("Portable.md"))
    let first = try vault.adoptMarkdown(path: "Portable.md")
    let second = try vault.adoptMarkdown(path: "Portable.md")
    #expect(first.id == second.id)
    #expect(first.identity.root == "local")
    #expect(try vault.markdown(first) == source)
}
