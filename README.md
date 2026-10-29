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

Requires macOS 14 or newer and Swift 6. The original Microsoft OneNote research archives are unnecessary for building and testing. SwiftPM pins the AppAuth authentication dependency.

```sh
git clone git@github.com:senguttuvang/OpenOneNote.git
cd OpenOneNote
swift run openonenote-dev check
swift run openonenote-dev app
swift run openonenote-dev verify-app
swift run openonenote-dev install-app
open ~/Applications/OpenOneNote.app
```

Normal launch opens the Markdown workspace at `~/Library/Application Support/OpenOneNote/Markdown`. Use `OpenOneNoteMac --vault /path/to/vault` for another vault. Source and reading preview support common formatting, tables, images/attachments and locally rendered Mermaid. Files save offline; explicit sync performs baseline/local/remote reconciliation, protects unsupported objects, updates supported children of the same page and verifies readback. Background refresh is read-only. Conflicts retain all three copies and expose resolution history. Relink a moved note from its context menu; missing pages/files never imply deletion.

Save and quit O2N before `install-app`. It refuses replacement while any O2N instance is running, preserves the prior app under `~/Backups/OpenOneNote/` with a restore manifest, stages the replacement and verifies its signature/checksum. Notes, preferences and Keychain items stay in their existing locations. Use one running build for native custom-scheme authentication; an older installed copy sharing the same bundle identity can receive a development build’s return URL. The current split-pane shell still requires the separately requested original-OneNote-style UI integration; these auth/sync changes do not establish visual or interaction parity.

Microsoft connection uses O2N's own delegated AppAuth identity and app-private macOS Keychain item. With explicit provisioning authority, run `swift run openonenote-dev microsoft-register /absolute/path/to/az /path/to/vault <tenant-id> <site-id>`. It verifies Azure's tenant and the exact SharePoint target, creates or reuses the separate **OpenOneNote** single-tenant public-client registration, and verifies its callback, service principal and delegated `Notes.ReadWrite` permission. It does not change the shared CloudOps registration, create a secret or grant tenant-wide consent. Click **Microsoft connection → Sign in**, then load the selected site’s notebook, section and page. SharePoint roots use `sites/<id>`; this registration intentionally supports the selected organization only.

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

## Native Sign-In And Cloud Verification

AppAuth uses authorization code flow with PKCE, state, nonce and offline access through the system browser. Its secure state archive is stored in a nonsynchronizing, app-private macOS login Keychain item, scoped to the O2N registration and tenant. There is no shared Keychain group or plaintext fallback. Apple developer membership is not an OAuth prerequisite. An existing signing identity can be supplied with `O2N_SIGNING_IDENTITY`; the local default is an integrity-checked ad-hoc build. macOS may require explicit access approval when a new build reads its previous Keychain item; background reads never request interaction.

```sh
swift run openonenote-dev app
swift run openonenote-dev verify-app
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --cloud-sign-in /path/to/configured/vault
dist/OpenOneNote.app/Contents/MacOS/OpenOneNoteMac --cloud-status /path/to/configured/vault
```

`--signing-status` checks executable integrity without reading credentials. `--cloud-sign-in` opens a dedicated human consent window; `--cloud-status` verifies saved native authentication and delegated Notes access without cloud writes. `--cloud-roundtrip /path/to/configured/test-vault` creates a new synthetic SharePoint notebook/section/page, edits through the actual native source editor and session save/sync path, verifies same-page formatted/table Graph readback, and waits for a separate marker entered in the **official OneNote editor**. It checks that polling pulls that marker into native Markdown/preview while retaining the original marker/table and single page identity. Registry, URLs, expected markers and native renders remain local under `.o2n/acceptance`; existing notes are untouched and fixtures are retained. Official UI rendering/provenance must be checked separately; Graph PATCH never substitutes for an official-client edit.

Selected pages refresh read-only on open, focus and wake. Background metadata polling adapts from 15 to 120 seconds, with a full content check at least every 120 seconds even if timestamps do not change. Errors back off to 300 seconds and honor longer `Retry-After` instructions. Explicit sync rechecks content before a write. OneNote page webhooks/delta are not documented; SharePoint library notifications require separate validation and cannot replace content reconciliation. See [the refresh contract](reconstruction/markdown-first-architecture.md#recovery-and-refresh).

Local notes can be created with Command-N and existing vault Markdown opened with Command-O. Existing file bytes are preserved when first adopted. External file changes and interrupted saves retain both copies for explicit reload/overwrite resolution; note identity survives explicit relinking after a move.

A separate `swift run openonenote-dev graph-probe /absolute/path/to/m365 /new/synthetic-output` command uses the sanctioned CLI's delegated session to test newly created synthetic fixtures without exporting tokens. Its text/table, refresh/reconnect and conflict readback is explicitly separate from native authentication and official-client acceptance. Existing notes remain read-only for automated experiments; generated fixture IDs stay in the private output directory.
