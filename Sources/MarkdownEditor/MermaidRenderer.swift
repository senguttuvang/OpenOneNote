import AppKit
import WebKit
import MarkdownNotes

/// Bundled Mermaid executes locally with CSP and WebKit rules blocking network requests.
@MainActor public final class MermaidRenderer: NSObject, DiagramRendering, WKNavigationDelegate {
    private static let cache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>(); cache.countLimit = 16; cache.totalCostLimit = 16 * 1024 * 1024; return cache
    }()
    public override init() {}
    public func png(source: String) async throws -> Data {
        guard source.utf8.count <= 128 * 1024 else { throw NotesError.invalid("Diagram source exceeds 128 KiB") }
        let cacheKey = MarkdownVault.hash(source) as NSString
        if let cached = Self.cache.object(forKey: cacheKey) { return cached as Data }
        guard let path = Bundle.module.url(forResource: "mermaid.min", withExtension: "js", subdirectory: "Mermaid") else {
            throw NotesError.invalid("Bundled Mermaid renderer is missing")
        }
        let library = try String(contentsOf: path, encoding: .utf8)
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let rules = """
        [{"trigger":{"url-filter":"^http"},"action":{"type":"block"}},{"trigger":{"url-filter":"^ws"},"action":{"type":"block"}}]
        """
        let rule: WKContentRuleList = try await withCheckedThrowingContinuation { continuation in
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "O2N-NoNetwork-v1", encodedContentRuleList: rules) { rule, error in
                if let rule { continuation.resume(returning: rule) }
                else { continuation.resume(throwing: error ?? NotesError.invalid("Cannot enforce diagram network boundary")) }
            }
        }
        configuration.userContentController.add(rule)
        let web = WKWebView(frame: NSRect(x: 0, y: 0, width: 1000, height: 800), configuration: configuration)
        web.navigationDelegate = self
        let window = NSWindow(contentRect: web.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = web
        defer { web.stopLoading(); window.contentView = nil }
        web.loadHTMLString("""
        <!doctype html><html><head><meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline' 'unsafe-eval'; style-src 'unsafe-inline'; img-src data: blob:; font-src data:; connect-src 'none'"><style>body{margin:0;background:white;color:#18324f}svg{display:block}</style></head><body></body></html>
        """, baseURL: nil)
        let deadline = Date().addingTimeInterval(15)
        while web.isLoading {
            guard Date() < deadline else { throw NotesError.invalid("Diagram renderer load timed out") }
            try await Task.sleep(for: .milliseconds(20))
        }
        _ = try await web.evaluateJavaScript(library + "\n;null;")
        let dimensions = try await web.callAsyncJavaScript("""
        mermaid.initialize({startOnLoad:false,securityLevel:'strict',theme:'default',maxTextSize:131072,maxEdges:500,secure:['securityLevel','startOnLoad','maxTextSize','maxEdges'],flowchart:{htmlLabels:false},fontFamily:'Helvetica'});
        const result = await mermaid.render('o2nDiagram', source);
        document.body.innerHTML = result.svg;
        const svg = document.querySelector('svg');
        const box = svg.viewBox.baseVal;
        const width = Math.min(1600, Math.max(200, Math.ceil(box.width)));
        const height = Math.min(4000, Math.max(100, Math.ceil(box.height * width / box.width)));
        if (!Number.isFinite(width) || !Number.isFinite(height)) throw new Error('Invalid diagram bounds');
        svg.setAttribute('width', width); svg.setAttribute('height', height); svg.style.maxWidth='none';
        return [width,height];
        """, arguments: ["source": source], in: nil, contentWorld: .page)
        guard let dimensions = dimensions as? [Double], dimensions.count == 2 else { throw NotesError.invalid("Invalid rendered diagram dimensions") }
        web.frame = NSRect(x: 0, y: 0, width: dimensions[0], height: dimensions[1])
        window.setContentSize(web.frame.size)
        try await Task.sleep(for: .milliseconds(100))
        let snapshot = WKSnapshotConfiguration(); snapshot.rect = web.bounds
        let image = try await web.takeSnapshot(configuration: snapshot)
        guard let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff),
              let data = bitmap.representation(using: .png, properties: [:]), !data.isEmpty else { throw NotesError.invalid("Cannot encode diagram PNG") }
        guard !window.isVisible else { throw NotesError.invalid("Diagram renderer unexpectedly showed a window") }
        Self.cache.setObject(data as NSData, forKey: cacheKey, cost: data.count)
        return data
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        decisionHandler(navigationAction.request.url?.absoluteString == "about:blank" ? .allow : .cancel)
    }
}
