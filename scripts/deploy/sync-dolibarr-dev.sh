#!/usr/bin/env bash
set -euo pipefail

# Sync ONLY the dolibarr-custom/dolibarr tree into /opt/dolibarr-dev for the dev subdomain.
# Keeps production /opt/dolibarr untouched.
# Differences from sync-dolibarr.sh:
#  - Separate target (/opt/dolibarr-dev)
#  - Always excludes documents unless --include-documents specified (to avoid clobbering test data)
#  - Lighter backup retention default (3)

SOURCE="dolibarr-custom/dolibarr"
TARGET="/opt/dolibarr-dev"
INCLUDE_DOCS=0
RETAIN=3
DATE_TAG=$(date +%Y%m%d-%H%M%S)
BACKUP_BASE="/opt/dolibarr-dev-backups"

usage(){
  cat <<EOF
sync-dolibarr-dev.sh options:
  --source <path>   (default: dolibarr-custom/dolibarr)
  --target <path>   (default: /opt/dolibarr-dev)
  --include-documents  include syncing htdocs/documents (default: skip)
  --backup-retain N retain N old backups (default 3)
  -h|--help         show help
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --source) SOURCE=$2; shift 2;;
    --target) TARGET=$2; shift 2;;
    --include-documents) INCLUDE_DOCS=1; shift;;
    --backup-retain) RETAIN=$2; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

[[ $EUID -eq 0 ]] || { echo "[ERROR] Run as root (sudo)." >&2; exit 1; }
[[ -d $SOURCE ]] || { echo "[ERROR] Source not found: $SOURCE" >&2; exit 1; }

mkdir -p "$TARGET" "$BACKUP_BASE"

if [[ -d $TARGET/htdocs ]]; then
  BK_DIR="$BACKUP_BASE/dolibarr-dev-$DATE_TAG"
  echo "[INFO] Creating backup: $BK_DIR";
  mkdir -p "$BK_DIR"
  tar -czf "$BK_DIR/dolibarr-dev.tar.gz" -C "$TARGET" .
fi

RSYNC_EXCLUDES=("--delete")
if [[ $INCLUDE_DOCS -eq 0 ]]; then
  RSYNC_EXCLUDES+=("--exclude" "htdocs/documents/")
fi

echo "[INFO] Syncing dev from $SOURCE/ to $TARGET/"
rsync -a "${RSYNC_EXCLUDES[@]}" "$SOURCE/" "$TARGET/"

if [[ ! -d $TARGET/htdocs/documents ]]; then
  mkdir -p $TARGET/htdocs/documents
  chown www-data:www-data $TARGET/htdocs/documents || true
fi

echo "[INFO] Setting permissions"
find $TARGET/htdocs -type d -exec chmod 755 {} +
find $TARGET/htdocs -type f -exec chmod 644 {} +
chown -R root:root $TARGET/htdocs || true
chown -R www-data:www-data $TARGET/htdocs/documents || true

echo "[INFO] Pruning old backups (retain $RETAIN)"
ls -1dt $BACKUP_BASE/dolibarr-dev-* 2>/dev/null | tail -n +$((RETAIN+1)) | xargs -r rm -rf

echo "[OK] Dev sync complete. Point dev Nginx root to $TARGET/htdocs if not already."
exit 0
