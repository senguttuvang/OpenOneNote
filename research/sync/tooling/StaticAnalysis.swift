import Foundation
import CryptoKit

// Orchestration stays Swift. Ghidra requires its Java adapter; configure the existing
// repository exporter in scratch rather than adding a second maintained Java workflow.
@main struct StaticAnalysis {
    static func main() throws {
        let fm = FileManager.default
        let root = URL(fileURLWithPath: fm.currentDirectoryPath)
        let lifecycle = CommandLine.arguments.contains("lifecycle")
        let trace = lifecycle || CommandLine.arguments.contains("trace")
        let follow = trace || CommandLine.arguments.contains("follow")
        let scratch = root.appendingPathComponent("scratch/sync/csi-analysis")
        let output = root.appendingPathComponent(lifecycle ? "research/sync/static/lifecycle" : (trace ? "research/sync/static/trace" : (follow ? "research/sync/static/follow" : "research/sync/static")))
        try fm.createDirectory(at: scratch, withIntermediateDirectories: true)
        try fm.createDirectory(at: output, withIntermediateDirectories: true)
        let csi = URL(fileURLWithPath: "/Applications/Microsoft OneNote.app/Contents/Frameworks/MicrosoftCSI.framework/Versions/A/MicrosoftCSI")
        let runner = NativeProcessRunner()
        let thin = scratch.appendingPathComponent("MicrosoftCSI-arm64")
        let inputHash = SHA256.hash(data: try Data(contentsOf: csi)).map { String(format: "%02x", $0) }.joined()
        guard inputHash == "e80e0bc4970f5cd538bf7a6dd7b5c18c8d58eda5416fa02b548cf5cd2dbf29e6" else { throw DevelopmentError.invalidArguments("CSI sample addresses are build-pinned") }
        try Data((inputHash + "  MicrosoftCSI-universal\n").utf8).write(to: output.appendingPathComponent("input.sha256"))
        _ = try runner.run("lipo", [csi.path, "-thin", "arm64", "-output", thin.path], at: root)
        let symbols = try runner.run("nm", ["-n", thin.path], at: root, capture: true).stdout
        let needles = ["CreateRequestBatch", "CreateRequestWorker", "CreateRequestFactory", "CreateCellStorageOverHttp", "CreateRevisionManifestScaffold", "CreateKnowledge", "SerializeDataElementPackage", "FGetCellKnowledge", "GetChangesSinceToken"]
        let selected = symbols.split(separator: "\n").filter { line in needles.contains { line.contains($0) } }
        try Data((selected.joined(separator: "\n") + "\n").utf8).write(to: output.appendingPathComponent("selected-symbols.txt"))
        var bridge = try String(contentsOf: root.appendingPathComponent("Tools/ghidra/ExportSelectedMethods.java"), encoding: .utf8)
        guard let start = bridge.range(of: "        String[][] selected = {"), let end = bridge.range(of: "        DecompInterface decompiler") else { throw DevelopmentError.invalidArguments("Exporter layout changed") }
        let addresses: [(String, String)] = trace ? [("9e850", "WorkerConstruction"), ("a713c", "BatchConstruction")] : (follow ? [("9da6c", "FactoryImplementation"), ("9dae8", "WorkerImplementation"), ("a708c", "BatchImplementation"), ("23d100", "CellStorageAllocation"), ("23d464", "CellStorageInitialization"), ("281f20", "SerializeDataElement"), ("79dc78", "ChangeTokenServiceCall"), ("79e734", "ChangeTokenChannelCreation"), ("736a88", "CellStorageFlagMutation")] : [("9da38", "CreateRequestFactory"), ("9dab4", "CreateRequestWorker"), ("a6f34", "CreateRequestBatch"), ("1dc060", "CreateRevisionManifestScaffold"), ("23cf98", "CreateCellStorageOverHttp_full"), ("26afb8", "CreateKnowledge"), ("51c60c", "SerializeDataElementPackage"), ("542cbc", "FGetCellKnowledge"), ("7369b0", "CreateCellStorageOverHttp_simple"), ("79ff78", "GetChangesSinceToken")])
        let selectedAddresses = lifecycle ? [("9c7a4", "TransportPathSelection"), ("106af0", "WorkerProtocolSelection")] : addresses
        let configuration = "        String[][] selected = {\n" + selectedAddresses.map { "            {\"\($0.0)\", \"\($0.1)\"}" }.joined(separator: ",\n") + "\n        };\n"
        bridge.replaceSubrange(start.lowerBound..<end.lowerBound, with: configuration)
        bridge = bridge.replacingOccurrences(of: "No whole-program analysis. Sample cannot establish complete behavior.", with: "Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred.")
        let exportRefs = """
                try (PrintWriter refs = new PrintWriter(new File(directory, item[1] + ".refs.tsv"))) {
                    refs.println("direction\\taddress\\tname");
                    for (Function caller : function.getCallingFunctions(monitor)) refs.println("caller\\t" + caller.getEntryPoint() + "\\t" + caller.getName());
                    for (Function callee : function.getCalledFunctions(monitor)) refs.println("callee\\t" + callee.getEntryPoint() + "\\t" + callee.getName());
                }
                try (PrintWriter assembly = new PrintWriter(new File(directory, item[1] + ".asm.txt"))) {
                    for (var instructions = currentProgram.getListing().getInstructions(function.getBody(), true); instructions.hasNext();) {
                        var instruction = instructions.next();
                        assembly.println(instruction.getAddress() + " " + instruction);
                        for (var reference : instruction.getReferencesFrom()) {
                            var symbol = getSymbolAt(reference.getToAddress());
                            if (symbol != null) assembly.println("  ref " + reference.getToAddress() + " " + symbol.getName(true));
                        }
                    }
                }
        """
        bridge = bridge.replacingOccurrences(of: "                DecompileResults result =", with: exportRefs + "\n                DecompileResults result =")
        if trace {
            let traces = """
                try (PrintWriter refs = new PrintWriter(new File(directory, "transport-references.tsv"))) {
                    refs.println("target\\tfrom\\tfunction\\ttype");
                    for (String target : new String[]{"ab1890", "afad9c", "d4c358", "adfe5f", "adfe8b", "adfeb3"}) {
                        for (var iterator = currentProgram.getReferenceManager().getReferencesTo(toAddr(target)); iterator.hasNext();) {
                            var reference = iterator.next();
                            var owner = getFunctionContaining(reference.getFromAddress());
                            refs.println(target + "\\t" + reference.getFromAddress() + "\\t" + (owner == null ? "data-or-unresolved" : owner.getEntryPoint() + ":" + owner.getName()) + "\\t" + reference.getReferenceType());
                        }
                    }
                }
                try (PrintWriter symbols = new PrintWriter(new File(directory, "scheduler-symbols.tsv"))) {
                    for (var iterator = currentProgram.getSymbolTable().getAllSymbols(true); iterator.hasNext();) {
                        var symbol = iterator.next();
                        String name = symbol.getName(true);
                        if (name.contains("HostNotifications") || name.contains("ContentSyncScheduler") || name.contains("CobaltClient")) symbols.println(symbol.getAddress() + "\\t" + name);
                    }
                }
            """
            bridge = bridge.replacingOccurrences(of: "        DecompInterface decompiler =", with: traces + "\n        DecompInterface decompiler =")
        }
        if lifecycle {
            let expansion = """
                var expanded = new java.util.ArrayList<String[]>(java.util.Arrays.asList(selected));
                var visited = new java.util.HashSet<String>();
                for (String target : new String[]{"bb95f6", "bb9732", "bb97cd", "ba22c2", "bb90de", "b98ddb"}) {
                    for (var iterator = currentProgram.getReferenceManager().getReferencesTo(toAddr(target)); iterator.hasNext() && expanded.size() < 12;) {
                        var reference = iterator.next();
                        var owner = getFunctionContaining(reference.getFromAddress());
                        if (owner != null && visited.add(owner.getEntryPoint().toString())) expanded.add(new String[]{owner.getEntryPoint().toString(), "LiteralRef_" + target + "_" + owner.getEntryPoint()});
                    }
                }
                selected = expanded.toArray(new String[0][]);
            """
            bridge = bridge.replacingOccurrences(of: "        DecompInterface decompiler =", with: expansion + "\n        DecompInterface decompiler =")
        }
        try Data(bridge.utf8).write(to: scratch.appendingPathComponent("ExportSelectedMethods.java"))
        let operation = follow ? ["-process", "MicrosoftCSI-arm64", "-readOnly", "-noanalysis"] : ["-import", thin.path]
        let args = [scratch.path, "CSI"] + operation + ["-max-cpu", "2", "-analysisTimeoutPerFile", "600", "-scriptPath", scratch.path, "-postScript", "ExportSelectedMethods.java", output.path, "-log", scratch.appendingPathComponent(trace ? "trace.log" : (follow ? "follow.log" : "analysis.log")).path, "-scriptlog", scratch.appendingPathComponent(trace ? "trace-script.log" : (follow ? "follow-script.log" : "script.log")).path]
        try Data((try JSONSerialization.data(withJSONObject: ["inputSHA256": inputHash, "arguments": args, "generatedAdapterSHA256": SHA256.hash(data: Data(bridge.utf8)).map { String(format: "%02x", $0) }.joined()], options: [.prettyPrinted, .sortedKeys]))).write(to: scratch.appendingPathComponent("invocation.json"))
        _ = try runner.run("/opt/homebrew/opt/ghidra/libexec/support/analyzeHeadless", args, at: root, capture: false, timeout: 1000)
    }
}
