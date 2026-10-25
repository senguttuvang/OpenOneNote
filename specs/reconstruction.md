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

**Native editor slice:** graphical notebook/section/page navigation; editable text container; UndoManager integration; edit/save/reopen; accessible keyboard focus. Decide local-first, existing-cloud-notebook-first, or canvas-parity-first sequencing with the user.

**Canvas and rich text:** document/viewport transform model; positioning/resizing; semantic runs/lists; text tables and attachments; input/accessibility and paste fixtures.

**Durable local notebooks:** transactional persistence, migrations, edit revisions, recovery, attachment storage, search/index updates, and export.

**Compatibility:** documented read-only import and Graph readback; feature fidelity matrix and retained originals for unsupported content; no silent conversion loss.

**Sync and packaging:** delegated account setup, retries/idempotency, conflicts, offline edits, signing/notarization, release/rollback validation.

These milestones are proposed scope, not completed features or delivery-date commitments. Beads owns live tasks and dependencies; this file is the behavior/acceptance contract.

## Constraints And Open Decisions

- Windows source overlap remains unquantified until a Windows artifact is compared.
- No formal source recovery, full OneNote parity, or private cloud backend reconstruction is promised by this research pass.
- Rich-text serialization, production storage library, packaging identity, initial feature priority, import fidelity targets, and sync expectations require prototype evidence or user decisions.
- The present graphical design is proposed; no UI parity or GUI verification is claimed.
