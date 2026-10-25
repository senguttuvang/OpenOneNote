# OpenOneNote Reconstruction Specification

This specification defines the private research deliverable and staged independent Swift reconstruction requested for OpenOneNote.

## Outcomes

- Private repository at `senguttuvang/OpenOneNote` containing preserved original application artifacts, extracted evidence, original assets, analysis, reconstruction design, and independent Swift code/builds.
- Explain the observed Mac technology mix with evidence and confidence; distinguish Windows shared-infrastructure inference from proven source-code identity.
- Establish a reproducible Swift foundation and an implementation path toward a useful native notebook editor.

## Research Acceptance

- Archive the complete installed bundle and its top-level Resources directory; record version/build, signature, executable architectures, and SHA-256 checksums.
- Inventory every regular file and symlink; verify a restored archive against the recorded inventory.
- Capture native dependencies, Objective-C metadata/selectors, symbols, readable strings, serialized ribbon data, JavaScript integration evidence, and selected pseudocode with tool/version limits.
- Keep third-party materials separate from new source code and preserve original notices. Keep account/user notebook data out of captures.
- Push the archives through Git LFS and verify remote availability through readback, not merely local file presence.

## Swift Foundation Acceptance

- Swift 6 / macOS 14+ package builds without proprietary runtime dependencies.
- Stable notebook/section/page/block IDs; positioned plain-text blocks; invalid geometry/duplicate IDs rejected.
- Schema-versioned atomic local saves; exact readback; missing/corrupt/future-schema files fail without replacement.
- A CLI creates a synthetic notebook and inspects it; existing destinations cannot be overwritten by demo creation.
- Full local check command runs build, tests, CLI success/failure paths, and whitespace checks.

## Proposed Next Milestones

**Native editor slice:** local-first priority confirmed. Graphical notebook/section/page navigation and naming, positioned/resizable native rich-text containers, formatting, active-page undo, autosave and reopen are implemented. Background native renders and programmatic AppKit edit/format/undo/reopen checks pass. Manual keyboard/VoiceOver review and direct OneNote parity comparisons remain separate validation work.

**Canvas and rich text:** document/viewport transform model; positioning/resizing; semantic runs/lists; text tables and attachments; input/accessibility and paste fixtures.

**Durable local notebooks:** transactional persistence, migrations, edit revisions, recovery, attachment storage, search/index updates, and export.

**Compatibility:** documented read-only import and Graph readback; feature fidelity matrix and retained originals for unsupported content; no silent conversion loss.

**Sync and packaging:** delegated account setup, retries/idempotency, conflicts, offline edits, signing/notarization, release/rollback validation.

Milestones after the initial editor remain proposed scope, not delivery-date commitments. Beads owns live tasks and dependencies; this file is the behavior/acceptance contract. Project-owned CLI/CI/build/verification/capture orchestration is Swift.

## Constraints And Open Decisions

- Windows source overlap remains unquantified until a Windows artifact is compared.
- No formal source recovery, full OneNote parity, or private cloud backend reconstruction is promised by this research pass.
- RTF is the initial native formatting representation; production storage, richer document semantics, import fidelity, and sync contracts require further evidence.
- Native owned-view renders and text-control integration checks have run. Complete Microsoft OneNote UI/capability parity is not claimed.

## Dark fidelity and context indexing slice

Use the supplied private OneNote Mac screenshot as the geometry/color reference while retaining OpenOneNote identity. Deliver a dark native ribbon, app rail, notebook/section/page hierarchy and positioned text containers. Every actionable ribbon control must reach the selected NSTextView or notebook command; unsupported capabilities must be explicit. Preserve existing saved files and stored RTF/geometry.

Acceptance: native selection formatting and undo; font family/size; paragraph/list styles; selected-text links; editable bordered table insertion with RTF reopen; page/section creation; independent document scrolling; wide/reference/compact hidden renders. Record observed differences and untested interactions in DESIGN.md and visual evidence. Full OneNote parity is not an acceptance claim.

Index authored code and static extracted/decompiled text locally with file hashes, source revision, path/line query results and provenance. Exclude original archives, compressed assembly, binaries, assets, account stores, screenshot and client content. Reject stale queries rather than presenting changed source as current. JetBrains has no local-main baseline and its installed index command exposes no exclusion flag; do not upload this mixed-ownership checkout without a separately verified provider boundary. The offline lexical index does not claim semantic embeddings or recovery of original source.
