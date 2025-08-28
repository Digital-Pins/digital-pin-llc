#!/usr/bin/env bash
set -euo pipefail

# run-tomorrow.sh
# Safe helper to initialize design-from-snapshots work.
# Dry-run by default. Use --run to perform actions.

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")
SNAP_DIR="$ROOT/docs/design-snapshots"
OUT_DIR="$ROOT/public/design-assets"
BRANCH="feature/design-from-snapshots"
DO_RUN=0

usage(){
  cat <<EOF
Usage: $0 [--run]
  --run   Perform actions (create branch, copy assets, git add/commit)
  (no args) Dry-run: show planned actions only
EOF
  exit 0
}

if [[ ${1:-} == "--run" ]]; then DO_RUN=1; fi

echo "Root project: $ROOT"
echo "Snapshots dir: $SNAP_DIR"
echo "Target assets dir: $OUT_DIR"
echo

if [[ ! -d "$SNAP_DIR" ]]; then
  echo "ERROR: snapshots dir not found: $SNAP_DIR" >&2
  exit 1
fi

echo "Planned actions:"
echo " 1) Create branch: $BRANCH (local)"
echo " 2) Create directory: $OUT_DIR"
echo " 3) Copy snapshots -> $OUT_DIR"
echo " 4) git add $OUT_DIR and commit 'chore: add design snapshots assets'"
echo

if [[ $DO_RUN -ne 1 ]]; then
  echo "Dry-run mode: no changes made. Rerun with --run to apply."
  exit 0
fi

echo "== Executing =="
echo "1) Creating branch $BRANCH"
git checkout -b "$BRANCH"

echo "2) Ensure $OUT_DIR exists"
mkdir -p "$OUT_DIR"

echo "3) Copying files"
cp -v "$SNAP_DIR"/* "$OUT_DIR/"

echo "4) Git add & commit"
git add "$OUT_DIR"
git commit -m "chore: add design snapshots assets"

echo "Done. Created branch $BRANCH with assets in $OUT_DIR."
echo "Note: changes are local; push with 'git push -u origin $BRANCH' when ready."
