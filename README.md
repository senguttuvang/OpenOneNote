# OpenOneNote

OpenOneNote preserves a private study of OneNote for Mac alongside an independent, local-first native Swift notebook editor.

## Findings

The captured **OneNote 16.114.1 / 16.114.26102031** is a native Mach-O application with AppKit/Objective-C, C++ Office infrastructure, Swift components, React Native integration, and embedded web capabilities. It is not evidenced as an Electron application. This Mac bundle cannot establish exact source-code overlap with Windows.

Read [the findings](research/findings.md), [architecture and reconstruction method](reconstruction/architecture-and-method.md), and [specification](specs/reconstruction.md).

## Contents

- **`research/originals/`**: complete installed app archive and complete top-level Resources archive in Git LFS, with SHA-256 checksums.
- **`research/extracted/16.114.1/`**: file hashes, Mach-O inventory, dependencies, signature, entitlements, symbols, Objective-C metadata/selectors, ribbon XML, strings, compressed full arm64 assembly.
- **`research/assets/16.114.1/`**: original icon, notices, Office JS API, and React Native bundles for direct inspection. All framework resources also remain in the app archive.
- **`research/decompiled/16.114.1/`**: six sampled Ghidra pseudocode exports and logs.
- **`reconstruction/` / `specs/`**: design, sequencing, compatibility strategy, acceptance criteria.
- **`Sources/` / `Tests/`**: independent Swift notebook core, persistence, AppKit/SwiftUI editor, development CLI, and tests.
- **`artifacts/native/`**: compiled `.app` and earlier foundation distributions, checksums, and provenance.
- **`artifacts/previews/`**: background renders of the real native views at wide and compact window sizes.

## Build And Open The Mac App

Requires macOS 14 or newer and Swift 6. Microsoft binaries are unnecessary for building and testing.

```sh
git clone git@github.com:senguttuvang/OpenOneNote.git
cd OpenOneNote
swift run openonenote-dev check
swift run openonenote-dev app
swift run openonenote-dev verify-app
open dist/OpenOneNote.app
```

The dark native alpha supports notebook/section/page navigation and naming, positioned/resizable rich-text containers, ribbon font/size and character formatting, headings, list paragraph styles, selected-text links, bordered native table insertion, the Mac font panel, undo/redo, and debounced atomic local saves. Normal launch stores its notebook at `~/Library/Application Support/OpenOneNote/notebook.json`; an explicit file can be selected with `OpenOneNoteMac --notebook /path/to/notebook.json`.

**Local-first is the confirmed priority.** Import, OneNote cloud synchronization, ink, attachments, search, section groups, and complete OneNote feature parity are later milestones. The current store is single-writer JSON with an RTF payload for native text formatting. Undo history is scoped to the active page and resets on navigation. Corrupt files are preserved; save failures retain in-memory edits for retry. This is a development alpha, not a production replacement for valuable notebooks.

All project-owned build, verification, packaging, and capture orchestration is Swift. `openonenote-dev` invokes native tools with separate argument arrays. The local check command is the CI-equivalent gate. **GitHub Actions is disabled and its workflow removed to avoid Actions-credit consumption.** There are no maintained shell workflow scripts. Ghidra's exporter remains Java because it runs inside Ghidra's scripting API.

## Foundation And Research Tools

```sh
swift run openonenote create-demo /tmp/openonenote-demo.json
swift run openonenote inspect /tmp/openonenote-demo.json
swift run openonenote-dev package-app
swift run openonenote-dev source-index
swift run openonenote-dev source-query "ONPageView"
swift run openonenote-dev help
```

`create-demo` refuses to overwrite existing data. Packaging requires committed program sources and refuses to overwrite an existing archive. See [the native build guide](artifacts/native/README.md), [design](DESIGN.md), and [existing Swift project references](reconstruction/swift-foundation-references.md).

The [offline source index](reconstruction/indexing.md) covers authored Swift and static extracted/decompiled research text with hashes and provenance. It never uploads content or reads account stores. It is lexical search, not a semantic embedding index. Wide and compact native previews document a close layout reconstruction, not exact OneNote parity.

## Retrieve Research Archives

```sh
git lfs install
git lfs pull
shasum -a 256 -c research/originals/SHA256SUMS
```

The new Swift code does not load original Microsoft assets. See [research reproduction](research/README.md) and [ownership](THIRD_PARTY.md). No user notebooks, account records, credentials, or OneNote caches are included.
