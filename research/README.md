# Research Capture And Reproduction

This directory preserves the installed OneNote Mac build and static evidence used to assess its architecture on 25 October 2026.

## Source And Scope

- **Source:** `/Applications/Microsoft OneNote.app`, version 16.114.1, build 16.114.26102031.
- **Identity:** `com.microsoft.onenote.mac`, Microsoft Developer ID signature, team `UBF8T346G9`; universal x86_64/arm64 executable. The observed signature is Developer ID rather than an App Store distribution signature.
- **Application only:** no user notebook caches, group-container contents, account records, credentials, memory dumps, or network captures.
- **Preservation:** full app archive includes every embedded framework and its resources. Separate Resources archive contains the entire top-level `Contents/Resources` tree. Loose selected assets are inspection copies.

Every regular file has a SHA-256 inventory entry; symlinks retain their destinations. Directories are excluded from inventory entries. The archived app is extracted and verified against that inventory. Ownership and extended filesystem metadata are outside the integrity contract; file bytes and symlink destinations are checked.

## Capture Another Build

Use a new immutable label:

```sh
sh Tools/capture-originals.sh '/Applications/Microsoft OneNote.app' 'new-version-build'
```

The command rejects existing outputs and does not install, patch, or launch OneNote. It currently requires an arm64 slice. A failed partial capture remains visible for investigation.

The initial capture also includes decoded ribbon XML, selectors, selected original resources, and an `mso40ui` symbol table. Additional extraction commands are retained in `capture-additional-evidence.sh`. `ibtool` rejected the compiled NIB; error XML is retained. No editable XIB source was recovered.

## Verify An Archive

```sh
shasum -a 256 -c research/originals/SHA256SUMS
gzip -t research/originals/*.tar.gz
mkdir -p scratch/restored
COPYFILE_DISABLE=1 tar -xzf research/originals/onenote-mac-16.114.1.app.tar.gz -C scratch/restored
swift run onenote-research verify 'scratch/restored/Microsoft OneNote.app' research/extracted/16.114.1/bundle-inventory.json
```

Use an empty destination. The verifier checks every captured file/link but does not certify absence of extra files. An archive listing is retained for scope auditing.

## Ghidra Sample

Ghidra 12.2 imported the arm64 slice with external framework loading and whole-program analysis disabled. The version-specific `Tools/ghidra/ExportSelectedMethods.java` disassembles/decompiles six selected addresses with a 20-second budget per function. Outputs have inferred types and imperfect calls; they are not original source.

```sh
mkdir -p scratch/ghidra research/decompiled/new-sample
lipo '/Applications/Microsoft OneNote.app/Contents/MacOS/Microsoft OneNote' -thin arm64 -output scratch/onenote-arm64
/opt/homebrew/opt/ghidra/libexec/support/analyzeHeadless scratch/ghidra OpenOneNote-16.114.1 \
  -import scratch/onenote-arm64 -noanalysis -max-cpu 2 \
  -scriptPath Tools/ghidra -postScript ExportSelectedMethods.java "$PWD/research/decompiled/new-sample"
```

Addresses apply only to the captured build. The two sampled Copilot bridge methods are no-op bodies and do not establish feature behavior. The generated Ghidra project is preserved as an archive under `originals/` for resuming analysis. No full call graph, complete decompilation, Swift source recovery, private sync-protocol reconstruction, or Windows-binary comparison has been performed.

## Interpretation

Distinguish observations, inferred responsibilities, and proposals. Bundled libraries do not prove specific feature execution. Absence claims are bounded by the complete captured path inventory and examined symbols. Intel bytes are preserved; arm64 receives deeper analysis.
