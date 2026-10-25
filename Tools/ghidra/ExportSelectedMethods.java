// Export a deliberately bounded sample. Addresses are from the arm64 metadata
// of OneNote 16.114.1 (16.114.26102031), not portable selectors or source code.
// @category OpenOneNote.Research
import ghidra.app.script.GhidraScript;
import ghidra.app.decompiler.DecompInterface;
import ghidra.app.decompiler.DecompileResults;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Function;
import java.io.PrintWriter;
import java.io.File;

public class ExportSelectedMethods extends GhidraScript {
    @Override public void run() throws Exception {
        String[] args = getScriptArgs();
        if (args.length != 1) throw new IllegalArgumentException("Expected output directory");
        File directory = new File(args[0]);
        if (!directory.isDirectory()) throw new IllegalArgumentException("Output directory must exist");
        String[][] selected = {
            {"10005ad4c", "entry_point"},
            {"10026dbe8", "ONPageView_method_10026dbe8"},
            {"10026dfa8", "ONPageView_method_10026dfa8"},
            {"10027424c", "ONPageView_method_10027424c"},
            {"1003a175c", "CopilotFREUI_method_1003a175c"},
            {"1003a176c", "CopilotFREUI_method_1003a176c"}
        };
        DecompInterface decompiler = new DecompInterface();
        if (!decompiler.openProgram(currentProgram)) throw new IllegalStateException("Cannot open program");
        try (PrintWriter manifest = new PrintWriter(new File(directory, "selected-methods.tsv"))) {
            manifest.println("address\tlabel\tdecompiled\tnote");
            for (String[] item : selected) {
                monitor.checkCancelled();
                Address address = toAddr(item[0]);
                disassemble(address);
                Function function = getFunctionAt(address);
                if (function == null) function = createFunction(address, item[1]);
                if (function == null) {
                    manifest.println(item[0] + "\t" + item[1] + "\tfalse\tFunction creation failed");
                    continue;
                }
                DecompileResults result = decompiler.decompileFunction(function, 20, monitor);
                boolean complete = result.decompileCompleted() && result.getDecompiledFunction() != null;
                manifest.println(item[0] + "\t" + item[1] + "\t" + complete + "\t" + result.getErrorMessage().replace('\n', ' '));
                try (PrintWriter writer = new PrintWriter(new File(directory, item[1] + ".c"))) {
                    writer.println("/* Ghidra pseudocode; inferred types and names; not Microsoft source. */");
                    writer.println("/* No whole-program analysis. Sample cannot establish complete behavior. */");
                    writer.println(complete ? result.getDecompiledFunction().getC() : "/* " + result.getErrorMessage() + " */");
                }
            }
        } finally { decompiler.dispose(); }
    }
}
