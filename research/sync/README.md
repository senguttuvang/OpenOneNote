# Storage And Sync Investigation Evidence

This catalogue preserves build-pinned static results and sanitized runtime measurements for the dedicated `oon-749` investigation, with the interpretation in [OneNote internals](../../reconstruction/onenote-internals/README.md).

## Scope And Ownership

- **Date/build:** 26 October 2026; OneNote `16.114.1` (`16.114.26102031`), arm64 analysis on macOS. Installed main executable SHA-256 matched the previously captured build.
- **Authority:** the user authorized read-only existing storage inspection and new synthetic notes, overriding the earlier static-only investigation scope for this dedicated work. `Sources/OneNoteResearch` remains unchanged/static-only.
- **Outputs:** only new `research/sync/` and `reconstruction/onenote-internals/` files. No UI/indexing agent files, shared manifests, Actions workflows, credentials, note caches, account databases, or personal note bodies are included.
- **Runtime boundary:** local metadata/header/schema reads, sanctioned Graph operations on new objects, and native OS descriptor/session metadata. No existing note mutation, note deletion, foreground activation, app navigation/quit, global network change, debug attachment, TLS interception, or security weakening.
- **Research ownership:** generated pseudocode/assembly/literals derive from Microsoft binaries and retain Microsoft's ownership. They are evidence, not recovered original source, and are never application dependencies. Tooling is independently authored Swift; its Ghidra adapter configures the repository's existing Java exporter in ignored scratch storage.

## Provenance

| Item | Value |
| --- | --- |
| Base | `c91d6a201886f2008e007157c437574938882329` |
| Main executable SHA-256 | `9b47f05110382560fafbccfa25ff716463fe7af9fec63da848546a26531733aa` |
| MicrosoftCSI universal SHA-256 | `e80e0bc4970f5cd538bf7a6dd7b5c18c8d58eda5416fa02b548cf5cd2dbf29e6` |
| Ghidra | Installed 12.2; default analysis requested, two CPUs, 600-second file limit |
| Analysis outcome | Reported success; analyzer total 311 seconds; no timeout |
| Dependencies | Zero additional binaries loaded; imported symbol names available, bodies unresolved |
| Known analysis errors | Function-body/thunk conflicts at `0x6410b4` and `0x642dd4`; many external RTTI/vtable application warnings |
| Export scope | 32 distinct sampled functions across initial/follow/trace/lifecycle; all selected decompilations completed |
| Coordinates | CSI addresses are unslid arm64 virtual addresses; literal TSV uses thin-file offsets |

The [sanitized analysis log](static/analysis.sanitized.log) retains analyzer timings/warnings. Caller/callee `.refs.tsv` files report Ghidra's direct relationships, not a complete interprocedural proof through every virtual call. Working labels are descriptive/inferred; the body retains its actual `FUN_...` or exported symbol name. Two initially misleading working labels were corrected after reading their bodies (`CellStorageFlagMutation`, `WorkerProtocolSelection`).

## Experiments

| ID | Execution/result | Limit |
| --- | --- | --- |
| E01 build identity | Installed version/hash matched archived main | No new full-bundle archive made |
| E02 storage headers | Partial header probe: 10,887 `.bin`; 531 `.one` inspected; 529 ONESTORE GUID prefixes | Conservative path exclusions; no content decode |
| E03 storage schema | 32 immutable/read-only persisted SQLite schemas; metadata totals by directory | No application rows/WAL snapshot; broader scope than E02 |
| E04 Graph create | New notebook, section, positioned text/list/table page | Service representation, native rendering untested |
| E05 Graph remote append | `REMOTE-BETA` present in next readback | No native receipt observed |
| E06 outer replacement | Fresh-ID content replacement succeeded; requested 750px remained 720px | Earlier invalid-target attempts are not valid restriction tests |
| E07 embedded file | New attachment page; downloaded 47 bytes exactly equal to input | Small ASCII file only; no arbitrary binary/large-file claim |
| E08 stale-base edits | Two reads returned same ID; A replaced; B using stale ID failed; A retained | Sequential stale reads, not simultaneous/native concurrency; failure cause unavailable |
| E09 native metadata | 22 cache descriptors; one remote TCP/443 connection; cmux foreground unchanged | No hostname, HTTP method/status/version, wire payload, or active notification proof |
| E10 bounded listing | Synthetic title absent from five `ServerListings` files | Cannot exclude other encodings/listings or prove native UI absence |
| E11 static analysis | Analyzed cell constructors, binary serializers, SOAP token path, endpoint selection, scheduler and notification state | Not complete source, protocol implementation, or live call trace |
| E12 supplied prior art | Four distinct repositories source-reviewed and revision-pinned | No dependency installed or upstream parser run; Discord inaccessible |

### Failed Attempts And Corrections

- Initial content read supplied `--output` twice; corrected before successful readback. No duplicate notebook was created.
- Two outer replacement attempts used an invalid target spelling. The later experiment used a fresh generated ID and succeeded for content while ignoring width. Only that later result informs geometry conclusions.
- Two multipart attempts failed when the body began with `--` and was passed as an option value. Passing a protected `@file` body succeeded. The earlier CLI failures contained no diagnostics, so this is a tooling explanation consistent with the correction, not a captured server error classification.
- First attachment downloader assumed `/me` in returned resource URLs and failed to find the resource. The owned projection used an identity-specific root. Following that exact returned Graph resource succeeded.
- The stale writer failed with no exported HTTP/error detail. No conflict code, data-loss guarantee, or retry policy was inferred from that failure.
- LLVM's Mach-O mode did not honor the attempted bounded-disassembly invocation as expected; no full assembly output from that attempt was retained here. Ghidra bounded-function exports supply the instruction evidence instead.

### Unperformed Native Experiments

Native edit → cache → backend acknowledgement; separate-client edit → native receipt; scoped offline/reconnect; crash/transaction recovery; native conflicting edits; native transport host/method/status/content type; foreground/background scheduling. The app had no declared scripting definition, and no verified non-activating synthetic-page editing surface or scoped per-notebook network isolation was available. No foreground fallback, global disconnect, app termination, credential extraction, or unrelated traffic capture was used. These gaps remain explicit in local-only follow-up task `oon-4kg` (discovered from `oon-749`).

## Retained Synthetic Objects

**Observed/reconciled:** one notebook named `OpenOneNote Sync Research 20261026 Synthetic`, one section `Synthetic Storage Fixtures`, two pages (`OON-SYNC-20261026 Canvas Fixture`, `OON-SYNC-20261026 Attachment Fixture`), and one attached `synthetic.txt` resource. They were not deleted. Writes replaced only content created in this run. No existing user pages were written by the probe.

Exact returned IDs remain in the owner-only ignored `scratch/sync/owned-objects.json` in this dedicated worktree. They are intentionally absent from Git, public sources, terminal summaries, and semantic indexes. This local registry is needed to resume inspection; do not reconstruct IDs from sanitized fixtures or reprovision blindly. Independent user/app changes to other notebooks were not globally audited, so “no existing note writes by this probe” is the precise preservation claim.

## Reproduction And Verification

Read [tooling instructions](tooling/README.md) before running anything. `StorageProbe`, `StorageSchema`, and `NativeObservation` are read-only; `GraphExperiment` has explicit synthetic writes and refuses duplicate provisioning. No command is a cleanup/deletion operation.

`runtime/` contains aggregate/header/schema records, CLI events and sanitized synthetic HTML. The `.html` files preserve the CLI's escaped line separators as evidence, not as a native rendering fixture. `static/` contains sampled pseudocode, selected function assembly, direct call references, literal offsets and the sanitized analyzer log. `evidence-manifest.json` hashes the committed evidence/document/tool bytes; it excludes itself, private scratch state, and later delivery-record updates.

Required verification: Swift 6 warnings-as-errors compilation of each standalone tool; local link/redaction/hash validation; `swift run openonenote-dev check`; installed-bundle per-file inventory verification; gzip/checksum verification of the existing archived research where full LFS bytes are available. No GitHub Actions or paid runner is used.
