# Local code and research context

`swift run openonenote-dev source-index` creates `scratch/source-index.json`. `source-query "terms"` verifies every indexed file hash before searching and returns path/line references. Rebuild after source changes. The manifest records the Git revision plus each file's SHA-256, so uncommitted bytes are identified by their hashes rather than confused with that revision's tree.

The index is entirely offline: Foundation/CryptoKit, no provider credentials, networking or embeddings. It includes UTF-8 text in Sources, Tests, Tools, research/extracted and research/decompiled, using an explicit extension allowlist and 32MiB per-file limit. Original archives, binaries, compressed assembly, assets, notebooks and the private reference screenshot are excluded. LFS pointers and binary plists are recorded as skipped, never counted as indexed content. This slice indexes 111 text files (24 authored, 87 research); see the native fidelity verification evidence for queries and exclusions.

AND queries match terms in a file path plus a source line, preserving exact symbol/selector spellings. Query a symbol across files to inspect references/call sites; this is lexical discovery, not a resolved compiler call graph. Examples:

```sh
swift run openonenote-dev source-index
swift run openonenote-dev source-query "formatSelection"
swift run openonenote-dev source-query "ribbon kOUIGallery"
swift run openonenote-dev source-query "ONPageView"
swift run openonenote-dev source-query "10026dbe8"
```

Research provenance remains explicit: extracted text derives from Microsoft static bundle evidence; six Ghidra C-like files are inferred pseudocode, not recovered source. No account caches, runtime traffic or process memory are read. Research is never an app dependency.

JetBrains context preparation reported `indexedRevision:null`, `needs-initial-index`. The installed 0.9.18 command's help offers no source exclusions. No whole-repository initial upload was attempted. Direct reads and scoped rg were used for current implementation discovery. External semantic indexing remains unverified; this local index fulfills text/symbol access for both ownership domains without uploading them.
