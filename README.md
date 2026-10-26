# OpenOneNote

O2N is a native Swift Markdown workspace for existing Microsoft OneNote cloud pages. Portable `.md` files and assets are the local source of truth; delegated Microsoft Graph opens and updates the same page. The earlier canvas editor and private static research remain preserved.

The current product contract is [Markdown-first editing](specs/markdown-first.md), with [architecture and verification boundaries](reconstruction/markdown-first-architecture.md). Cloud authentication and live acceptance evidence are separate from local test results; this remains a development build until those gates are recorded.

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

Requires macOS 14 or newer and Swift 6. The original Microsoft OneNote research archives are unnecessary for building and testing. SwiftPM downloads the supported MSAL authentication dependency.

```sh
git clone git@github.com:senguttuvang/OpenOneNote.git
cd OpenOneNote
swift run openonenote-dev check
swift run openonenote-dev app
swift run openonenote-dev verify-app
open dist/OpenOneNote.app
```

Normal launch opens the Markdown workspace at `~/Library/Application Support/OpenOneNote/Markdown`. Use `OpenOneNoteMac --vault /path/to/vault` for another vault. Source and reading preview support common formatting, tables, images/attachments and locally rendered Mermaid. Files save offline; explicit sync performs baseline/local/remote reconciliation, protects unsupported objects, updates supported children of the same page and verifies readback. Background refresh is read-only. Conflicts retain all three copies and expose resolution history. Relink a moved note from its context menu; missing pages/files never imply deletion.

Microsoft connection uses O2N's own delegated MSAL identity and private Keychain cache. Configure an approved client or run `swift run openonenote-dev microsoft-setup /absolute/path/to/m365 /path/to/vault` with the sanctioned Microsoft 365 CLI. Setup verifies existing registration metadata and can append only O2N's native callback through existing same-tenant authority, preserving callbacks/scopes and centralized rollback evidence. It never grants new permissions or extracts credentials. Click **Microsoft connection → Sign in**, then load a notebook, section and existing page. SharePoint roots use `sites/<id>`; personal/work/school support depends on the approved registration's audience and consent.

Mermaid sync uploads a PNG fallback and a hash-bound source attachment. New vaults recover source only when the downloaded source and image match. A remotely changed diagram is retained as an image with a stale-source warning; pixels are never treated as editable source.

Legacy JSON/RTF notebooks are untouched. Open them with `OpenOneNoteMac --legacy` or `--notebook /path/to/notebook.json`. That mode retains the earlier rich-text canvas controls. Full OneNote parity, handwriting, binary `.one` parsing and CSI/FSSHTTP are outside this milestone. The Graph read/recheck/write sequence has a residual concurrency race; no transactional or ETag guarantee is claimed.

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

## Native credential signing

MSAL's private macOS Keychain requires an approved Apple developer signing identity and matching provisioning profile. An ad-hoc build remains an offline Markdown editor; it reports the native-auth requirement before querying credentials. Package a native-auth-capable build with an existing Keychain identity/profile:

```sh
O2N_SIGNING_IDENTITY='Approved identity in Keychain' O2N_PROVISIONING_PROFILE=/path/to/O2N.provisionprofile swift run openonenote-dev app
swift run openonenote-dev verify-app
```

The profile must authorize this app/team/private Keychain group and be unexpired. No first-party credential extraction, plaintext token fallback, broadened permission scope or invalid ad-hoc entitlement is used. `OpenOneNoteMac --signing-status` checks capability without reading credentials. `--cloud-status /path/to/configured/vault` checks native MSAL plus delegated Notes access without writing cloud notes. `--cloud-self-test /path/to/configured/test-vault` creates and retains a clearly named synthetic notebook/section/page, records its IDs locally, and exercises same-page readback, diagram source recovery, refresh, offline reconnect and conflicts. It never targets pre-existing pages or deletes fixtures. Graph readback does not establish native OneNote visual fidelity.

Local notes can be created with Command-N and existing vault Markdown opened with Command-O. Existing file bytes are preserved when first adopted. External file changes and interrupted saves retain both copies for explicit reload/overwrite resolution; note identity survives explicit relinking after a move.

A separate `swift run openonenote-dev graph-probe /absolute/path/to/m365 /new/synthetic-output` command uses the sanctioned CLI's delegated session to test newly created synthetic fixtures without exporting tokens. Its successful text/table, refresh/reconnect and conflict readback is explicitly separate from native MSAL and image/diagram acceptance. Existing notes remain read-only for automated experiments; generated fixture IDs stay in the private output directory.
