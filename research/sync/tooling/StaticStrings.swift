import Foundation
import CryptoKit

// Static bundle bytes only. Output file offsets are not loaded virtual addresses.
let fm = FileManager.default
let binary = URL(fileURLWithPath: "scratch/sync/csi-analysis/MicrosoftCSI-arm64")
let bytes = [UInt8](try Data(contentsOf: binary))
let terms = ["cellstorage.svc", "_vti_bin", "getchangessincetoken", "querychanges", "putchanges", "coherency", "websocket", "longpoll", "retry-after", "notification", "fsshttp", "application/x-fsshttp", "http://", "https://", "debounce", "dirty"]
var matches: Set<String> = []
@MainActor func emit(_ offset: Int, _ data: [UInt8], encoding: String) {
    guard data.count >= 6, data.count <= 1000, let text = String(bytes: data, encoding: .ascii), terms.contains(where: text.lowercased().contains) else { return }
    // Exclude query material even for static example URLs.
    let safe = text.components(separatedBy: "?").first!
    matches.insert(String(format: "0x%08x", offset) + "\t" + encoding + "\t" + safe)
}
var start = 0
for index in 0...bytes.count {
    let printable = index < bytes.count && bytes[index] >= 32 && bytes[index] <= 126
    if !printable {
        if index - start >= 6 { emit(start, Array(bytes[start..<index]), encoding: "ascii") }
        start = index + 1
    }
}
for alignment in 0...1 {
    var data: [UInt8] = [], beginning = alignment
    for index in stride(from: alignment, to: bytes.count - 1, by: 2) {
        if bytes[index] >= 32 && bytes[index] <= 126 && bytes[index + 1] == 0 {
            if data.isEmpty { beginning = index }
            data.append(bytes[index])
        } else {
            emit(beginning, data, encoding: "utf16le-ascii-subset")
            data.removeAll(keepingCapacity: true)
        }
    }
}
print("offset\tencoding\tstaticLiteral")
for match in matches.sorted() { print(match) }
