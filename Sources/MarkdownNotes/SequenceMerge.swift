import Foundation

public enum SequenceMerge {
    public struct Edit<Element: Equatable & Sendable>: Sendable {
        public let range: Range<Int>
        public let replacement: [Element]
    }
    /// LCS-based changed ranges. Bounds prevent unbounded quadratic work on hostile pages.
    public static func edits<T: Equatable & Sendable>(base: [T], changed: [T]) -> [Edit<T>] {
        guard base != changed else { return [] }
        guard base.count <= 1000, changed.count <= 1000 else {
            return [Edit(range: 0..<base.count, replacement: changed)]
        }
        var matrix = Array(repeating: Array(repeating: 0, count: changed.count + 1), count: base.count + 1)
        for i in base.indices.reversed() {
            for j in changed.indices.reversed() {
                matrix[i][j] = base[i] == changed[j] ? matrix[i + 1][j + 1] + 1 : max(matrix[i + 1][j], matrix[i][j + 1])
            }
        }
        var i = 0; var j = 0; var result: [Edit<T>] = []
        var start: Int?; var replacement: [T] = []
        func flush() {
            if let lower = start { result.append(Edit(range: lower..<i, replacement: replacement)) }
            start = nil; replacement = []
        }
        while i < base.count || j < changed.count {
            if i < base.count && j < changed.count && base[i] == changed[j] { flush(); i += 1; j += 1 }
            else if j < changed.count && (i == base.count || matrix[i][j + 1] >= matrix[i + 1][j]) {
                if start == nil { start = i }; replacement.append(changed[j]); j += 1
            } else { if start == nil { start = i }; i += 1 }
        }
        flush(); return result
    }
    public static func merge<T: Equatable & Sendable>(base: [T], local: [T], remote: [T]) throws -> [T] {
        if local == remote { return local }
        if local == base { return remote }
        if remote == base { return local }
        let localEdits = edits(base: base, changed: local)
        let remoteEdits = edits(base: base, changed: remote)
        for lhs in localEdits {
            for rhs in remoteEdits {
                if lhs.range == rhs.range && lhs.replacement == rhs.replacement { continue }
                let touchesInsertion = (lhs.range.isEmpty && rhs.range.contains(lhs.range.lowerBound)) ||
                    (rhs.range.isEmpty && lhs.range.contains(rhs.range.lowerBound)) ||
                    (lhs.range.isEmpty && rhs.range.isEmpty && lhs.range.lowerBound == rhs.range.lowerBound)
                if lhs.range.overlaps(rhs.range) || touchesInsertion { throw NotesError.conflict }
            }
        }
        var result = base
        var edits = localEdits
        for edit in remoteEdits where !localEdits.contains(where: { $0.range == edit.range && $0.replacement == edit.replacement }) { edits.append(edit) }
        for edit in edits.sorted(by: { $0.range.lowerBound > $1.range.lowerBound }) { result.replaceSubrange(edit.range, with: edit.replacement) }
        return result
    }
}
