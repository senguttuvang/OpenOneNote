import Foundation

extension DevelopmentWorkflow {
    public func decompileSample(bundle: URL, label: String, ghidra: URL) throws {
        try Self.validateLabel(label)
        let executable = bundle.appendingPathComponent("Contents/MacOS/Microsoft OneNote")
        guard try digest(executable) == "9b47f05110382560fafbccfa25ff716463fe7af9fec63da848546a26531733aa" else {
            throw DevelopmentError.invalidArguments("Sample addresses are pinned to OneNote 16.114.1; select addresses for the supplied build before decompiling")
        }
        guard FileManager.default.isExecutableFile(atPath: ghidra.path) else { throw DevelopmentError.invalidArguments("Ghidra analyzeHeadless executable not found") }
        let output = root.appendingPathComponent("research/decompiled/\(label)")
        guard !FileManager.default.fileExists(atPath: output.path) else { throw DevelopmentError.outputExists(output.path) }
        let project = root.appendingPathComponent("scratch/ghidra-\(label)")
        guard !FileManager.default.fileExists(atPath: project.path) else { throw DevelopmentError.outputExists(project.path) }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: project, withIntermediateDirectories: true)
        let thin = project.appendingPathComponent("onenote-arm64")
        try run("lipo", [executable.path, "-thin", "arm64", "-output", thin.path])
        try run(ghidra.path, [project.path, "OpenOneNote", "-import", thin.path, "-noanalysis", "-max-cpu", "2",
                              "-scriptPath", root.appendingPathComponent("Tools/ghidra").path, "-postScript", "ExportSelectedMethods.java", output.path,
                              "-log", output.appendingPathComponent("ghidra.log").path, "-scriptlog", output.appendingPathComponent("script.log").path])
        try archive(project, to: root.appendingPathComponent("research/originals/onenote-mac-\(label).ghidra-project.tar.gz"))
    }

    public func capture(bundle: URL, label: String) throws {
        try Self.validateLabel(label)
        let output = root.appendingPathComponent("research/extracted/\(label)")
        guard !FileManager.default.fileExists(atPath: output.path) else { throw DevelopmentError.outputExists(output.path) }
        try run("swift", ["build", "-c", "release", "--product", "onenote-research", "--jobs", "2"])
        let research = try releaseDirectory().appendingPathComponent("onenote-research")
        try run(research.path, ["capture", bundle.path, output.path])
        try additional(bundle: bundle, output: output.appendingPathComponent("additional"), label: label)
        try archive(bundle, to: root.appendingPathComponent("research/originals/onenote-mac-\(label).app.tar.gz"))
        try archive(bundle.appendingPathComponent("Contents/Resources"), to: root.appendingPathComponent("research/originals/onenote-mac-\(label).resources.tar.gz"))
    }

    public func additional(bundle: URL, output: URL, label: String) throws {
        try Self.validateLabel(label)
        guard !FileManager.default.fileExists(atPath: output.path) else { throw DevelopmentError.outputExists(output.path) }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let resources = bundle.appendingPathComponent("Contents/Resources")
        try run("plutil", ["-convert", "xml1", "-o", output.appendingPathComponent("ribbon.xml").path, resources.appendingPathComponent("onenote_mac.ribbonb").path])
        let nm = try run("nm", ["-arch", "arm64", "-m", bundle.appendingPathComponent("Contents/Frameworks/mso40ui.framework/Versions/A/mso40ui").path], capture: true)
        try Data(nm.stdout.utf8).write(to: output.appendingPathComponent("mso40ui-symbols-arm64.txt"))
        let selectors = try run("otool", ["-arch", "arm64", "-v", "-s", "__TEXT", "__objc_methname", bundle.appendingPathComponent("Contents/MacOS/Microsoft OneNote").path], capture: true)
        try Data(selectors.stdout.utf8).write(to: output.appendingPathComponent("objc-selectors-arm64.txt"))
        let nib = try run("xcrun", ["ibtool", "--objects", "--hierarchy", "--connections", "--output-format", "xml1", resources.appendingPathComponent("ONFishbowlViewController.nib").path], capture: true, allowFailure: true)
        try Data(nib.stdout.utf8).write(to: output.appendingPathComponent("ibtool-compiled-nib-result.xml"))
        if nib.exitCode != 0 { print("Compiled NIB decoding failed (\(nib.exitCode)); failure XML retained. This is not editable source recovery.") }
        let assets = root.appendingPathComponent("research/assets/\(label)")
        guard !FileManager.default.fileExists(atPath: assets.path) else { throw DevelopmentError.outputExists(assets.path) }
        try FileManager.default.createDirectory(at: assets, withIntermediateDirectories: true)
        for name in ["OneNote_macOS.icns", "ThirdPartyNotice.txt", "onenote.js"] {
            try FileManager.default.copyItem(at: resources.appendingPathComponent(name), to: assets.appendingPathComponent(name))
        }
        for name in ["foundation.macos.jsbundle", "ui.macos.jsbundle"] {
            try FileManager.default.copyItem(at: bundle.appendingPathComponent("Contents/Frameworks/mso40ui.framework/Versions/A/Resources/\(name)"), to: assets.appendingPathComponent(name))
        }
    }
}
