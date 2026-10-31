import AppKit
import SwiftUI

struct MermaidPreview: View {
    let source: String
    @State private var png: Data?
    @State private var failure: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let png, let image = NSImage(data: png) { Image(nsImage: image).resizable().scaledToFit().accessibilityLabel("Rendered Mermaid diagram") }
            else if let failure { Label(failure, systemImage: "exclamationmark.triangle").foregroundStyle(.orange) }
            else { ProgressView("Rendering diagram locally…") }
        }.task(id: source) {
            png = nil; failure = nil
            do {
                let rendered = try await MermaidRenderer().png(source: source)
                try Task.checkCancellation(); png = rendered
            }
            catch is CancellationError { return }
            catch { failure = "Diagram render failed. Source retained: " + error.localizedDescription }
        }
    }
}
