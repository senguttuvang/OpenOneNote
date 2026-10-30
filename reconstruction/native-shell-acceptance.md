# Native Shell Acceptance

Program source `87be99a` restores the OneNote for Mac shell around the Markdown editor, based on the original reference and the independently authored observed UI catalog. It includes the AppAuth foundation through `3743a31`. Beads: `oon-qar`.

## Implemented and verified

- Reference layout: 148pt title/tabs/ribbon, 47pt application rail, wide 250/301pt section/page columns, compact adaptation, reference neutral/purple colours, proportional reading content and monospace source. System light/dark appearance is supported.
- Observed native menu families/labels, four ribbons and contextual Table controls are retained. List, font/highlight/ink/paper galleries, paper ruling and the 10×8 insertion grid remain visible. Unsupported capabilities are disabled.
- Write/Split/Read preserve the same NSTextView, selection and native undo. Tests exercise Tamil/emoji UTF-16 formatting, undo/redo, paragraph styles, an eight-row/ten-column Markdown table, save/reopen, busy navigation and local hierarchy persistence.
- Account, notebook discovery, Preferences and sync/recovery are separate surfaces. Recovery comparison scrolls; actual failures stay visible. Cloud-wide sync is not substituted with page sync. New documents/hierarchy remain local.
- `openonenote-dev check` passed from the exact program worktree: 69 tests (8 + 9 + 41 + 11), release build, real native edit/undo/reopen and source identity checks, hidden native ribbon/mode/dialog/gallery renders, local Mermaid rendering and malformed rejection, CLI rejection, tamper and whitespace checks.
- `package-app` and `verify-app` passed: committed source metadata, resources/licenses, deep/strict signature, packaged native/diagram checks, archive gzip and SHA-256 verification. Archive: `artifacts/native/openonenote-app-arm64-87be99a.tar.gz`; SHA-256 `dec9eaf449c825c86577541f5f40ea43522deacdbf18a6b3cccdab304114afac`.
- Installed replacement used the existing safe installer after a normal save/quit, with no forced termination. The prior signed app and restore/checksum manifests were preserved in the centralized backup location. Installed source metadata is `87be99a`; executable SHA-256 is `3f3fdf19ff96cbae990eca53a4857ff57ff8618e630d672febde8aaf4a9a0bc3`, matching the package. Installed-path native Markdown and offline diagram checks passed. Launcher registration and Spotlight discovery were verified. Foreground process stayed unchanged across normal quit; no notes, settings or credentials were copied/replaced by installation.

## Visual review and measurements

Actual packaged SwiftUI/AppKit captures were compared with the supplied OneNote reference. Differences corrected during review included table cell geometry, light-mode heading contrast, ribbon height at compact widths, content reflow, font-field alignment, omitted galleries and standalone capture transparency. Synthetic content is used throughout; private reference screenshots and client notes are not committed.

A packaged native editing sample used 53,465 UTF-8 bytes, 400 synthetic sections and five diagram fences. Ten native insertions including parsing and synchronous persistence measured 15.6–17.1ms on this run. This excludes preview layout, diagram PNG regeneration and human typing latency, and is not an end-to-end performance claim.

The offline index was rebuilt at program revision `87be99a`: 160 hashed text files (73 authored, 80 static evidence, seven inferred pseudocode), with actual authored-symbol and research queries verified. Binary/archive/assets/account/screenshot content and the third-party Mermaid bundle remain excluded. This is lexical discovery with provenance, not a resolved compiler call graph or external semantic coverage.

## Review boundaries

Self-review checked document/view identity, Unicode selection, undo grouping, local/cloud creation boundaries, command scope, save-error visibility, busy configuration, menu target lifetime, callback forwarding and account/config separation. No Graph/auth/backend/package sources were modified in the UI delta.

This is a measured shell reconstruction, not full pixel or feature parity. Proprietary artwork/fonts/metrics and some inactive states differ. Rich-text attributes, native object/table layout commands, ink, recording/dictation and sharing remain unavailable. Full desktop keyboard traversal, VoiceOver and real popup interaction automation remain unverified; gallery components were rendered independently. Native authentication and official two-client cloud acceptance remain separate work, not established by local synthetic UI tests. GitHub Actions remains disabled; integration is stacked on the pending auth PR.
