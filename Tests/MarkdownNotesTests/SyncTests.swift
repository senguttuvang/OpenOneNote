import Foundation
import Testing
@testable import MarkdownNotes

private actor SyntheticRemote: OneNoteRemote {
    var html: String
    var afterWrite: String?
    var offline = false
    var writes: [[PageCommand]] = []
    var resources: [String: Data] = [:]
    var uploadedBytes: [Data] = []
    init(_ html: String) { self.html = html }
    func setHTML(_ html: String) { self.html = html }
    func setOffline(_ value: Bool) { offline = value }
    func setAfterWrite(_ html: String) { afterWrite = html }
    func addResource(_ url: String, bytes: Data) { resources[url] = bytes }
    func fetch(_ identity: PageIdentity) throws -> RemotePage {
        if offline { throw URLError(.notConnectedToInternet) }
        return RemotePage(id: identity.pageID, title: "Synthetic", html: html)
    }
    func resource(_ url: URL) throws -> Data {
        guard let bytes = resources[url.absoluteString] else { throw NotesError.http(404) }
        return bytes
    }
    func update(_ identity: PageIdentity, commands: [PageCommand], parts: [BinaryPart]) throws {
        if offline { throw URLError(.notConnectedToInternet) }
        writes.append(commands)
        uploadedBytes += parts.map(\.bytes)
        if let afterWrite { html = afterWrite }
    }
}
private func page(_ first: String, _ second: String = "Second") -> String {
    "<html><body><div id='outer'><p id='p1'>\(first)</p><p id='p2'>\(second)</p></div></body></html>"
}

@Test func officialTrailingBreakIsPreservedWithoutBlockingSupportedEdits() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let imageURL = "https://graph.microsoft.com/v1.0/me/onenote/resources/original/$value"
    let imageBytes = Data([0x89, 0x50, 0x4e, 0x47, 1, 2, 3])
    let original = "<body><div id='outer'><p id='keep'><b>Keep தமிழ் 🌿</b></p><p id='edit'>Original</p><img id='picture' src='\(imageURL)' /><iframe id='protected'></iframe><br id='empty' /></div></body>"
    let remote = SyntheticRemote(original)
    await remote.addResource(imageURL, bytes: imageBytes)
    let sync = NoteSync(vault: vault, remote: remote)
    let ledger = try await sync.open(PageIdentity(pageID: "official-origin"))
    let source = try vault.markdown(ledger).replacingOccurrences(of: "Original", with: "Changed in O2N")
    _ = try await sync.save(ledger.id, markdown: source)
    await remote.setAfterWrite(original.replacingOccurrences(of: "Original", with: "Changed in O2N"))
    let result = try await sync.sync(ledger.id)
    #expect(result.state == "synced")
    let commands = try #require(await remote.writes.first)
    #expect(commands.count == 1)
    #expect(commands[0].target == "edit")
    #expect(await remote.uploadedBytes.isEmpty)
    #expect(result.assets == ledger.assets)
    #expect(result.assets.first?.hash == MarkdownVault.hash(imageBytes))
    #expect(try vault.markdown(result).contains("Keep தமிழ் 🌿"))
}

@Test func samePageOfflineReconnectAndRemotePull() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let remote = SyntheticRemote(page("Original"))
    let sync = NoteSync(vault: vault, remote: remote)
    let ledger = try await sync.open(PageIdentity(pageID: "synthetic-page"))
    #expect(try vault.markdown(ledger) == "Original\n\nSecond\n")
    _ = try await sync.save(ledger.id, markdown: "Offline edit\n\nSecond\n")
    await remote.setOffline(true)
    await #expect(throws: URLError.self) { try await sync.sync(ledger.id) }
    #expect(try vault.markdown(ledger).contains("Offline edit"))
    await remote.setOffline(false)
    await remote.setAfterWrite(page("Offline edit"))
    let synced = try await sync.sync(ledger.id)
    #expect(synced.state == "synced")
    #expect(synced.identity.pageID == "synthetic-page")
    #expect(await remote.writes.count == 1)
    #expect(await remote.writes.first?.first?.target == "p1")
    await remote.setHTML(page("Offline edit", "External edit"))
    _ = try await sync.sync(ledger.id)
    #expect(try vault.markdown(ledger).contains("External edit"))
    #expect(await remote.writes.count == 1)
}

@Test func syncDisjointMergeAndOverlapPreserveAllCopies() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let remote = SyntheticRemote(page("First"))
    let sync = NoteSync(vault: vault, remote: remote)
    let ledger = try await sync.open(PageIdentity(pageID: "synthetic-page"))
    _ = try await sync.save(ledger.id, markdown: "Local\n\nSecond\n")
    await remote.setHTML(page("First", "Remote"))
    await remote.setAfterWrite(page("Local", "Remote"))
    _ = try await sync.sync(ledger.id)
    #expect(try vault.markdown(ledger) == "Local\n\nRemote\n")
    _ = try await sync.save(ledger.id, markdown: "Local overlap\n\nRemote\n")
    await remote.setHTML(page("Remote overlap", "Remote"))
    await #expect(throws: NotesError.conflict) { try await sync.sync(ledger.id) }
    let conflict = try vault.load(ledger.id)
    #expect(conflict.state == "conflict")
    #expect(conflict.pendingMarkdown?.contains("Local overlap") == true)
    #expect(conflict.remoteRecovery?.blocks.first?.text == "Remote overlap")
    #expect(conflict.baseline.blocks.first?.text == "Local")
    #expect(try vault.markdown(ledger).contains("Local overlap"))
    #expect(await remote.writes.count == 1)
}

@Test func readbackMismatchNeverAdvancesBaseline() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let remote = SyntheticRemote(page("First"))
    let sync = NoteSync(vault: vault, remote: remote)
    let ledger = try await sync.open(PageIdentity(pageID: "synthetic-page"))
    _ = try await sync.save(ledger.id, markdown: "Changed\n\nSecond\n")
    await #expect(throws: NotesError.remoteChanged) { try await sync.sync(ledger.id) }
    let recovery = try vault.load(ledger.id)
    #expect(recovery.state == "readback-mismatch")
    #expect(recovery.baseline.blocks.first?.text == "First")
    #expect(try vault.markdown(ledger).contains("Changed"))
}

@Test func backgroundRefreshPullsRemoteOnlyAndNeverPushesLocalOutbox() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let remote = SyntheticRemote(page("Original"))
    let sync = NoteSync(vault: vault, remote: remote)
    let ledger = try await sync.open(PageIdentity(pageID: "synthetic-page"))
    await remote.setHTML(page("Remote only"))
    _ = try await sync.sync(ledger.id, allowPush: false)
    #expect(try vault.markdown(ledger).contains("Remote only"))
    _ = try await sync.save(ledger.id, markdown: "Offline pending\n\nSecond\n")
    let pending = try await sync.sync(ledger.id, allowPush: false)
    #expect(pending.state == "outbox")
    #expect(try vault.markdown(ledger).contains("Offline pending"))
    #expect(await remote.writes.isEmpty)
}

@Test func imageResourceDownloadEditUploadAndHashReadback() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let oldURL = "https://graph.microsoft.com/v1.0/me/onenote/resources/old/$value"
    let newURL = "https://graph.microsoft.com/v1.0/me/onenote/resources/new/$value"
    let oldBytes = Data([0x89, 0x50, 0x4e, 0x47, 1, 2, 3])
    let newBytes = Data([0x89, 0x50, 0x4e, 0x47, 9, 8, 7])
    let remote = SyntheticRemote("<body><div id='outer'><img id='image' src='\(oldURL)' alt='Synthetic' /></div></body>")
    await remote.addResource(oldURL, bytes: oldBytes)
    await remote.addResource(newURL, bytes: newBytes)
    let sync = NoteSync(vault: vault, remote: remote)
    let ledger = try await sync.open(PageIdentity(pageID: "synthetic-image"))
    #expect(ledger.assets.count == 1)
    #expect(try vault.asset(ledger.assets[0].path) == oldBytes)
    #expect(try !vault.markdown(ledger).contains("graph.microsoft.com"))
    let replacement = try vault.storeAsset(newBytes, resourceURL: "", extension: "png")
    _ = try await sync.save(ledger.id, markdown: "![Synthetic](\(replacement.path))\n")
    await remote.setAfterWrite("<body><div id='outer'><img id='new-image-id' src='\(newURL)' alt='Synthetic' /></div></body>")
    let synced = try await sync.sync(ledger.id)
    #expect(synced.state == "synced")
    #expect(await remote.uploadedBytes == [newBytes])
    #expect(synced.assets.first?.hash == replacement.hash)
    #expect(synced.identity.pageID == "synthetic-image")
}

private struct SyntheticDiagramRenderer: DiagramRendering {
    let bytes: Data
    func png(source: String) async throws -> Data { bytes }
}

@Test func diagramSourceAttachmentRecoveryAndChangedPreviewProtection() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let source = "flowchart LR\n A-->B\n"
    let png = Data([0x89, 0x50, 0x4e, 0x47, 1, 3, 5])
    let changedPNG = Data([0x89, 0x50, 0x4e, 0x47, 2, 4, 6])
    let filename = DiagramSource.filename(sourceHash: MarkdownVault.hash(source), previewHash: MarkdownVault.hash(png))
    let imageURL = "https://graph.microsoft.com/v1.0/me/onenote/resources/diagram/$value"
    let sourceURL = "https://graph.microsoft.com/v1.0/me/onenote/resources/source/$value"
    let remote = SyntheticRemote("<body><div id='outer'><p id='p'>Base</p></div></body>")
    await remote.addResource(imageURL, bytes: png)
    await remote.addResource(sourceURL, bytes: Data(source.utf8))
    let diagramHTML = "<body><div id='outer'><img id='diagram' src='\(imageURL)' alt='O2N diagram' /><object id='source' data='\(sourceURL)' data-attachment='\(filename)' type='application/octet-stream'></object></div></body>"
    await remote.setAfterWrite(diagramHTML)
    let sync = NoteSync(vault: vault, remote: remote, diagrams: SyntheticDiagramRenderer(bytes: png))
    let ledger = try await sync.open(PageIdentity(pageID: "synthetic-diagram"))
    _ = try await sync.save(ledger.id, markdown: "```mermaid\n\(source)```\n")
    let synced = try await sync.sync(ledger.id)
    #expect(synced.state == "synced")
    #expect(await remote.uploadedBytes.count == 2)
    #expect(DiagramSource.source(synced.baseline.blocks[0]) == source)
    // A fresh vault recovers editable source from the verified attachment, not from pixels.
    let other = try MarkdownVault(root: directory.appendingPathComponent("other-device"))
    let recovered = try await NoteSync(vault: other, remote: remote).open(ledger.identity)
    #expect(try other.markdown(recovered).contains("```mermaid"))
    await remote.addResource(imageURL, bytes: changedPNG)
    await remote.setHTML(diagramHTML)
    let stale = try await sync.sync(ledger.id, allowPush: false)
    #expect(stale.baseline.warnings.contains(where: { $0.contains("stale") }))
    #expect(!stale.baseline.blocks.contains(where: { DiagramSource.source($0) != nil }))
    #expect(stale.recoveryVersions?.last?.localMarkdown.contains("```mermaid") == true)
    #expect(await remote.writes.count == 1)
}

private struct MismatchedPageRemote: OneNoteRemote {
    func fetch(_ identity: PageIdentity) async throws -> RemotePage { RemotePage(id: "different-synthetic-page", title: "Wrong page", html: "<body><div><p>Wrong body</p></div></body>") }
    func resource(_ url: URL) async throws -> Data { throw NotesError.http(404) }
    func update(_ identity: PageIdentity, commands: [PageCommand], parts: [BinaryPart]) async throws { throw NotesError.invalid("Unexpected write") }
}

@Test func wrongRemotePageIdentityCannotEnterTheVault() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    let sync = NoteSync(vault: vault, remote: MismatchedPageRemote())
    await #expect(throws: NotesError.self) { try await sync.open(PageIdentity(pageID: "expected-synthetic-page")) }
    #expect(try vault.ledgers().isEmpty)
}

@Test func disjointMergeRetainsUnchangedMarkdownSpellingAndUnicode() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let vault = try MarkdownVault(root: directory)
    func html(_ local: String, _ remote: String) -> String { "<body><div id='outer'><p id='keep'>தமிழ் <b>bold</b></p><p id='local'>\(local)</p><p id='remote'>\(remote)</p></div></body>" }
    let server = SyntheticRemote(html("Local base", "Remote base"))
    let sync = NoteSync(vault: vault, remote: server)
    let ledger = try await sync.open(PageIdentity(pageID: "synthetic-spelling"))
    _ = try await sync.save(ledger.id, markdown: "தமிழ் __bold__\n\nLocal changed\n\nRemote base\n")
    await server.setHTML(html("Local base", "Remote changed"))
    await server.setAfterWrite(html("Local changed", "Remote changed"))
    _ = try await sync.sync(ledger.id)
    #expect(try vault.markdown(ledger) == "தமிழ் __bold__\n\nLocal changed\n\nRemote changed\n")
}
