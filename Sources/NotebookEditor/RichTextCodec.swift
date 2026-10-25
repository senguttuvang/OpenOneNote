import AppKit

public enum RichTextCodec {
    public static func decode(_ data: Data) throws -> NSAttributedString {
        guard data.starts(with: Data("{\\rtf".utf8)) else { throw CocoaError(.coderReadCorrupt) }
        return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
    }

    public static func encode(_ value: NSAttributedString) throws -> Data {
        try value.data(from: NSRange(location: 0, length: value.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
    }
}
