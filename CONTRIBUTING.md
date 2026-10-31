# Hacking On OpenOneNote

This guide helps developers build O2N, find the right module and contribute native Mac editing or OneNote compatibility improvements without risking existing notebooks.

## Build And Run

Use macOS 14 or newer and Swift 6. Apple Silicon is the verified platform. Archived research and historical app packages are not build inputs; `GIT_LFS_SKIP_SMUDGE=1` avoids downloading them during a clone.

```sh
swift run --jobs 2 openonenote-dev check
swift run --jobs 2 openonenote-dev app
swift run --jobs 2 openonenote-dev verify-app
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --vault /absolute/path/to/disposable-vault
```

Run `swift run openonenote-dev help` for supported commands. `check` runs unit tests, the release build, hidden native editing/formatting/undo/save/reopen checks, diagram rendering, CLI rejection and evidence-integrity checks. It uses synthetic fixtures and needs no Microsoft account. `verify-app` checks an assembled bundle and writes native preview receipts; keep generated receipts out of unrelated changes.

Developer workflows are written in Swift and invoke native tools through a typed process boundary. Extend `DevelopmentKit` instead of adding shell, Python or JavaScript build scripts. GitHub Actions is deliberately disabled; do not enable or dispatch it as part of a contribution.

## Choose A Starting Point

- **UI and rich editing — `MarkdownEditor`:** SwiftUI shell, AppKit text views, inline titles, selection/undo, ribbon controls, source/reading views and local Mermaid rendering. Markdown is a capability inside the same notebook experience.
- **Documents and sync — `MarkdownNotes`:** semantic nodes, Markdown/HTML conversion, assets, vault persistence, sync baselines, source-aware diagrams, conflicts and refresh policy. Vendor DOM types stop at the converter.
- **Microsoft access — `OneNoteGraph`:** Graph adapter and delegated AppAuth identity. Credentials belong in the app-private Keychain, not files, diagnostics or fixtures.
- **Earlier notebook model — `NotebookCore`, `NotebookPersistence`, `NotebookEditor`:** preserve existing JSON/RTF notes and independent interfaces. `NotebookCore` imports Foundation only.
- **Composition and tools — `OpenOneNoteMac`, `DevelopmentKit`, `OpenOneNoteDev`:** lifecycle, URL callbacks, build, packaging, signing and installation. Packaging must not depend on archived research.

Read [the UI design](DESIGN.md), [native-shell specification](specs/native-shell.md), and [document/sync architecture](reconstruction/markdown-first-architecture.md). The native rich-editor default supersedes older source-editor-first wording. Specifications describe intent; acceptance records distinguish implemented workflows from unverified interoperability.

## Try Cloud Integration Carefully

Use your own Microsoft public-client registration and a disposable test vault/notebook. The current setup path targets an organizational tenant and explicitly selected SharePoint site. Tenant consent policies may require administrator involvement. Do not reuse another developer's configuration, credentials or acceptance directory.

```sh
swift run openonenote-dev microsoft-register /absolute/path/to/az /absolute/path/to/test-vault <tenant-id> <site-id>
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --cloud-sign-in /absolute/path/to/test-vault
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --cloud-status /absolute/path/to/test-vault
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --cloud-roundtrip /absolute/path/to/test-vault
```

Inspect setup and confirm the target before provisioning: it can create a directory app registration/service principal. Use only required delegated Notes permissions; no client secret is needed. Human login, MFA and consent stay with the account owner. Run one build with the registered bundle/callback identity during sign-in. Keep configuration, Keychain state and `.o2n` acceptance output private.

`--cloud-roundtrip` creates new synthetic cloud fixtures and expects a marker entered through the actual official OneNote editor. Fixtures are retained. Native authentication, Graph readback, official-client rendering/edits, identity and downloaded source/asset preservation are separate assertions. CLI `graph-probe` uses a different delegated transport and cannot prove native sign-in or an official-client edit. Never use somebody's existing notes as automated write fixtures.

## Protect Compatibility

- Retain unsupported objects and both sides of a conflict; do not silently flatten or delete content to make sync pass.
- Keep Markdown source, rendered content, asset hashes and metadata responsibilities explicit. Official OneNote may normalize HTML or change attachments; validate what actually survived.
- Exercise selection, Unicode, undo/redo and save/reopen when changing text editing. Use real native controls where behaviour matters; screenshots alone cannot establish interaction parity.
- Use synthetic screenshots, logs and bug reports. Report sanitized error codes and reproduction steps, not callbacks, authorization headers, tokens, account stores or private notebook contents.

## Send A Contribution

Use a focused branch or isolated worktree. Maintainers and automated agents follow `AGENTS.md` and the local Beads ledger; remote Beads synchronization must be proven before treating it as shared state. Coordinate ownership of shared app/session, package or installation files.

Before a pull request, inspect the complete diff, run the full local check from the exact branch/worktree, and explain the user-visible change, verification and remaining limits. Preserve existing notes/research and keep generated artifacts out of unrelated patches. Contributions must be independently authored or compatibly licensed, with upstream notices retained; see [THIRD_PARTY.md](THIRD_PARTY.md). AI-assisted contributions follow `AGENTS.md` attribution rules.

Native developer binaries use an integrity-checked ad-hoc signature unless a developer identity is supplied. Building locally is separate from publishing a signed/notarized binary. Save and quit the installed app before using the safe installer; never terminate another person's editing session or overwrite a running build.
