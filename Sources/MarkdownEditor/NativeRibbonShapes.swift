import SwiftUI

struct StrokeSample: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path(); path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.midY), control1: CGPoint(x: rect.width * 0.2, y: rect.minY), control2: CGPoint(x: rect.width * 0.25, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control1: CGPoint(x: rect.width * 0.8, y: rect.maxY), control2: CGPoint(x: rect.width * 0.8, y: rect.maxY))
        return path
    }
}

struct ShapeSample: Shape {
    let kind: Int
    func path(in r: CGRect) -> Path {
        var p = Path(); let left = r.minX + 1, right = r.maxX - 1, top = r.minY + 1, bottom = r.maxY - 1
        switch kind {
        case 0, 1, 2:
            p.move(to: CGPoint(x: left, y: top)); p.addLine(to: CGPoint(x: right, y: bottom))
            if kind > 0 { p.move(to: CGPoint(x: right - 7, y: bottom)); p.addLine(to: CGPoint(x: right, y: bottom)); p.addLine(to: CGPoint(x: right, y: bottom - 7)) }
            if kind == 2 { p.move(to: CGPoint(x: left + 7, y: top)); p.addLine(to: CGPoint(x: left, y: top)); p.addLine(to: CGPoint(x: left, y: top + 7)) }
        case 3, 4, 5:
            p.move(to: CGPoint(x: left, y: top)); p.addLine(to: CGPoint(x: right, y: top)); p.addLine(to: CGPoint(x: right, y: bottom))
            if kind > 3 { p.move(to: CGPoint(x: right - 5, y: bottom - 5)); p.addLine(to: CGPoint(x: right, y: bottom)); p.addLine(to: CGPoint(x: right + 1, y: bottom - 5)) }
            if kind == 5 { p.move(to: CGPoint(x: left + 5, y: top - 1)); p.addLine(to: CGPoint(x: left, y: top)); p.addLine(to: CGPoint(x: left + 5, y: top + 5)) }
        case 6: p.addRect(r.insetBy(dx: 1, dy: 1))
        case 7: p.addEllipse(in: r.insetBy(dx: 1, dy: 1))
        case 8:
            p.move(to: CGPoint(x: r.midX, y: top)); p.addLine(to: CGPoint(x: right, y: bottom)); p.addLine(to: CGPoint(x: left, y: bottom)); p.closeSubpath()
        case 9:
            p.move(to: CGPoint(x: left + 4, y: top)); p.addLine(to: CGPoint(x: right, y: top)); p.addLine(to: CGPoint(x: right - 4, y: bottom)); p.addLine(to: CGPoint(x: left, y: bottom)); p.closeSubpath()
        case 10:
            p.move(to: CGPoint(x: r.midX, y: top)); p.addLine(to: CGPoint(x: right, y: r.midY)); p.addLine(to: CGPoint(x: r.midX, y: bottom)); p.addLine(to: CGPoint(x: left, y: r.midY)); p.closeSubpath()
        default:
            let center = CGPoint(x: kind == 11 ? left : r.midX, y: kind == 11 ? bottom : r.midY)
            p.move(to: CGPoint(x: center.x, y: bottom)); p.addLine(to: CGPoint(x: center.x, y: top)); p.move(to: CGPoint(x: left, y: center.y)); p.addLine(to: CGPoint(x: right, y: center.y))
            if kind == 13 { p.move(to: center); p.addLine(to: CGPoint(x: right, y: bottom)) }
        }
        return p
    }
}
