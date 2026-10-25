#!/bin/sh
set -eu
cd "$(git rev-parse --show-toplevel)"
command -v git-lfs >/dev/null 2>&1 || { echo 'git-lfs is required' >&2; exit 2; }
hooks=$(git config --get core.hooksPath || git rev-parse --git-path hooks)
mkdir -p "$hooks"
for hook in pre-push post-checkout post-commit post-merge; do
  path="$hooks/$hook"
  if [ ! -f "$path" ]; then printf '#!/bin/sh\n' > "$path"; fi
  if ! grep -Fq "git lfs $hook" "$path"; then
    cat >> "$path" <<'HOOK'

# OpenOneNote Git LFS integration; preserve preceding Beads/custom hook.
command -v git-lfs >/dev/null 2>&1 || { echo 'git-lfs is required' >&2; exit 2; }
HOOK
    printf 'git lfs %s "$@"\n' "$hook" >> "$path"
  fi
  chmod u+x "$path"
done
echo 'Git LFS integration added alongside existing hooks'
