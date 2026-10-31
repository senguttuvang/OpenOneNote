import Foundation
import Testing
@preconcurrency import AppAuth
@testable import OneNoteGraph

@MainActor private final class BrowserSessionProbe: NSObject, @preconcurrency OIDExternalUserAgentSession {
    var rejection: NSError?
    var failed: NSError?
    var resumes = 0
    var cancellations = 0
    func cancel() { cancellations += 1 }
    func cancel(completion: (@Sendable () -> Void)?) { cancel(); completion?() }
    func resumeExternalUserAgentFlow(with url: URL) -> Bool {
        do { try resumeExternalUserAgentFlow(url); return true } catch { return false }
    }
    func resumeExternalUserAgentFlow(_ url: URL) throws {
        resumes += 1
        if let rejection { throw rejection }
    }
    func failExternalUserAgentFlowWithError(_ error: any Error) { failed = error as NSError }
}

@Test @MainActor func rejectedBrowserCallbackFailsFlowAndNeverLogsItsURLOrErrorDescription() {
    let probe = BrowserSessionProbe()
    probe.rejection = NSError(domain: "org.openid.appauth.general", code: -16,
                              userInfo: [NSLocalizedDescriptionKey: "synthetic-private-code"])
    var reports: [String] = []
    let callback = MicrosoftBrowserCallback(session: probe) { reports.append($0) }
    let url = URL(string: "unregistered://return?code=synthetic-private-code&state=synthetic-private-state")!
    #expect(throws: NSError.self) { try callback.resumeExternalUserAgentFlow(url) }
    #expect(probe.resumes == 1)
    #expect(probe.failed?.domain == probe.rejection?.domain)
    #expect(probe.failed?.code == -16)
    #expect(reports.contains(where: { $0.contains("rejected") && $0.contains("-16") }))
    #expect(!reports.joined().contains("synthetic-private"))
    #expect(!reports.joined().contains("unregistered://"))
}

@Test @MainActor func acceptedBrowserCallbackAndCancellationReachTheOwningSDKSession() throws {
    let probe = BrowserSessionProbe()
    var reports: [String] = []
    let callback = MicrosoftBrowserCallback(session: probe) { reports.append($0) }
    try callback.resumeExternalUserAgentFlow(URL(string: "synthetic://return")!)
    #expect(probe.resumes == 1)
    #expect(probe.failed == nil)
    #expect(reports.last == "AppAuth consumed the system browser callback.")
    callback.cancel(completion: nil)
    #expect(probe.cancellations == 1)
}
