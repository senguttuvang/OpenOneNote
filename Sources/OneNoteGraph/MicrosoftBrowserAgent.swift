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

    nonisolated func dismiss(animated: Bool, completion: @escaping @Sendable () -> Void) {
        onMicrosoftMainActor {
            self.browser.dismiss(animated: animated, completion: completion)
            self.callback = nil
        }
    }
}

@MainActor final class MicrosoftBrowserCallback: NSObject, OIDExternalUserAgentSession {
    private weak var session: (any OIDExternalUserAgentSession)?
    private let report: (String) -> Void
    init(session: any OIDExternalUserAgentSession, report: @escaping (String) -> Void) {
        self.session = session; self.report = report
    }
    nonisolated func cancel() { onMicrosoftMainActor { self.session?.cancel() } }
    nonisolated func cancel(completion: (@Sendable () -> Void)?) {
        onMicrosoftMainActor {
            if let session = self.session { session.cancel(completion: completion) } else { completion?() }
        }
    }
    nonisolated func resumeExternalUserAgentFlow(with url: URL) -> Bool {
        onMicrosoftMainActor {
            guard self.session != nil else { return false }
            do { try self.resumeOnMainActor(url); return true } catch { return false }
        }
    }
    nonisolated func resumeExternalUserAgentFlow(_ url: URL) throws {
        try onMicrosoftMainActor { try self.resumeOnMainActor(url) }
    }
    private func resumeOnMainActor(_ url: URL) throws {
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
    nonisolated func failExternalUserAgentFlowWithError(_ error: any Error) {
        onMicrosoftMainActor {
            self.report("System authentication session failed before a validated callback.")
            self.session?.failExternalUserAgentFlowWithError(error)
        }
    }
}

/// AppAuth's Objective-C browser completion can arrive off-main and requires a synchronous reply.
/// Hop before entering actor-isolated code, including the SDK's synchronous dismissal callback.
private func onMicrosoftMainActor<T: Sendable>(_ action: @MainActor @Sendable () throws -> T) rethrows -> T {
    if Thread.isMainThread { return try MainActor.assumeIsolated(action) }
    return try DispatchQueue.main.sync { try MainActor.assumeIsolated(action) }
}
