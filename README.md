# OpenOneNote · O2N

**A native Mac notebook with a familiar OneNote experience and portable Markdown.** OpenOneNote is an independent app built with Swift, AppKit and SwiftUI. Its Microsoft Graph integration is designed to read and update the same OneNote cloud pages used by Microsoft's official clients, while adding capabilities that OneNote does not offer natively.

O2N's independently authored code is available under the [MIT license](LICENSE), including for personal and commercial use. Microsoft and other third-party materials retain their own rights; see [third-party notices](THIRD_PARTY.md). O2N is not affiliated with or endorsed by Microsoft or ArtCraft.

## For People Who Use OneNote

- **A familiar place to write.** Notebook, section and page navigation, a ribbon, light/dark appearance, native rich-text editing, and immediate inline page creation. Add a page and type its title in place.
- **Markdown when you want it.** The Markdown/code icon in the Home ribbon opens source, split and reading views for the same page. Ordinary writing stays in the native rich editor.
- **Files you can keep.** Notes and assets live locally as portable Markdown and companion files. Local editing and offline Mermaid diagram rendering do not require Microsoft sign-in.
- **The same cloud notebook.** The sync implementation targets existing OneNote pages through delegated Microsoft Graph access, rather than exporting a separate copy into another note service.

**Current stage: developer preview.** Native local editing and Graph transport/recovery paths have automated coverage. A synthetic native O2N ↔ official OneNote web-editor roundtrip passed on 31 October, including same-page identity, table/image/diagram-source preservation and an observed 81-second return refresh. Separate offline/reconnect/conflict checks passed. The final installed build also verified saved-identity reuse and synthetic asset downloads; ad-hoc development updates can require renewed macOS Keychain approval. See the [precise acceptance and deployment boundaries](reconstruction/oauth-sharepoint-acceptance.md). O2N does not yet promise production-ready interoperability, complete OneNote feature parity, or lossless handling of every OneNote page.

## For Teams And Business Users

The aim is to let colleagues keep using official OneNote while Mac users gain Markdown and code-oriented tools over the same supported pages. Microsoft still hosts the cloud notebook; organizational access and consent policies still apply. O2N uses delegated user access, not an embedded client secret or a separate O2N cloud service.

MIT permits internal use, modification and commercial distribution with its notices retained. It does not replace Microsoft's service terms, account requirements, or your organization's security review. Start evaluations with a disposable notebook and retained originals; this preview has no enterprise support or service-level commitment.

## Working Alongside Official OneNote

### Shared Content

O2N converts supported content to OneNote-compatible HTML and resources and updates the existing cloud page by identity. Supported editing includes common formatting, headings, simple lists, links and basic tables; image/attachment transport and diagram preservation have separate checks. Unsupported remote objects are protected from destructive rewrites. Overlapping edits retain local, remote and baseline copies for recovery.

The current integration is oriented toward configured organizational SharePoint notebooks. Other account/tenant combinations need their own acceptance tests. Handwriting, arbitrary spatial layouts, `.one` binary import, native OneNote synchronization protocols, and full feature/transition parity are not implemented compatibility guarantees. Cloud title mutation and structural table editing also remain limited.

### Keeping O2N's Extra Information

OneNote does not understand every Markdown structure or O2N enhancement. O2N therefore keeps two representations with different responsibilities:

- **Local source and metadata:** Markdown files, assets and a local `.o2n` ledger retain note identity, sync baselines and recovery state. Local metadata is not automatically understood by official clients or guaranteed to travel to another device.
- **Compatible cloud content:** official OneNote receives supported HTML, images and attachments. Mermaid diagrams use a rendered PNG plus an attached source file whose name binds the source and preview hashes. O2N recovers editable diagram source only when both downloaded files still match.

If an official-client edit changes a diagram preview or source, O2N preserves the available image and attachment and reports stale source instead of inventing editable Markdown. Other edits may normalize Markdown syntax or exceed the supported rich-text subset. The synthetic two-client test recovered original image bytes and editable Mermaid source from a fresh vault after the official edit. This is a tested preservation strategy, not a guarantee that every O2N-specific structure or metadata field survives every official-client edit.

### Refresh And Authentication

Selected pages refresh on open, focus and wake. Adaptive metadata polling runs at 15–120 seconds, with periodic full-content reconciliation, error backoff and `Retry-After` handling. This is polling, not an instant or transactional sync promise; a read/recheck/write race remains possible.

Microsoft connection uses O2N's own public-client OAuth registration, AppAuth authorization-code flow with PKCE, and an app-private macOS Keychain item. Account setup is separate from local editing. Developers use their own registration and tenant configuration; no maintainer credentials or tenant configuration are included.

## Build And Try It

Requires **macOS 14 or newer**, a Swift 6 toolchain, Git and access to SwiftPM dependencies. Apple Silicon is the verified build target; Intel delivery is not yet verified. Current local builds are development-signed and not notarized.

```sh
# Historical LFS archives are not needed to build O2N.
GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/senguttuvang/OpenOneNote.git
cd OpenOneNote
swift run --jobs 2 openonenote-dev check
swift run --jobs 2 openonenote-dev app
swift run --jobs 2 openonenote-dev verify-app
open dist/OpenOneNote.app
```

Normal launch uses `~/Library/Application Support/OpenOneNote/Markdown`. To try a separate workspace:

```sh
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --vault /absolute/path/to/test-vault
```

To install a verified build, save and quit O2N, then run `swift run --jobs 2 openonenote-dev install-app`. The installer refuses a running O2N instance, backs up the previous app and verifies the replacement. Notes, settings and authentication stores are not replaced. Avoid running multiple builds with the same bundle identity during native sign-in.

## Developers: Hack On O2N

Start with [CONTRIBUTING.md](CONTRIBUTING.md) for build commands, module boundaries, synthetic fixtures, sync setup and contribution expectations.

- **Native UI and editing:** `Sources/MarkdownEditor`; the rich editor and Markdown views share the page model. `Sources/NotebookEditor` preserves the earlier editor.
- **Portable notes and compatibility:** `Sources/MarkdownNotes`; parsing, HTML conversion, assets, diagram recovery, conflict handling and the local vault.
- **Microsoft integration:** `Sources/OneNoteGraph`; delegated identity, secure credential storage and Graph transport.
- **Build and verification:** `Sources/DevelopmentKit` and `Sources/OpenOneNoteDev`; Swift-native workflows and packaging. No Microsoft binaries or archived research are required to build or run the app.

Issues and focused pull requests are welcome, especially for native editing, accessibility, compatibility fixtures and reproducible sync failures. Use synthetic notes in bug reports; never attach credentials, personal notebooks or tenant configuration. GitHub Actions remains disabled; the full local check is the merge gate.

## Related Open-Source Work

[ArtCraft's Crafting Apps](https://getartcraft.com/apps) bring familiar creative and office workflows to open-source native applications. Their published lineup includes [WordCraft](https://github.com/storytold/wordcraft) for word processing, [GridCraft](https://github.com/storytold/gridcraft) for spreadsheets, and [DeckCraft](https://github.com/storytold/deckcraft) for presentations; it currently does not list a OneNote counterpart.

O2N is an independent effort to fill that notebook-workflow gap on macOS, using Swift and Apple's native frameworks, with OneNote interoperability and Markdown enhancements as its focus. These links acknowledge related work; they do not imply shared code, integration or endorsement.

## License And Release Preparation

See [LICENSE](LICENSE) for O2N's MIT terms and [THIRD_PARTY.md](THIRD_PARTY.md) for dependencies and exclusions. The private development repository also retains Microsoft research materials that are **not** covered by MIT and must not be included in a public source distribution. Maintainers must follow [the public-release boundary](PUBLIC_RELEASE.md) before publishing this repository or its history. Adding a license does not make those materials redistributable.
