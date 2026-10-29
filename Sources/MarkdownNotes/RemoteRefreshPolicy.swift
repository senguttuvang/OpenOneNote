import Foundation

/// Metadata is a freshness hint. Full content reconciliation is mandatory even when it is unchanged.
public struct RemoteRefreshPolicy: Sendable {
    public private(set) var interval: TimeInterval = 15
    public private(set) var notBefore = Date.distantPast
    private var lastContent = Date.distantPast
    private var lastHint: String?
    private var retryUntil = Date.distantPast
    public init() {}
    public mutating func selectedPageChanged() {
        interval = 15; lastContent = .distantPast; lastHint = nil
        notBefore = retryUntil
    }
    public func canRefresh(now: Date, force: Bool) -> Bool { now >= (force ? retryUntil : notBefore) }
    public func needsContent(hint: String?, now: Date, force: Bool = false) -> Bool {
        force || hint == nil || hint != lastHint || now.timeIntervalSince(lastContent) >= 120
    }
    public mutating func succeeded(hint: String?, contentChecked: Bool, changed: Bool, now: Date) {
        lastHint = hint
        if contentChecked { lastContent = now }
        interval = changed ? 15 : min(120, interval * 2)
        notBefore = min(now.addingTimeInterval(interval), lastContent.addingTimeInterval(120))
        retryUntil = .distantPast
    }
    public mutating func failed(now: Date, retryAfter: TimeInterval? = nil) {
        interval = min(300, max(30, interval * 2))
        notBefore = now.addingTimeInterval(max(interval, retryAfter ?? 0))
        retryUntil = notBefore
    }
}
