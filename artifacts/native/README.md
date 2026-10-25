# Native Swift Foundation Build

This directory retains independent native Swift app/tool builds alongside reproducible source and checksums. The current graphical app is a local-first editing alpha, with an ad-hoc development signature and no notarization.

`openonenote-app-arm64-<revision>.tar.gz` contains `OpenOneNote.app`. Extract it to a new directory and open the app. Requires Apple Silicon and targets macOS 14 or newer; Intel builds have not been verified. The app's resource manifest records the committed source revision. The earlier `openonenote-foundation-*` archives preserve the initial CLI-only milestones, including a synthetic notebook and original build metadata.

The recommended build is [openonenote-app-arm64-be794c5.tar.gz](openonenote-app-arm64-be794c5.tar.gz), version 0.2.0, with the dark native ribbon and expanded local editing. Its adjacent checksum, [preview verification](../previews/verification.json) and [fidelity evidence](../previews/fidelity.md) record the source and test scope. Earlier 0.1.0 and 0.1.1 graphical builds are retained. Version 0.1.1 introduced explicit actor callbacks to avoid a Swift 6.1 compiler crash; that protection remains.

Retrieve the archive with `git lfs pull`, validate its adjacent `.sha256` file, extract to a new directory, and open `OpenOneNote.app`. The executables do not need the original Microsoft archives. The earlier foundation CLI archive separately includes `example-notebook.json`.

Build and verify with `swift run openonenote-dev check`; assemble the app with `swift run openonenote-dev app`; archive committed sources with `swift run openonenote-dev package-app` or `package-tools`. The embedded revision identifies the program source; later artifact/documentation commits may leave those program sources unchanged. No project shell scripts are required.
