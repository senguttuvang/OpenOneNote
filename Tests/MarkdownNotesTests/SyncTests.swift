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
