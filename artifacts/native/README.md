# Native Swift Foundation Build

This directory retains independent native Swift app/tool builds alongside reproducible source and checksums. The current graphical app is a local-first editing alpha, with an ad-hoc development signature and no notarization.

`openonenote-app-arm64-<revision>.tar.gz` contains `OpenOneNote.app`. Extract it to a new directory and open the app. Requires Apple Silicon and targets macOS 14 or newer; Intel builds have not been verified. The app's resource manifest records the committed source revision. The earlier `openonenote-foundation-*` archives preserve the initial CLI-only milestones, including a synthetic notebook and original build metadata.

The retained 26 October Markdown-first build is [openonenote-app-arm64-34c9809.tar.gz](openonenote-app-arm64-34c9809.tar.gz), version 0.3.0 (build 4). Its adjacent checksum and [verification receipt](../previews/verification.json) identify those committed program sources. [Markdown previews](../previews/markdown-v1/) show hidden native source and reading views, plus the actual rendered diagram PNG. That historical MSAL archive supports offline editing and encountered a private-Keychain signing requirement; it does not contain the subsequent dedicated AppAuth identity implementation. Build current sources with `swift run openonenote-dev app` for the app-private macOS Keychain implementation. Native authentication, API checks and official-client acceptance remain separately reported evidence.

The earlier [0.3.0 integration build](openonenote-app-arm64-f717d72.tar.gz) and [0.2.0 canvas build](openonenote-app-arm64-be794c5.tar.gz) remain available. The canvas build's [fidelity evidence](../previews/fidelity.md) describes its earlier scope. Earlier 0.1.0 and 0.1.1 graphical builds are retained. Version 0.1.1 introduced explicit actor callbacks to avoid a Swift 6.1 compiler crash; that protection remains.

Retrieve the archive with `git lfs pull`, validate its adjacent `.sha256` file, extract to a new directory, and open `OpenOneNote.app`. The executables do not need the original Microsoft archives. The earlier foundation CLI archive separately includes `example-notebook.json`.

Build and verify with `swift run openonenote-dev check`; assemble the app with `swift run openonenote-dev app`; archive committed sources with `swift run openonenote-dev package-app` or `package-tools`. The embedded revision identifies the program source; later artifact/documentation commits may leave those program sources unchanged. No project shell scripts are required.
