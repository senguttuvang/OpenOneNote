# OpenOneNote

OpenOneNote preserves a private study of OneNote for Mac alongside an independent native Swift reconstruction.

## Findings

The captured **OneNote 16.114.1 / 16.114.26102031** is a native Mach-O application with AppKit/Objective-C, C++ Office infrastructure, Swift components, React Native integration, and embedded web capabilities. It is not evidenced as an Electron application. This Mac bundle cannot establish exact source-code overlap with Windows.

Read [the findings](research/findings.md), [architecture and reconstruction method](reconstruction/architecture-and-method.md), and [specification](specs/reconstruction.md).

## Contents

- **`research/originals/`**: complete installed app archive and complete top-level Resources archive in Git LFS, with SHA-256 checksums.
- **`research/extracted/16.114.1/`**: file hashes, Mach-O inventory, dependencies, signature, entitlements, symbols, Objective-C metadata/selectors, ribbon XML, strings, compressed full arm64 assembly.
- **`research/assets/16.114.1/`**: original icon, notices, Office JS API, and React Native bundles for direct inspection. All framework resources also remain in the app archive.
- **`research/decompiled/16.114.1/`**: six sampled Ghidra pseudocode exports and logs.
- **`reconstruction/` / `specs/`**: design, sequencing, compatibility strategy, acceptance criteria.
- **`Sources/` / `Tests/`**: independent Swift code and tests.
- **`artifacts/native/`**: compiled foundation distribution and provenance. This milestone is a CLI/core build; the graphical notebook application is future work.

## Run The Swift Foundation

Requires macOS 14 or newer and Swift 6. Microsoft binaries are unnecessary for building and testing.

```sh
git clone git@github.com:senguttuvang/OpenOneNote.git
cd OpenOneNote
sh Tools/check.sh
swift run openonenote create-demo /tmp/openonenote-demo.json
swift run openonenote inspect /tmp/openonenote-demo.json
```

`create-demo` refuses to overwrite an existing path. The foundation has stable IDs, sections, pages, positioned text blocks, geometry validation, versioned JSON, and atomic saves. Rich-text editing and sync remain proposed.

## Retrieve Research Archives

```sh
git lfs install
git lfs pull
shasum -a 256 -c research/originals/SHA256SUMS
```

The new Swift code does not load original Microsoft assets. See [research reproduction](research/README.md) and [ownership](THIRD_PARTY.md). No user notebooks, account records, credentials, or OneNote caches are included.
