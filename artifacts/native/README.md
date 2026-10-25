# Native Swift Foundation Build

This directory retains the compiled independent Swift foundation alongside its reproducible source. It contains command-line tools, not a graphical OneNote replacement or a signed/notarized application release.

The archive includes `openonenote`, `onenote-research`, a synthetic example notebook, binary hashes, dependency/toolchain metadata, and a source-revision manifest. Requires Apple Silicon and macOS 14 or newer. Intel source builds have not been verified.

Retrieve the archive with `git lfs pull`, validate its adjacent `.sha256` file, extract to a new directory, and run `openonenote inspect example-notebook.json` from that directory. The executables do not need the original Microsoft archives.

Build and verify from source with `sh Tools/check.sh`; create a new compiled archive with `sh Tools/package-build.sh`. The embedded revision identifies the program source used for that build; later commits may add delivery metadata or packaging instructions without changing those sources.
