#!/bin/sh
set -eu
cd "$(git rev-parse --show-toplevel)"
git diff --quiet HEAD -- Package.swift Sources
source_revision=$(git rev-parse HEAD)
short_revision=$(git rev-parse --short HEAD)
architecture=$(uname -m)
name="openonenote-foundation-$architecture-$short_revision"
directory="scratch/$name"
archive="artifacts/native/$name.tar.gz"
if [ -e "$directory" ] || [ -e "$archive" ]; then echo 'Build package already exists' >&2; exit 1; fi
swift build -c release --jobs 2
bin=$(swift build -c release --show-bin-path)
mkdir -p "$directory" artifacts/native
cp "$bin/openonenote" "$directory/"
cp "$bin/onenote-research" "$directory/"
swift --version > "$directory/toolchain.txt"
file "$bin/openonenote" "$bin/onenote-research" > "$directory/binary-formats.txt"
otool -L "$bin/openonenote" > "$directory/openonenote-dependencies.txt"
"$directory/openonenote" create-demo "$directory/example-notebook.json"
cat > "$directory/build.json" <<JSON
{
  "sourceRevision": "$source_revision",
  "architecture": "$architecture",
  "minimumMacOS": "14.0",
  "command": "swift build -c release --jobs 2",
  "productScope": "Independent notebook core/persistence demonstrator and research CLI; no graphical app",
  "builtAtUTC": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
JSON
shasum -a 256 "$directory/openonenote" "$directory/onenote-research" > "$directory/binary-sha256.txt"
COPYFILE_DISABLE=1 tar -czf "$archive" -C scratch "$name"
gzip -t "$archive"
shasum -a 256 "$archive" > "$archive.sha256"
echo "Packaged $archive"
