import AppKit
import Foundation
import Security

extension DevelopmentWorkflow {
    public func buildApp() throws {
        try run("swift", ["build", "-c", "release", "--product", "OpenOneNoteMac", "--jobs", "2"])
        let bin = try releaseDirectory()
        let app = root.appendingPathComponent("dist/OpenOneNote.app")
        if FileManager.default.fileExists(atPath: app.path) {
            guard Bundle(url: app)?.bundleIdentifier == "dev.senguttuvang.OpenOneNote",
                  !NSWorkspace.shared.runningApplications.contains(where: { $0.bundleURL?.standardizedFileURL == app.standardizedFileURL }) else {
                throw DevelopmentError.invalidArguments("Existing app is not an inactive OpenOneNote build; preserve it and choose a clean build directory")
            }
            try FileManager.default.removeItem(at: app)
        }
        let contents = app.appendingPathComponent("Contents")
        let resources = contents.appendingPathComponent("Resources")
        try FileManager.default.createDirectory(at: contents.appendingPathComponent("MacOS"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: resources, withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: bin.appendingPathComponent("OpenOneNoteMac"), to: contents.appendingPathComponent("MacOS/OpenOneNoteMac"))
        try FileManager.default.copyItem(at: bin.appendingPathComponent("OpenOneNote_MarkdownEditor.bundle"), to: resources.appendingPathComponent("OpenOneNote_MarkdownEditor.bundle"))
        for name in ["AppAuth_AppAuth.bundle", "AppAuth_AppAuthCore.bundle"] {
            try FileManager.default.copyItem(at: bin.appendingPathComponent(name), to: resources.appendingPathComponent(name))
        }
        let executable = contents.appendingPathComponent("MacOS/OpenOneNoteMac")
        let loadCommands = try run("otool", ["-l", executable.path], capture: true).stdout
        for line in loadCommands.components(separatedBy: "\n") {
            let value = line.trimmingCharacters(in: .whitespaces)
            if value.hasPrefix("path "), value.contains("/.build/"), let path = value.dropFirst(5).components(separatedBy: " (offset").first {
                try run("install_name_tool", ["-delete_rpath", path, executable.path])
            }
        }
        let notices = resources.appendingPathComponent("Licenses")
        try FileManager.default.createDirectory(at: notices, withIntermediateDirectories: true)
        for (source, name) in [
            (".build/checkouts/swift-markdown/LICENSE.txt", "Swift-Markdown.txt"),
            (".build/checkouts/swift-cmark/COPYING", "cmark.txt"),
            (".build/checkouts/SwiftSoup/LICENSE", "SwiftSoup.txt"),
            (".build/checkouts/AppAuth-iOS/LICENSE", "AppAuth.txt"),
            ("Sources/MarkdownEditor/Resources/Mermaid/LICENSE", "Mermaid.txt")
        ] { try FileManager.default.copyItem(at: root.appendingPathComponent(source), to: notices.appendingPathComponent(name)) }
        let plist: [String: Any] = [
            "CFBundleName": "OpenOneNote", "CFBundleDisplayName": "OpenOneNote", "CFBundleIdentifier": "dev.senguttuvang.OpenOneNote",
            "CFBundleExecutable": "OpenOneNoteMac", "CFBundlePackageType": "APPL", "CFBundleShortVersionString": "0.3.0",
            "CFBundleVersion": "4", "CFBundleIconFile": "AppIcon", "LSMinimumSystemVersion": "14.0",
            "NSHighResolutionCapable": true, "NSPrincipalClass": "NSApplication"
        ]
        var appPlist = plist
        appPlist["CFBundleURLTypes"] = [["CFBundleURLName": "O2N Microsoft sign-in", "CFBundleURLSchemes": ["msauth.dev.senguttuvang.OpenOneNote"]]]
        try PropertyListSerialization.data(fromPropertyList: appPlist, format: .xml, options: 0).write(to: contents.appendingPathComponent("Info.plist"))
        let iconset = root.appendingPathComponent("scratch/AppIcon.iconset")
        try AppIcon.write(to: iconset)
        try run("iconutil", ["-c", "icns", iconset.path, "-o", resources.appendingPathComponent("AppIcon.icns").path])
        let revision = try run("git", ["rev-parse", "HEAD"], capture: true).stdout
        let dirty = try run("git", ["status", "--porcelain", "--", "Package.swift", "Package.resolved", "Sources"], capture: true).stdout
        let metadata = ["sourceRevision": revision, "sourceState": dirty.isEmpty ? "committed" : "working-tree",
                        "architecture": try run("uname", ["-m"], capture: true).stdout,
                        "signingMode": (ProcessInfo.processInfo.environment["O2N_SIGNING_IDENTITY"] ?? "-") == "-" ? "ad-hoc; app-private macOS Keychain; no shared entitlement" : "developer identity; app-private macOS Keychain",
                        "scope": "Markdown vault editor with delegated Graph same-page sync; see build verification for live evidence"]
        try JSONSerialization.data(withJSONObject: metadata, options: [.prettyPrinted, .sortedKeys]).write(to: resources.appendingPathComponent("build.json"))
        let identity = ProcessInfo.processInfo.environment["O2N_SIGNING_IDENTITY"] ?? "-"
        try run("codesign", ["--force", "--sign", identity, "--timestamp=none", app.path])
        try run("codesign", ["--verify", "--deep", "--strict", app.path])
        print("Built \(app.path)")
    }

    public func packageApp() throws {
        let dirty = try run("git", ["status", "--porcelain", "--", "Package.swift", "Package.resolved", "Sources"], capture: true).stdout
        guard dirty.isEmpty else { throw DevelopmentError.uncommittedSource }
        try buildApp()
        let revision = try run("git", ["rev-parse", "--short", "HEAD"], capture: true).stdout
        try DevelopmentWorkflow.validateLabel(revision)
        let architecture = try run("uname", ["-m"], capture: true).stdout
        try archive(root.appendingPathComponent("dist/OpenOneNote.app"), to: root.appendingPathComponent("artifacts/native/openonenote-app-\(architecture)-\(revision).tar.gz"))
    }

    public func verifyApp() throws {
        let app = root.appendingPathComponent("dist/OpenOneNote.app")
        try run("codesign", ["--verify", "--deep", "--strict", app.path])
        let binary = app.appendingPathComponent("Contents/MacOS/OpenOneNoteMac").path
        let fixture = root.appendingPathComponent("scratch/bundle-verification-\(UUID())/notebook.json")
        try run(binary, ["--self-test", fixture.path])
        try run(binary, ["--markdown-self-test", fixture.deletingLastPathComponent().appendingPathComponent("markdown").path])
        try run(binary, ["--diagram-self-test", fixture.deletingLastPathComponent().appendingPathComponent("diagrams").path])
        let previews = root.appendingPathComponent("artifacts/previews")
        try FileManager.default.createDirectory(at: previews, withIntermediateDirectories: true)
        for width in [1728, 1280, 960] {
            try run(binary, ["--render-preview", previews.appendingPathComponent("native-\(width).png").path, "\(width)"])
        }
        let metadata = try Data(contentsOf: app.appendingPathComponent("Contents/Resources/build.json"))
        var verification = try JSONSerialization.jsonObject(with: metadata) as? [String: String] ?? [:]
        let capability = try run(binary, ["--signing-status"], allowFailure: true)
        let adHoc = verification["signingMode"]?.hasPrefix("ad-hoc") == true
        guard capability.exitCode == 0 else { throw DevelopmentError.invalidArguments("Packaged executable signature verification failed") }
        verification["nativeCredentialCache"] = "AppAuth secure archive in app-private macOS Keychain; actual persistence and human sign-in remain separate live checks"
        verification["signature"] = adHoc ? "Ad-hoc deep/strict verification passed" : "Developer deep/strict verification passed"
        verification["nativeEditing"] = "Packaged binary: legacy rich text and Markdown source edit/undo/redo/save/reopen passed"
        verification["diagrams"] = "Bundled offline Mermaid PNG, preview and malformed-source rejection passed"
        verification["renderScope"] = "Real native views in hidden windows at 1728x1088, 1280x800 and 960x800; one pixel per point; prohibited activation policy"
        verification["limits"] = "No full desktop keyboard/VoiceOver automation or Microsoft OneNote parity claim"
        try JSONSerialization.data(withJSONObject: verification, options: [.prettyPrinted, .sortedKeys]).write(to: previews.appendingPathComponent("verification.json"))
        print("Verified app and saved native previews to \(previews.path)")
    }

    public func packageTools() throws {
        guard try run("git", ["status", "--porcelain", "--", "Package.swift", "Package.resolved", "Sources"], capture: true).stdout.isEmpty else { throw DevelopmentError.uncommittedSource }
        try build()
        let revision = try run("git", ["rev-parse", "--short", "HEAD"], capture: true).stdout
        try DevelopmentWorkflow.validateLabel(revision)
        let architecture = try run("uname", ["-m"], capture: true).stdout
        let directory = root.appendingPathComponent("scratch/openonenote-tools-\(architecture)-\(revision)")
        guard !FileManager.default.fileExists(atPath: directory.path) else { throw DevelopmentError.outputExists(directory.path) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let bin = try releaseDirectory()
        var checksums = ""
        for name in ["openonenote", "onenote-research", "openonenote-dev"] {
            let copy = directory.appendingPathComponent(name)
            try FileManager.default.copyItem(at: bin.appendingPathComponent(name), to: copy)
            checksums += "\(try digest(copy))  \(name)\n"
        }
        try Data(checksums.utf8).write(to: directory.appendingPathComponent("SHA256SUMS"))
        try Data(revision.utf8).write(to: directory.appendingPathComponent("SOURCE_REVISION"))
        try archive(directory, to: root.appendingPathComponent("artifacts/native/\(directory.lastPathComponent).tar.gz"))
    }
}

@MainActor private enum AppIcon {
    static func write(to directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for (points, scale) in [(16,1),(16,2),(32,1),(32,2),(128,1),(128,2),(256,1),(256,2),(512,1),(512,2)] {
            let pixels = points * scale
            guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
                samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
                  let context = NSGraphicsContext(bitmapImageRep: bitmap) else { throw CocoaError(.fileWriteUnknown) }
            NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = context
            context.cgContext.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
            NSColor(red: 0.031, green: 0.471, blue: 0.710, alpha: 1).setFill()
            NSBezierPath(roundedRect: NSRect(x: 60, y: 60, width: 904, height: 904), xRadius: 200, yRadius: 200).fill()
            NSColor.white.setFill(); NSBezierPath(roundedRect: NSRect(x: 254, y: 205, width: 516, height: 614), xRadius: 44, yRadius: 44).fill()
            NSColor(red: 0.894, green: 0.949, blue: 1, alpha: 1).setFill()
            NSBezierPath(rect: NSRect(x: 300, y: 235, width: 42, height: 552)).fill()
            NSColor(red: 0.031, green: 0.471, blue: 0.710, alpha: 1).setFill()
            for y in [610, 510, 410] { NSBezierPath(roundedRect: NSRect(x: 402, y: y, width: 260, height: 28), xRadius: 14, yRadius: 14).fill() }
            NSColor(red: 0.72, green: 0.64, blue: 0.94, alpha: 1).setFill()
            NSBezierPath(roundedRect: NSRect(x: 628, y: 674, width: 70, height: 145), xRadius: 12, yRadius: 12).fill()
            NSGraphicsContext.restoreGraphicsState()
            guard let png = bitmap.representation(using: .png, properties: [:]) else { throw CocoaError(.fileWriteUnknown) }
            try png.write(to: directory.appendingPathComponent("icon_\(points)x\(points)\(scale == 2 ? "@2x" : "").png"))
        }
    }
}
