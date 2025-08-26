#!/usr/bin/env bash
set -euo pipefail

# Sync custom Dolibarr code to target deployment directory with safety backup.
# Usage:
#   sudo scripts/deploy/sync-dolibarr.sh \
#       --source dolibarr-custom/dolibarr \
#       --target /opt/dolibarr \
#       --apply-patch        # (optional) apply filecache toggle patch to dev tree first
#       --exclude-documents  # do not overwrite existing documents directory
#       --backup-retain 5    # retain last 5 backups

SOURCE="dolibarr-custom/dolibarr"
TARGET="/opt/dolibarr"
APPLY_PATCH=0
EXCLUDE_DOCS=0
RETAIN=5
DATE_TAG=$(date +%Y%m%d-%H%M%S)
BACKUP_BASE="/opt/dolibarr-backups"

usage(){
  cat <<EOF
sync-dolibarr.sh options:
  --source <path>   (default: dolibarr-custom/dolibarr)
  --target <path>   (default: /opt/dolibarr)
  --apply-patch     apply dolibarr-filecache-toggle.patch to dolibarr-dev before sync
  --exclude-documents  skip syncing htdocs/documents
  --backup-retain N retain N old backups (default 5)
  -h|--help         show help
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --source) SOURCE=$2; shift 2;;
    --target) TARGET=$2; shift 2;;
    --apply-patch) APPLY_PATCH=1; shift;;
    --exclude-documents) EXCLUDE_DOCS=1; shift;;
    --backup-retain) RETAIN=$2; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

[[ $EUID -eq 0 ]] || { echo "[ERROR] Run as root (sudo)." >&2; exit 1; }
[[ -d $SOURCE ]] || { echo "[ERROR] Source not found: $SOURCE" >&2; exit 1; }

if [[ $APPLY_PATCH -eq 1 ]]; then
  if [[ -x scripts/deploy/apply-dolibarr-patch.sh ]]; then
    echo "[INFO] Applying patch to dolibarr-dev tree (idempotent).";
    scripts/deploy/apply-dolibarr-patch.sh || echo "[WARN] Patch application failed or already applied.";
  else
    echo "[WARN] Patch script missing; skipping.";
  fi
fi

mkdir -p "$TARGET" "$BACKUP_BASE"

if [[ -d $TARGET/htdocs ]]; then
  BK_DIR="$BACKUP_BASE/dolibarr-$DATE_TAG"
  echo "[INFO] Creating backup: $BK_DIR";
  mkdir -p "$BK_DIR"
  tar -czf "$BK_DIR/dolibarr.tar.gz" -C "$TARGET" .
fi

RSYNC_EXCLUDES=("--delete")
if [[ $EXCLUDE_DOCS -eq 1 ]]; then
  RSYNC_EXCLUDES+=("--exclude" "htdocs/documents/")
fi

echo "[INFO] Syncing from $SOURCE/ to $TARGET/"
rsync -a "${RSYNC_EXCLUDES[@]}" "$SOURCE/" "$TARGET/"

if [[ ! -d $TARGET/htdocs/documents ]]; then
  mkdir -p $TARGET/htdocs/documents
  chown www-data:www-data $TARGET/htdocs/documents || true
fi

echo "[INFO] Setting base permissions"
find $TARGET/htdocs -type d -exec chmod 755 {} +
find $TARGET/htdocs -type f -exec chmod 644 {} +
chown -R root:root $TARGET/htdocs || true
chown -R www-data:www-data $TARGET/htdocs/documents || true

echo "[INFO] Pruning old backups (retain $RETAIN)"
ls -1dt $BACKUP_BASE/dolibarr-* 2>/dev/null | tail -n +$((RETAIN+1)) | xargs -r rm -rf

echo "[OK] Sync complete. Update Nginx root to $TARGET/htdocs if not already."
exit 0
