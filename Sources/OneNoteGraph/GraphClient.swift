import Foundation
import MarkdownNotes

public protocol GraphAuthorization: Sendable {
    func accessToken() async throws -> String
    func identityKey() async throws -> String
}
public struct GraphResponse: Sendable {
    public var data: Data
    public var status: Int
    public var retryAfter: String?
    public init(data: Data, status: Int, retryAfter: String? = nil) { self.data = data; self.status = status; self.retryAfter = retryAfter }
}
public protocol GraphTransport: Sendable {
    func send(_ request: URLRequest) async throws -> GraphResponse
}
public struct GraphRetryRequired: Error, LocalizedError, Sendable {
    public let status: Int
    public let delay: TimeInterval
    public var errorDescription: String? { "Microsoft Graph requested a retry after \(String(format: "%.0f", delay.rounded(.up))) seconds. Local notes are retained." }
}
public final class URLSessionGraphTransport: NSObject, GraphTransport, URLSessionTaskDelegate, Sendable {
    public override init() {}
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse,
                           newRequest request: URLRequest, completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        completionHandler(nil) // Never forward delegated authorization to a redirect.
    }
    public func send(_ request: URLRequest) async throws -> GraphResponse {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpCookieStorage = nil; configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 60
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        defer { session.invalidateAndCancel() }
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else { throw NotesError.invalid("Invalid Graph response") }
        guard data.count <= 24 * 1024 * 1024 else { throw NotesError.invalid("Graph response exceeds 24 MiB") }
        return GraphResponse(data: data, status: response.statusCode, retryAfter: response.value(forHTTPHeaderField: "Retry-After"))
    }
}

public struct GraphClient: OneNoteRemote, Sendable {
    public let authorization: any GraphAuthorization
    public let transport: any GraphTransport
    public init(authorization: any GraphAuthorization, transport: any GraphTransport = URLSessionGraphTransport()) {
        self.authorization = authorization; self.transport = transport
    }
    public static func validate(_ url: URL) throws {
        guard url.scheme == "https", url.host == "graph.microsoft.com", url.port == nil,
              url.user == nil, url.password == nil, url.fragment == nil, url.path.hasPrefix("/v1.0/"),
              !(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []).contains(where: {
                  ["access_token", "token", "sig", "auth", "code"].contains($0.name.lowercased())
              }) else { throw NotesError.invalid("Untrusted Graph URL") }
    }
    public static func component(_ value: String) throws -> String {
        guard !value.isEmpty, value != ".", value != "..", !value.contains("/"), !value.contains("\\"), !value.contains(where: \.isNewline) else { throw NotesError.invalid("Invalid Graph identifier") }
        return value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
    }
    public func url(root: String, path: String) throws -> URL {
        let pieces = root.split(separator: "/", omittingEmptySubsequences: false)
        guard root == "me" || (pieces.count == 2 && ["users", "sites", "groups"].contains(String(pieces[0]))) else { throw NotesError.invalid("Choose me, users/id, groups/id or sites/id") }
        let encoded = try pieces.map { try Self.component(String($0)) }.joined(separator: "/")
        guard let url = URL(string: "https://graph.microsoft.com/v1.0/\(encoded)/onenote/\(path)") else { throw NotesError.invalid("Invalid Graph path") }
        try Self.validate(url); return url
    }
    public static func retryDelay(_ value: String?, now: Date = Date()) -> TimeInterval? {
        guard let value else { return nil }
        if let seconds = Double(value), seconds.isFinite, seconds >= 0 { return seconds }
        let format = DateFormatter(); format.locale = Locale(identifier: "en_US_POSIX"); format.timeZone = TimeZone(secondsFromGMT: 0)
        format.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return format.date(from: value).map { max(0, $0.timeIntervalSince(now)) }
    }
    public func request(_ url: URL, method: String = "GET", body: Data? = nil, contentType: String = "application/json") async throws -> Data {
        try Self.validate(url)
        for attempt in 0..<4 {
            try Task.checkCancellation()
            var request = URLRequest(url: url); request.httpMethod = method; request.httpBody = body; request.timeoutInterval = 60
            request.setValue("Bearer " + (try await authorization.accessToken()), forHTTPHeaderField: "Authorization")
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            let response = try await transport.send(request)
            if (200..<300).contains(response.status) { return response.data }
            if response.status == 401 { throw NotesError.authenticationRequired }
            // Writes are never blindly retried after an ambiguous response or timeout.
            if method == "GET", [429, 503].contains(response.status) {
                let delay = Self.retryDelay(response.retryAfter) ?? pow(2, Double(attempt))
                guard delay <= 120, attempt < 3 else { throw GraphRetryRequired(status: response.status, delay: delay) }
                try await Task.sleep(for: .seconds(delay)); continue
            }
            throw NotesError.http(response.status)
        }
        throw NotesError.invalid("Retry budget exhausted")
    }
    public func list(root: String, path: String) async throws -> [GraphItem] {
        struct Page: Decodable { var value: [GraphItem]; var next: String?; enum CodingKeys: String, CodingKey { case value; case next = "@odata.nextLink" } }
        let initial = try url(root: root, path: path)
        var next: URL? = initial; var seen: Set<URL> = []; var result: [GraphItem] = []
        while let current = next {
            guard seen.insert(current).inserted, seen.count <= 1000 else { throw NotesError.invalid("Pagination loop or page limit") }
            let page = try JSONDecoder().decode(Page.self, from: await request(current))
            result += page.value
            if let link = page.next {
                guard let value = URL(string: link) else { throw NotesError.invalid("Invalid nextLink") }
                try Self.validate(value)
                guard value.path == initial.path else { throw NotesError.invalid("Pagination left the selected Graph collection") }
                next = value
            } else { next = nil }
        }
        return result
    }
    public func sections(root: String, notebookID: String) async throws -> [GraphItem] {
        let notebook = try Self.component(notebookID)
        var result = try await list(root: root, path: "notebooks/\(notebook)/sections")
        var queue = try await list(root: root, path: "notebooks/\(notebook)/sectionGroups").map { ($0, $0.name) }
        var seen: Set<String> = []
        while !queue.isEmpty {
            let (group, prefix) = queue.removeFirst()
            guard seen.insert(group.id).inserted, seen.count <= 1000 else { throw NotesError.invalid("Section group cycle or traversal limit") }
            let groupID = try Self.component(group.id)
            let children = try await list(root: root, path: "sectionGroups/\(groupID)/sections")
            result += children.map { GraphItem(id: $0.id, displayName: prefix + " / " + $0.name) }
            let groups = try await list(root: root, path: "sectionGroups/\(groupID)/sectionGroups")
            queue += groups.map { ($0, prefix + " / " + $0.name) }
        }
        return result
    }
    public func fetch(_ identity: PageIdentity) async throws -> RemotePage {
        try await verifyIdentity(identity)
        let page = try Self.component(identity.pageID)
        struct Metadata: Decodable { var id: String; var title: String }
        let metadata = try JSONDecoder().decode(Metadata.self, from: await request(url(root: identity.root, path: "pages/\(page)")))
        let data = try await request(url(root: identity.root, path: "pages/\(page)/content?includeIDs=true"))
        guard metadata.id == identity.pageID, let html = String(data: data, encoding: .utf8) else { throw NotesError.invalid("Page identity or encoding mismatch") }
        return RemotePage(id: metadata.id, title: metadata.title, html: html)
    }
    public func modificationHint(_ identity: PageIdentity) async throws -> String? {
        try await verifyIdentity(identity)
        struct Metadata: Decodable { var id: String; var lastModifiedDateTime: String? }
        let path = "pages/\(try Self.component(identity.pageID))?$select=id,lastModifiedDateTime"
        let value = try JSONDecoder().decode(Metadata.self, from: await request(url(root: identity.root, path: path)))
        guard value.id == identity.pageID else { throw NotesError.invalid("Page metadata identity mismatch") }
        return value.lastModifiedDateTime
    }
    public func resource(_ url: URL) async throws -> Data {
        try Self.validate(url)
        guard url.path.contains("/onenote/resources/"), url.path.hasSuffix("/$value") else { throw NotesError.invalid("Not a OneNote resource endpoint") }
        return try await request(url)
    }
    public func update(_ identity: PageIdentity, commands: [PageCommand], parts: [BinaryPart]) async throws {
        try await verifyIdentity(identity)
        guard !commands.isEmpty else { return }
        let endpoint = try url(root: identity.root, path: "pages/\(Self.component(identity.pageID))/content")
        if parts.isEmpty {
            _ = try await request(endpoint, method: "PATCH", body: JSONEncoder().encode(commands))
        } else {
            let boundary = "O2N-" + UUID().uuidString
            let body = try Self.multipart(commands: commands, parts: parts, boundary: boundary)
            _ = try await request(endpoint, method: "PATCH", body: body, contentType: "multipart/form-data; boundary=\(boundary)")
        }
    }
    private func verifyIdentity(_ identity: PageIdentity) async throws {
        guard let key = identity.accountKey, try await authorization.identityKey() == key else { throw NotesError.authenticationRequired }
    }
    public static func multipart(commands: [PageCommand], parts: [BinaryPart], boundary: String) throws -> Data {
        guard boundary.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" }) else { throw NotesError.invalid("Invalid multipart boundary") }
        var body = Data()
        func append(_ value: String) { body.append(Data(value.utf8)) }
        append("--\(boundary)\r\nContent-Disposition: form-data; name=\"Commands\"\r\nContent-Type: application/json\r\n\r\n")
        body.append(try JSONEncoder().encode(commands)); append("\r\n")
        for part in parts {
            guard part.name.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" }), !part.name.isEmpty,
                  !part.mimeType.contains(where: \.isNewline), part.bytes.count <= 20 * 1024 * 1024 else { throw NotesError.invalid("Invalid binary part") }
            append("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(part.name)\"\r\nContent-Type: \(part.mimeType)\r\n\r\n")
            body.append(part.bytes); append("\r\n")
        }
        append("--\(boundary)--\r\n"); return body
    }
}
