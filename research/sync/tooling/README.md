# Research Probe Entry Points

These standalone Swift probes reproduce the dedicated storage/sync investigation without extending the static-only application research target or touching another agent's shared workflow files.

Run from the feature worktree root. Keep generated binaries, Ghidra projects, private IDs and unredacted synthetic service responses under ignored `scratch/sync/`. Do not capture existing note bodies. Commands below require an already installed Swift toolchain and, for Graph, the sanctioned `m365` CLI session.

## Read-Only Runtime Probes

```text
swiftc -swift-version 6 -warnings-as-errors research/sync/tooling/StorageProbe.swift -o scratch/sync/storage-probe
scratch/sync/storage-probe
swiftc -swift-version 6 -warnings-as-errors research/sync/tooling/StorageSchema.swift -o scratch/sync/storage-schema
scratch/sync/storage-schema
swiftc -swift-version 6 -warnings-as-errors Sources/DevelopmentKit/ProcessRunner.swift research/sync/tooling/NativeObservation.swift -o scratch/sync/native-observation
scratch/sync/native-observation
```

- **StorageProbe:** reports aggregate sizes and header classes from allowed roots. Skips hidden files, symlinks, and excluded paths. Reads at most 16 header bytes per included file; outputs no names/raw bytes.
- **StorageSchema:** known OneNote subtrees, SQLite `READONLY|URI` plus `immutable=1`; reads `sqlite_master` table names and `PRAGMA table_info` column names only. Ignores WAL. Never query the `Text`, identity, or search-term rows.
- **NativeObservation:** queries an already running OneNote process via OS APIs/`lsof`; no launch or UI mutation. Reads small `ServerListings` files only to emit a synthetic-title-match count. IP addresses/filenames/bodies are suppressed.

## Synthetic Graph Experiments

```text
swiftc -swift-version 6 -warnings-as-errors research/sync/tooling/GraphExperiment.swift -o scratch/sync/graph-experiment
scratch/sync/graph-experiment inspect
scratch/sync/graph-experiment reconcile
```

`inspect`, `reconcile`, and `download-attachment` read the run's owned objects. `account` additionally requires a privately supplied `OON_EXPECTED_PRINCIPAL` and emits comparison booleans only. It does not log identity values.

`self-test` performs seven pure request-scope cases and an unknown-object rejection check without starting a network process.

**Write modes:** `provision` creates the clearly named synthetic notebook/section/canvas page only when the local registry is empty; `append` adds a marker to its owned page; `outer-replace` replaces that page's main container content; `attachment` creates a new attachment page once; `stale-writes` starts a one-time stale-ID experiment. These are explicit experimental writes, not a production sync adapter. The existing registry refuses duplicate provisioning/stale-probe starts. An uncertain write outcome requires reconciliation before any retry. No delete method is implemented.

The CLI owns authentication. Swift neither reads its token cache nor requests/extracts token values. Responses/errors are captured into owner-only temporary files, raw diagnostics are suppressed, and those temporary transport files are removed. Exact synthetic IDs and raw synthetic projections remain local in protected scratch files. Endpoint checks allow the expected Graph root and read-only resource URLs obtained from the owned attachment projection.

**Limits:** CLI exit success is not a captured HTTP status. Failure diagnostics may be empty. Polling uses a bounded process deadline, not API-level cancellation; after a timeout write state can be unknown. Registry ownership is an operational guard within this trusted worktree, not cryptographic proof against a modified local registry. Never point it at a manually fabricated existing-note ID.

## Static Analysis

```text
swiftc -swift-version 6 -warnings-as-errors Sources/DevelopmentKit/ProcessRunner.swift research/sync/tooling/StaticAnalysis.swift -o scratch/sync/static-analysis
scratch/sync/static-analysis
scratch/sync/static-analysis follow
scratch/sync/static-analysis trace
scratch/sync/static-analysis lifecycle
swiftc -swift-version 6 -warnings-as-errors research/sync/tooling/StaticStrings.swift -o scratch/sync/static-strings
scratch/sync/static-strings
```

The first analysis requires a fresh ignored Ghidra project directory and the exact pinned CSI hash. It thins the installed binary and requests normal analysis. Subsequent modes read that analyzed project without reanalysis or saving mutations. Do not run modes concurrently against one project/exporter. The Swift orchestration configures the existing `Tools/ghidra/ExportSelectedMethods.java` as a generated scratch adapter for Ghidra's required Java API. This is not a second maintained Java workflow or an application dependency.

`StaticStrings` extracts a filtered ASCII/ASCII-subset UTF-16 literal catalogue from the thin static binary. It strips URL queries, records offsets/encoding, and does not read runtime storage. Literal matches alone do not prove live protocol use.

## Export And Validate

`ExportEvidence` copies only allowlisted aggregate/event records and synthetic HTML, deduplicates schemas, replaces generated element/account/resource identifiers, and excludes the private registry. `VerifyEvidence` checks local links, absence of known private object IDs, runtime UUID/JWT patterns, and evidence hashes. Do not add arbitrary cache files to the export allowlist.

```text
swiftc -swift-version 6 -warnings-as-errors research/sync/tooling/ExportEvidence.swift -o scratch/sync/export-evidence
scratch/sync/export-evidence
swiftc -swift-version 6 -warnings-as-errors research/sync/tooling/VerifyEvidence.swift -o scratch/sync/verify-evidence
scratch/sync/verify-evidence
```

Exporting intentionally changes the evidence bytes; regenerate the manifest only after review. Verification never calls Graph or changes notes. Existing original research archives remain LFS-owned and were not duplicated for this investigation.
