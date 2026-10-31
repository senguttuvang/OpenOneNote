# Public Development And Release Guide

OpenOneNote uses this public repository for development, contributions, version tags and GitHub Releases. This guide defines release contents and records the remaining legacy-research boundary.

## One Repository

Work on focused branches, review the complete diff and run the full local gate on the exact branch before merging through a pull request. `main` is the integration branch; publish reviewed release assets under this repository's GitHub Releases. A separate public mirror or development repository is not required.

There are no packaged GitHub releases yet. Historical tags, files under `artifacts/` and a successful local build are not automatically reviewed release distributions. Build from source until an explicitly reviewed release is published.

## Current Repository Contents

The repository is public. Its tree, older commits and Git LFS pointers still contain or reference original Microsoft app archives, extracted assets, assembly and sampled pseudocode. O2N's MIT license covers independently authored code and documentation, with the exclusions in [THIRD_PARTY.md](THIRD_PARTY.md); it does not relicense those Microsoft materials.

**Legacy research remains an unresolved distribution concern.** Excluding it from a release asset does not remove its public Git/history/LFS exposure. Resolving that exposure requires a separate reviewed plan. Any destructive history or storage operation needs an appropriate backup, explicit owner authorization and coordination with existing clones and worktrees. Do not rewrite history, delete archives or change visibility as a documentation side effect.

## Select Release Assets

Select independently authored `Sources/`, `Tests/`, `Tools/`, Swift package manifests, the MIT license, dependency notices, README and contributor guide. Include the reviewed labels-only `specs/observed-menu-labels.json` fixture required by native menu tests. The app's generated notebook icon is independent; retain the bundled Mermaid license and upstream dependency notices.

Review other specifications, architecture documents and fixtures individually. The fictional screenshot and guide in `artifacts/previews/orbit-startup/` are used by the README and may accompany the selected source. Do not include unrelated artifact history.

Exclude Microsoft research and historical LFS archives, account/acceptance output, private notebooks and screenshots, source indexes, credentials, local agent state and unreviewed compiled packages. Build and run the full gate from the selected source tree to prove that excluded research is not a build input.

GitHub's automatic source-code archives follow the tagged tree; they are not source-only selections merely because a release has an MIT notice. Review the tag's contents and clearly identify any separately assembled source archive. A selected source archive can be attached to a release in this same repository without importing another repository's history.

## Verify A Release

- **Source and history:** inspect the exact commit/tag, selected files, LFS references and release assets. Do not treat previous tags or archived packages as cleared by a later release.
- **Secrets and privacy:** scan the intended tree/history with redacted reports retained outside the public distribution. Review binary/archive material and account metadata beyond the text scanner's coverage. Do not publish credentials or real notebook content.
- **License notices:** retain O2N's MIT notice and dependency/file-level notices. Binary distributions must include them and keep Microsoft research out of the app bundle. MIT does not grant trademark or third-party asset rights.
- **Local gate:** run `swift run --jobs 2 openonenote-dev check` on the exact candidate. For binaries, verify bundle contents, signature, architecture, source revision and archive checksum; describe signing and notarization accurately.
- **Compatibility claims:** distinguish native authentication, Graph transport, actual official-client edits and source/asset preservation. Tested examples do not establish production readiness or full OneNote parity.

## Repository Automation

GitHub Actions remains disabled. Public visibility does not authorize workflow dispatch, paid CI or a change to that policy; the local Swift gate remains required before merging.

Repository security scanning and push protection are separate from running Actions. Verify their actual settings, and verify the account's visibility guard through its owning account before changing its allowlist. An inaccessible guard is not proof that the repository is allowlisted.
