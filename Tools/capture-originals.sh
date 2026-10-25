#!/bin/sh
set -eu
if [ "$#" -ne 2 ]; then
  echo 'Usage: Tools/capture-originals.sh <app-bundle> <version-label>' >&2
  exit 2
fi
bundle=$1
label=$2
case "$label" in *[!A-Za-z0-9._-]*|'') echo 'Invalid version label' >&2; exit 2;; esac
root=$(git rev-parse --show-toplevel)
cd "$root"
extraction="research/extracted/$label"
archive="research/originals/onenote-mac-$label.app.tar.gz"
resources="research/originals/onenote-mac-$label.resources.tar.gz"
if [ -e "$extraction" ] || [ -e "$archive" ] || [ -e "$resources" ]; then
  echo 'Capture exists; use a new version label. Existing evidence is immutable.' >&2
  exit 1
fi
swift run -c release --jobs 2 onenote-research capture "$bundle" "$extraction"
mkdir -p research/originals
COPYFILE_DISABLE=1 tar -czf "$archive" -C "$(dirname "$bundle")" "$(basename "$bundle")"
COPYFILE_DISABLE=1 tar -czf "$resources" -C "$bundle/Contents" Resources
shasum -a 256 "$archive" "$resources" > "research/originals/$label.sha256"
gzip -t "$archive" "$resources"
