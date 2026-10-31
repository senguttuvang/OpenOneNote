# Public Source Release Boundary

This maintainer guide defines what may be selected for an MIT-licensed O2N source release and why the private development repository must not be made public unchanged.

## Publish O2N's Code, Not The Research Archive

The root MIT license covers independently authored O2N code and documentation, with the exclusions in [THIRD_PARTY.md](THIRD_PARTY.md). The private repository and its history contain Microsoft app archives, original assets, extracted code/assembly and sampled pseudocode. A license file or deletion in the latest commit does not remove them from older commits, branches, tags or Git LFS storage.

**Keep this repository private until a reviewed publication candidate excludes those materials.** A source-only repository with fresh history is the preferred path: preserve the private research repository, then publish only reviewed O2N files. Rewriting or replacing existing history is a separate, explicitly approved operation requiring backups; this preparation does not authorize it.

## Source-Only Selection

Start with independently authored `Sources/`, `Tests/`, Swift package manifests, the MIT license, dependency notices, README and contributor guide. The app's generated icon is independent; retain the Mermaid license and retrieve SwiftPM dependencies with their notices.

Review design/specification and architecture documents individually before selection. Source/tool code also needs a privacy and provenance check; an allowlist is a starting point, not evidence that every file is cleared. Build and run the full local gate in the source-only checkout so missing research is proved harmless.

Exclude original Microsoft material under `research/`, historical research archives/LFS pointers, private account/acceptance output, source indexes, local agent state, credentials and screenshots of real notebooks. Historical compiled packages and captures under `artifacts/` are not automatically approved releases; assemble and review fresh artifacts separately. The README explicitly uses the fictional O2N-only images and accompanying explanation in `artifacts/previews/orbit-startup/`; include that reviewed directory in a source-only selection so the README's images resolve, without including unrelated artifact history.

## Review The Whole Publication Surface

- **History and storage:** inspect all refs being published, Git LFS objects, tags, releases, attached assets, issue/PR content and screenshots. Do not push private refs into a source-only repository.
- **Secrets and privacy:** scan the selected tree and entire intended history, with redacted reports retained privately. Also review archived/binary material, account identifiers, fixtures and metadata outside the text scanner's coverage. A clean text scan alone is insufficient.
- **Licensing and branding:** retain dependency/file-level notices and exclude Microsoft-derived material. Verify independent O2N branding. MIT does not grant Microsoft or Apple trademark/asset rights.
- **Claims:** native sign-in reuse, actual official-client edits and O2N-specific source/asset preservation need live acceptance. Transport tests do not establish production interoperability or full OneNote parity.
- **Delivery:** run `swift run --jobs 2 openonenote-dev check` on the exact candidate. Inspect bundle contents/notices for binary releases; describe signing/notarization and architecture support accurately.

## Visibility And Automation

An owner performs the final GitHub visibility change manually after review. Do not change visibility through agent CLI/API/browser automation. Before that change, verify whether the account's visibility guard requires an approved allowlist entry. Do not change the guard or its baseline as a documentation side effect.

GitHub Actions stays disabled. Public visibility does not authorize workflow dispatch, paid CI or broader automation. The LinkedIn announcement is a separate unpublished draft; review it against the actual public repository and current compatibility status before posting.
