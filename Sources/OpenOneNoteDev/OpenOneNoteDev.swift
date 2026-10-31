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
            case "graph-probe" where arguments.count == 3:
                Task { @MainActor in
                    do { try await workflow.graphProbe(cli: arguments[1], output: URL(fileURLWithPath: arguments[2])); exit(0) }
                    catch { FileHandle.standardError.write(Data("Synthetic CLI Graph probe failed: \(error.localizedDescription)\n".utf8)); exit(1) }
                }
                RunLoop.main.run()
            case "microsoft-register" where arguments.count == 5:
                try workflow.microsoftRegister(azure: arguments[1], vault: URL(fileURLWithPath: arguments[2]), tenant: arguments[3], siteID: arguments[4])
            case "source-index" where arguments.count == 1: try workflow.sourceIndex(query: nil)
            case "source-query" where arguments.count == 2: try workflow.sourceIndex(query: arguments[1])
            case "check" where arguments.count == 1: try workflow.check()
            case "app" where arguments.count == 1: try workflow.buildApp()
            case "install-app" where arguments.count == 1: try workflow.installApp()
            case "inspection-app" where arguments.count == 1: try workflow.buildApp(inspection: true)
            case "verify-app" where arguments.count == 1: try workflow.verifyApp()
            case "package-app" where arguments.count == 1: try workflow.packageApp()
            case "package-tools" where arguments.count == 1: try workflow.packageTools()
            case "capture" where arguments.count == 3: try workflow.capture(bundle: URL(fileURLWithPath: arguments[1]), label: arguments[2])
            case "additional" where arguments.count == 4: try workflow.additional(bundle: URL(fileURLWithPath: arguments[1]), output: URL(fileURLWithPath: arguments[2]), label: arguments[3])
            case "decompile-sample" where arguments.count == 4: try workflow.decompileSample(bundle: URL(fileURLWithPath: arguments[1]), label: arguments[2], ghidra: URL(fileURLWithPath: arguments[3]))
            case "help", "--help", nil:
                print("OpenOneNote Swift development CLI\nCommands: check | app | inspection-app | install-app | verify-app | package-app | package-tools | microsoft-register <az> <vault> <tenant-id> <site-id> | graph-probe <m365> <new-output> | source-index | source-query <terms> | capture <app> <new-label> | additional <app> <new-directory> <label> | decompile-sample <app> <new-directory> <label> <analyzeHeadless>")
            default: throw DevelopmentError.invalidArguments("Unknown command or wrong arguments; use openonenote-dev help")
            }
        } catch { FileHandle.standardError.write(Data("Development workflow failed: \(error)\n".utf8)); exit(1) }
    }
}
