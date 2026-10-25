#!/bin/sh
set -eu
cd "$(git rev-parse --show-toplevel)"
swift test --jobs 2
swift build -c release --jobs 2
bin=$(swift build -c release --show-bin-path)
temporary=$(mktemp -d)
trap 'rm -rf "$temporary"' EXIT HUP INT TERM
"$bin/openonenote" create-demo "$temporary/notebook.json"
"$bin/openonenote" inspect "$temporary/notebook.json"
if "$bin/openonenote" create-demo "$temporary/notebook.json" > "$temporary/duplicate.log" 2>&1; then
  echo 'ERROR: create-demo overwrote an existing file' >&2
  exit 1
fi
if "$bin/onenote-research" > "$temporary/research.log" 2>&1; then
  echo 'ERROR: research accepted missing arguments' >&2
  exit 1
fi
mkdir -p "$temporary/Fixture.app/Contents"
printf abc > "$temporary/Fixture.app/Contents/sample"
cat > "$temporary/inventory.json" <<'JSON'
[{"path":"Contents/sample","kind":"file","bytes":3,"sha256":"ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad","destination":null}]
JSON
"$bin/onenote-research" verify "$temporary/Fixture.app" "$temporary/inventory.json"
printf xyz > "$temporary/Fixture.app/Contents/sample"
if "$bin/onenote-research" verify "$temporary/Fixture.app" "$temporary/inventory.json" > "$temporary/mismatch.log" 2>&1; then
  echo 'ERROR: research verifier accepted modified evidence' >&2
  exit 1
fi
git diff --check -- . ':!research'
git diff --cached --check -- . ':!research'
echo 'Swift tests, release build, CLI paths, and whitespace checks passed.'
