#!/usr/bin/env bash
set -euo pipefail

# prepare-devhub-root.sh
# Idempotent helper to provision /opt/dev-hub from current working copy.
# Usage (run from repository root after pulling latest):
#   sudo scripts/deploy/prepare-devhub-root.sh
#
# Steps:
#   - Create /opt/dev-hub (if absent)
#   - Rsync tracked files (excluding VCS noise & large transient dirs)
#   - Optionally preserve local .git (flag --with-git) else deploy as clean tree
#   - Maintain a release stamp file

WITH_GIT=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --with-git) WITH_GIT=1; shift;;
    -h|--help)
      echo "Usage: $0 [--with-git]"; exit 0;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

[[ $EUID -eq 0 ]] || { echo "Run as root" >&2; exit 1; }

SRC=$(pwd)
DEST=/opt/dev-hub
echo "[INFO] Preparing $DEST from $SRC"
mkdir -p "$DEST"

EXCLUDES=(
  --exclude .git/ --exclude .github/
  --exclude node_modules/ --exclude dist/ --exclude build/
  --exclude tmp/ --exclude .next/
)

rsync -a --delete "${EXCLUDES[@]}" "$SRC/" "$DEST/"

if [[ $WITH_GIT -eq 1 ]]; then
  echo "[INFO] Preserving git metadata";
  rsync -a "$SRC/.git/" "$DEST/.git/"
fi

echo "release_timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$DEST/.release"
echo "[OK] /opt/dev-hub updated"
exit 0
