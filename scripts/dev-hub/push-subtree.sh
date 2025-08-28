#!/usr/bin/env bash
set -euo pipefail

# Push only the dolibarr-custom/dolibarr subtree to a separate remote (GitLab dev-hub).
# Usage:
#   ./scripts/dev-hub/push-subtree.sh git@gitlab.com:digital-pin/dev-hub.git main
# (Assumes current working directory is repo root.)

REMOTE_URL=${1:-}
TARGET_BRANCH=${2:-main}
SUBTREE_PATH="dolibarr-custom/dolibarr"
TMP_BRANCH="_subtree_dev_hub_$(date +%s)"

[[ -n "$REMOTE_URL" ]] || { echo "Usage: $0 <remote-url> [branch]" >&2; exit 1; }

echo "[INFO] Creating subtree split for $SUBTREE_PATH";
git subtree split --prefix "$SUBTREE_PATH" -b "$TMP_BRANCH"

if git ls-remote --exit-code "$REMOTE_URL" &>/dev/null; then
  echo "[INFO] Remote reachable. Adding/updating temporary remote alias gitlab-dev-hub";
  git remote remove gitlab-dev-hub 2>/dev/null || true
  git remote add gitlab-dev-hub "$REMOTE_URL"
else
  echo "[WARN] Remote not reachable now (maybe offline / needs SSH key). Will still attempt push.";
  git remote remove gitlab-dev-hub 2>/dev/null || true
  git remote add gitlab-dev-hub "$REMOTE_URL"
fi

echo "[INFO] Pushing subtree branch to $REMOTE_URL ($TARGET_BRANCH)";
git push gitlab-dev-hub "$TMP_BRANCH:$TARGET_BRANCH"

echo "[INFO] Cleaning temp branch";
git branch -D "$TMP_BRANCH" || true
exit 0
