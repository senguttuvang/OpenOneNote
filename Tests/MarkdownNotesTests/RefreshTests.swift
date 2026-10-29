import Foundation
import Testing
import MarkdownNotes
import MarkdownEditor
@testable import OneNoteGraph

@Test func unchangedMetadataCannotSuppressContentReconciliation() {
    var policy = RemoteRefreshPolicy()
    let now = Date(timeIntervalSince1970: 1000)
    #expect(policy.needsContent(hint: "unchanged", now: now))
    policy.succeeded(hint: "unchanged", contentChecked: true, changed: false, now: now)
    #expect(!policy.needsContent(hint: "unchanged", now: now.addingTimeInterval(119)))
    #expect(policy.needsContent(hint: "unchanged", now: now.addingTimeInterval(120)))
    #expect(policy.needsContent(hint: "different", now: now.addingTimeInterval(1)))
    #expect(policy.needsContent(hint: nil, now: now))
    #expect(policy.needsContent(hint: "unchanged", now: now, force: true))
}

@Test func refreshAdaptsToActivityAndHonorsProviderBackoffEvenOnFocus() {
    var policy = RemoteRefreshPolicy()
    let now = Date(timeIntervalSince1970: 1000)
    for _ in 0..<8 { policy.succeeded(hint: "same", contentChecked: true, changed: false, now: now) }
    #expect(policy.interval == 120)
    #expect(policy.canRefresh(now: now, force: true))
    #expect(!policy.canRefresh(now: now.addingTimeInterval(119), force: false))
    policy.succeeded(hint: "new", contentChecked: true, changed: true, now: now)
    #expect(policy.interval == 15)
    policy.failed(now: now, retryAfter: 900)
    #expect(!policy.canRefresh(now: now.addingTimeInterval(899), force: true))
    policy.selectedPageChanged()
    #expect(!policy.canRefresh(now: now.addingTimeInterval(899), force: true))
    #expect(policy.canRefresh(now: now.addingTimeInterval(900), force: true))
}

@Test func adaptiveMetadataScheduleCannotDelayThePeriodicContentDeadline() {
    var policy = RemoteRefreshPolicy()
    let now = Date(timeIntervalSince1970: 1000)
    policy.succeeded(hint: "same", contentChecked: true, changed: false, now: now)
    policy.succeeded(hint: "same", contentChecked: false, changed: false, now: now.addingTimeInterval(30))
    policy.succeeded(hint: "same", contentChecked: false, changed: false, now: now.addingTimeInterval(90))
    #expect(policy.notBefore == now.addingTimeInterval(120))
}

@Test @MainActor func nativeMicrosoftConfigurationRejectsCrossTenantAndUnregisteredCallbacks() throws {
    let client = "11111111-1111-1111-1111-111111111111"
    let tenant = "22222222-2222-2222-2222-222222222222"
    try MicrosoftSignIn.validate(clientID: client, tenant: tenant, redirectURI: "msauth.dev.senguttuvang.OpenOneNote://auth")
    for (app, directory, redirect) in [("invalid", tenant, "msauth.dev.senguttuvang.OpenOneNote://auth"),
                                       (client, "common", "msauth.dev.senguttuvang.OpenOneNote://auth"),
                                       (client, tenant, "http://localhost"),
                                       (client, tenant, "msauth.dev.senguttuvang.OpenOneNote://auth?code=synthetic")] {
        #expect(throws: NotesError.self) { try MicrosoftSignIn.validate(clientID: app, tenant: directory, redirectURI: redirect) }
    }
}
