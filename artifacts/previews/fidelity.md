# Dark native fidelity verification — 25 October 2026

Source build: `be794c51d41c12ea573f09bc38df9071c05736b7`, app version 0.2.0. The private user screenshot remains outside the repository; all committed previews contain synthetic Field Notes content.

## Native renders

Inspected real owned-view renders at 1728×1088, 1280×800 and 960×800, using prohibited app activation and hidden windows. Output is one pixel per logical point. Inspected additional private crops of the ribbon/navigation and note text; no foreground app, tab or Space was switched. Normal launch additionally uses macOS window chrome.

At reference size, visual boundary checks give ribbon bottom y148 (reference approximately149), rail x47, section/page divider x297, canvas x598 and container x670/y247 (reference approximately x670/y248). Title begins x646/y175 (reference approximately x646/y176). Column and canvas geometry closely match; pixels, text metrics and complete interaction parity do not.

The native note shows a bordered table, blue headings, link underline, a single bullet per list paragraph, and readable light text on a dark surface. At 960pt, fixed document geometry extends past the viewport; horizontal scrolling is intentional and visible. Controls and creation rows remain within the window. Ribbon actions are disabled until a text container is focused.

Differences: smaller set of ribbon groups; local save replaces cloud/share actions; system symbols replace proprietary assets; title underline width, header naming field, table dimensions, typography, list spacing and note length differ. No ink, dictation, tags, cloud sharing, zoom, import or synchronization is claimed. VoiceOver and full desktop keyboard traversal remain unverified.

## Functional and package evidence

`swift run openonenote-dev check`: 22 tests, no skips; release build; native Unicode editing, bold and undo/redo; selection/caret formatting; list type switching; links; table RTF persistence; save/reopen; geometry undo; corruption/save failure recovery; three render sizes; CLI rejection; tamper rejection; authored whitespace checks.

`swift run openonenote-dev package-app` and `verify-app`: ad-hoc deep/strict code signature passed, packaged binary native self-test passed, three preview files produced. Archive gzip validation and adjacent SHA-256 validation passed. This is an unsigned-for-distribution development identity, not a notarized release.

## Offline index evidence

At the source build revision, the local Swift index contains 111 hashed UTF-8 text files: 24 authored source/test/tool files and 87 research text files, including all six sampled Ghidra C-like files. Four files skipped: two `.log` files, binary Info.plist, compressed full arm64 assembly. Archives, original assets, screenshot, notebooks and account stores are outside the allowlist. No semantic provider upload occurred.

Representative verified queries return `formatSelection` definitions/call sites, `ribbon kOUIGallery` metadata keys, `objc-selectors boldSystemFont` at selector line3652, and the `10026dbe8` sampled pseudocode with provenance. Index tests reject changed/added source files and forged cached text. The index is lexical; it does not resolve a compiler call graph or recover original source.

Direct self-review and a bounded read-only review found list-type switching and caret-formatting state defects, both corrected with regression assertions. Final review: ship after the exact-final local gate. GitHub Actions remains disabled.
