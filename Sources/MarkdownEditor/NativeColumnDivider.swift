import AppKit
import SwiftUI

struct NativeColumnDivider: View {
    @Binding var width: Double
    let bounds: ClosedRange<Double>
    let title: String
    @State private var origin: Double?
    var body: some View {
        Rectangle().fill(Color.primary.opacity(0.3)).frame(width: 1)
            .overlay {
                Color.clear.frame(width: 7).contentShape(Rectangle())
                    .gesture(DragGesture(minimumDistance: 1).onChanged { value in
                        if origin == nil { origin = width }
                        width = min(bounds.upperBound, max(bounds.lowerBound, (origin ?? width) + value.translation.width))
                    }.onEnded { _ in origin = nil })
                    .onHover { if $0 { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() } }
            }
            .accessibilityElement().accessibilityLabel(title).accessibilityValue("\(Int(width)) points")
            .accessibilityAdjustableAction { direction in
                width = min(bounds.upperBound, max(bounds.lowerBound, width + (direction == .increment ? 20 : -20)))
            }
    }
}
