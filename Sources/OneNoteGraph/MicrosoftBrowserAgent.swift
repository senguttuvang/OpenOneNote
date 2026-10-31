import AppKit
import Foundation
@preconcurrency import AppAuth

/// Keep AppAuth's system-browser adapter and validation, but surface a rejected browser return.
/// AppAuth's macOS adapter otherwise ignores the BOOL/error returned by resume.
@MainActor final class MicrosoftBrowserAgent: NSObject, @preconcurrency OIDExternalUserAgent {
    private let browser: OIDExternalUserAgentMac
    private let report: (String) -> Void
    private var callback: MicrosoftBrowserCallback?

    init(window: NSWindow, report: @escaping (String) -> Void) {
        browser = OIDExternalUserAgentMac(presenting: window)
        self.report = report
    }

    func present(_ request: any OIDExternalUserAgentRequest, session: any OIDExternalUserAgentSession) -> Bool {
        let callback = MicrosoftBrowserCallback(session: session, report: report)
        self.callback = callback
        let started = browser.present(request, session: callback)
        report("System authentication session started: \(started).")
        return started
    }

    func dismiss(animated: Bool, completion: @escaping @Sendable () -> Void) {
        browser.dismiss(animated: animated, completion: completion)
        callback = nil
    }
}

@MainActor final class MicrosoftBrowserCallback: NSObject, @preconcurrency OIDExternalUserAgentSession {
    private weak var session: (any OIDExternalUserAgentSession)?
    private let report: (String) -> Void
    init(session: any OIDExternalUserAgentSession, report: @escaping (String) -> Void) {
        self.session = session; self.report = report
    }
    func cancel() { session?.cancel() }
    func cancel(completion: (@Sendable () -> Void)?) {
        if let session { session.cancel(completion: completion) } else { completion?() }
    }
    func resumeExternalUserAgentFlow(with url: URL) -> Bool {
        guard session != nil else { return false }
        do { try resumeExternalUserAgentFlow(url); return true } catch { return false }
    }
    func resumeExternalUserAgentFlow(_ url: URL) throws {
        report("System browser returned a callback; validating with AppAuth.")
        guard let session else { return }
        do {
            try session.resumeExternalUserAgentFlow(url)
            report("AppAuth consumed the system browser callback.")
        } catch {
            let value = error as NSError
            report("AppAuth rejected the system browser callback (\(value.domain):\(value.code)).")
            session.failExternalUserAgentFlowWithError(error)
            throw error
        }
    }
    func failExternalUserAgentFlowWithError(_ error: any Error) {
        report("System authentication session failed before a validated callback.")
        session?.failExternalUserAgentFlowWithError(error)
    }
}
