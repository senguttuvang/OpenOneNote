# OpenOneNote

Private OneNote Mac research and an independent native Swift reconstruction.

## Ownership

- `research/`: immutable Microsoft bundle archives, original assets, metadata, assembly, and pseudocode. They retain original ownership and are never dependencies of the new application.
- `Sources/NotebookCore`: independent notebook model and repository port; Foundation imports only.
- `Sources/NotebookPersistence`: local storage, depending inward on NotebookCore.
- `Sources/OneNoteResearch`: static bundle analysis; never read account stores, notebook caches, Keychain, process memory, or runtime traffic.
- `Sources/OpenOneNoteCLI`: functioning foundation demonstrator, not the finished graphical application.
- `Sources/NotebookEditor`: AppKit/SwiftUI editing, UI session state, rich-text conversion, and owned-view verification. `Sources/OpenOneNoteMac` composes the app lifecycle and menus.
- `Sources/DevelopmentKit` and `Sources/OpenOneNoteDev`: Swift-only project CLI, CI checks, capture orchestration, app assembly, signing, and packaging. Do not add shell/Python/Bun workflow scripts. Invoke native tools through the typed process boundary.
- `reconstruction/` and `specs/`: distinguish proposals from implementation. Library presence and pseudocode samples cannot establish feature parity.
- Git LFS owns original archives, compressed assembly, and compiled distributions. Keep them out of ordinary Git blobs.
- Do not upload third-party research to semantic indexes. Verify provider exclusion controls before indexing authored Sources, Tests, and Tools.

## Delivery And Tasks

Use a fresh feature worktree, direct self-review, `swift run openonenote-dev check`, and a GitHub PR. This repository opts into the team-maintainer Beads profile for authorized commit/push/merge delivery; global safety rules still apply.

GitHub Actions is disabled by explicit user instruction to avoid Actions-credit consumption. Keep it disabled, do not add workflows or dispatch Actions, and do not use paid CI runners. The local Swift check command is the full CI-equivalent merge gate. A new authorization is required before enabling credit-consuming GitHub automation.

Beads owns live work: `bd prime`, `bd ready`, `bd show <id>`, then `bd update <id> --claim`. Initial task: `oon-0hm`. Discover the authoritative database with `bd where`; remote task synchronization is unverified and remains local-only until proven.

## Verification

`swift run openonenote-dev check`: Swift tests, release build, real native text edits/format/undo/save/reopen, background native renders, CLI read/write/rejection paths, evidence tamper rejection, and authored whitespace checks. Research additionally needs gzip validation, archive checksums, and `onenote-research verify` against the per-file inventory after extraction.

Native tests and preview modes must set prohibited activation policy and keep windows hidden. Never activate an app or switch the user's focus for agent convenience. Microsoft OneNote API/GUI interaction testing has not run. Static research concentrates on the arm64 main binary, dependency inventories, and six sampled functions; Intel bytes are preserved with less analysis.
