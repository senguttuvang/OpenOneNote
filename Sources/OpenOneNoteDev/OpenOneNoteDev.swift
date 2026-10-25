import Foundation
import DevelopmentKit

@main @MainActor struct OpenOneNoteDevelopmentCLI {
    static func main() {
        do {
            let arguments = Array(CommandLine.arguments.dropFirst())
            let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            guard FileManager.default.fileExists(atPath: root.appendingPathComponent("Package.swift").path) else {
                throw DevelopmentError.invalidArguments("Run openonenote-dev from the OpenOneNote repository")
            }
            let workflow = DevelopmentWorkflow(root: root)
            switch arguments.first {
            case "check" where arguments.count == 1: try workflow.check()
            case "app" where arguments.count == 1: try workflow.buildApp()
            case "verify-app" where arguments.count == 1: try workflow.verifyApp()
            case "package-app" where arguments.count == 1: try workflow.packageApp()
            case "package-tools" where arguments.count == 1: try workflow.packageTools()
            case "capture" where arguments.count == 3: try workflow.capture(bundle: URL(fileURLWithPath: arguments[1]), label: arguments[2])
            case "additional" where arguments.count == 4: try workflow.additional(bundle: URL(fileURLWithPath: arguments[1]), output: URL(fileURLWithPath: arguments[2]), label: arguments[3])
            case "decompile-sample" where arguments.count == 4: try workflow.decompileSample(bundle: URL(fileURLWithPath: arguments[1]), label: arguments[2], ghidra: URL(fileURLWithPath: arguments[3]))
            case "help", "--help", nil:
                print("OpenOneNote Swift development CLI\nCommands: check | app | verify-app | package-app | package-tools | capture <app> <new-label> | additional <app> <new-directory> <label> | decompile-sample <app> <new-label> <analyzeHeadless>")
            default: throw DevelopmentError.invalidArguments("Unknown command or wrong arguments; use openonenote-dev help")
            }
        } catch { FileHandle.standardError.write(Data("Development workflow failed: \(error)\n".utf8)); exit(1) }
    }
}
