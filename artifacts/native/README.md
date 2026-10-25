# Native Swift Foundation Build

This directory retains independent native Swift app/tool builds alongside reproducible source and checksums. The current graphical app is a local-first editing alpha, with an ad-hoc development signature and no notarization.

`openonenote-app-arm64-<revision>.tar.gz` contains `OpenOneNote.app`. Extract it to a new directory and open the app. Requires Apple Silicon and targets macOS 14 or newer; Intel builds have not been verified. The app's resource manifest records the committed source revision. The earlier `openonenote-foundation-*` archives preserve the initial CLI-only milestones, including a synthetic notebook and original build metadata.

The first graphical build is [openonenote-app-arm64-51d9805.tar.gz](openonenote-app-arm64-51d9805.tar.gz), built from source tag `native-alpha-0.1.0-source`. Its adjacent checksum and the native [preview verification](../previews/verification.json) record the preserved build and test scope.

Retrieve the archive with `git lfs pull`, validate its adjacent `.sha256` file, extract to a new directory, and run `openonenote inspect example-notebook.json` from that directory. The executables do not need the original Microsoft archives.

Build and verify with `swift run openonenote-dev check`; assemble the app with `swift run openonenote-dev app`; archive committed sources with `swift run openonenote-dev package-app` or `package-tools`. The embedded revision identifies the program source; later artifact/documentation commits may leave those program sources unchanged. No project shell scripts are required.
