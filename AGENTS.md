# OpenOneNote

Private OneNote Mac research and an independent native Swift reconstruction.

## Ownership

- `research/`: immutable Microsoft bundle archives, original assets, metadata, assembly, and pseudocode. They retain original ownership and are never dependencies of the new application.
- `Sources/NotebookCore`: independent notebook model and repository port; Foundation imports only.
- `Sources/NotebookPersistence`: local storage, depending inward on NotebookCore.
- `Sources/OneNoteResearch`: static bundle analysis; never read account stores, notebook caches, Keychain, process memory, or runtime traffic.
- `Sources/OpenOneNoteCLI`: functioning foundation demonstrator, not the finished graphical application.
- `reconstruction/` and `specs/`: distinguish proposals from implementation. Library presence and pseudocode samples cannot establish feature parity.
- Git LFS owns original archives, compressed assembly, and compiled distributions. Keep them out of ordinary Git blobs.
- Do not upload third-party research to semantic indexes. Verify provider exclusion controls before indexing authored Sources, Tests, and Tools.

## Delivery And Tasks

Use a fresh feature worktree, direct self-review, `sh Tools/check.sh`, and a GitHub PR. This repository opts into the team-maintainer Beads profile for authorized commit/push/merge delivery; global safety rules still apply.

Beads owns live work: `bd prime`, `bd ready`, `bd show <id>`, then `bd update <id> --claim`. Initial task: `oon-0hm`. Discover the authoritative database with `bd where`; remote task synchronization is unverified and remains local-only until proven.

## Verification

`sh Tools/check.sh`: Swift tests, release build, CLI read/write and rejection paths, whitespace checks. Research additionally needs gzip validation, archive checksums, and `onenote-research verify` against the per-file inventory after extraction.

No Microsoft OneNote API/GUI interaction testing has run. Static analysis concentrates on the arm64 main binary, dependency inventories, and six sampled functions; Intel bytes are preserved with less analysis.
