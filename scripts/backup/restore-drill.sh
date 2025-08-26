#!/usr/bin/env bash
set -euo pipefail
# restore-drill.sh
# Purpose: Perform a non-destructive restore verification of the latest (or specified) OCI backup
# for a given service (e.g., erp-dev) into an isolated temp workspace and optionally validate SQL dump structure.
#
# Features:
#  - Fetch latest (lexicographically newest) archive + checksum from OCI bucket prefix
#  - Verify SHA256
#  - Extract into a temp directory
#  - Optionally create a temporary MySQL DB and import the dump for integrity check
#  - Report summary (sizes / counts) and emit success/failure code
#
# Requirements:
#  - oci CLI configured
#  - mysql client installed (if --import-db used)
#  - Sufficient disk space in /tmp
#
# Exit Codes:
#  0 success
#  1 args error
#  2 no backup found
#  3 checksum mismatch
#  4 import failure

SERVICE=""
BUCKET=""
PROFILE=""
ARCHIVE=""   # explicit object name (prefix/<file>) optional
IMPORT_DB=0
DB_NAME=""   # auto-generated if empty and --import-db
KEEP_WORK=0
VERBOSE=0

die(){ echo "[ERR] $*" >&2; exit 1; }
log(){ echo "[restore] $*"; }
vlog(){ [[ $VERBOSE -eq 1 ]] && echo "[restore][v] $*"; }

while [[ $# -gt 0 ]]; do
  case $1 in
    --service) SERVICE=$2; shift 2;;
    --bucket) BUCKET=$2; shift 2;;
    --profile) PROFILE=$2; shift 2;;
    --archive) ARCHIVE=$2; shift 2;;
    --import-db) IMPORT_DB=1; shift;;
    --db-name) DB_NAME=$2; shift 2;;
    --keep-work) KEEP_WORK=1; shift;;
    --verbose) VERBOSE=1; shift;;
    -h|--help)
      grep '^# ' "$0" | sed 's/^# //'; exit 0;;
    *) die "Unknown arg: $1";;
  esac
done

[[ -n $SERVICE && -n $BUCKET ]] || die "--service and --bucket required"
command -v oci >/dev/null || die "oci CLI not found"

OCI_ARGS=()
[[ -n $PROFILE ]] && OCI_ARGS+=(--profile "$PROFILE")

PREFIX="$SERVICE/"

if [[ -z $ARCHIVE ]]; then
  log "Listing objects to find latest archive..."
  LIST=$(oci "${OCI_ARGS[@]}" os object list --bucket-name "$BUCKET" --prefix "$PREFIX" --fields name | grep '"name"' | sed 's/.*"name": "\(.*\)".*/\1/' | grep "${SERVICE}_backup_.*\.tar\.gz" | sort -r || true)
  ARCHIVE=$(echo "$LIST" | head -1)
  if [[ -z $ARCHIVE ]]; then
    die "No archives found under prefix $PREFIX"
  fi
fi

ARCHIVE_BASE=$(basename "$ARCHIVE")
CHECKSUM_OBJECT="${ARCHIVE}.sha256"
WORK="/tmp/restore-${SERVICE}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$WORK"

log "Selected archive: $ARCHIVE"
log "Work dir: $WORK"

log "Downloading archive & checksum"
oci "${OCI_ARGS[@]}" os object get --bucket-name "$BUCKET" --name "$ARCHIVE" --file "$WORK/$ARCHIVE_BASE" >/dev/null
oci "${OCI_ARGS[@]}" os object get --bucket-name "$BUCKET" --name "$CHECKSUM_OBJECT" --file "$WORK/${ARCHIVE_BASE}.sha256" >/dev/null || true

if [[ -f $WORK/${ARCHIVE_BASE}.sha256 ]]; then
  log "Verifying checksum"
  (cd "$WORK" && sha256sum -c "${ARCHIVE_BASE}.sha256") || { die "Checksum mismatch"; }
else
  log "[WARN] No checksum object found, skipping verification"
fi

log "Extracting archive"
mkdir -p "$WORK/extract"
tar -xzf "$WORK/$ARCHIVE_BASE" -C "$WORK/extract"

SQL_DUMP=$(find "$WORK/extract" -maxdepth 2 -type f -name "*.sql" | head -1 || true)
if [[ -n $SQL_DUMP ]]; then
  log "Found SQL dump: $(basename "$SQL_DUMP") (size: $(stat -c '%s' "$SQL_DUMP" 2>/dev/null))"
else
  log "[WARN] No SQL dump (*.sql) detected"
fi

DOCS_ARCHIVE=$(find "$WORK/extract" -maxdepth 2 -type f -name "documents.tar.gz" | head -1 || true)
if [[ -n $DOCS_ARCHIVE ]]; then
  log "Documents archive present (size: $(stat -c '%s' "$DOCS_ARCHIVE" 2>/dev/null) bytes)"
fi

if (( IMPORT_DB == 1 )); then
  command -v mysql >/dev/null || die "mysql client not installed"
  [[ -n $SQL_DUMP ]] || die "--import-db specified but no SQL dump found"
  if [[ -z $DB_NAME ]]; then
    DB_NAME="restore_${SERVICE}_${RANDOM}"
  fi
  log "Creating temp DB $DB_NAME"
  mysql -e "CREATE DATABASE \`$DB_NAME\`;" || die "Failed to create DB"
  log "Importing dump"
  if mysql "$DB_NAME" < "$SQL_DUMP"; then
    log "Import successful"
  else
    die "Import failed"
  fi
  # Simple structural check
  TABLE_COUNT=$(mysql -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';")
  log "Table count: $TABLE_COUNT"
fi

log "Restore drill completed successfully"
log "Summary:"
log "  Archive: $ARCHIVE_BASE"
log "  Workdir: $WORK"
[[ -n $SQL_DUMP ]] && log "  SQL Dump: $(basename "$SQL_DUMP")"
[[ -n $DOCS_ARCHIVE ]] && log "  Docs Archive: $(basename "$DOCS_ARCHIVE")"
if (( KEEP_WORK == 0 )); then
  rm -rf "$WORK"
  log "Workdir removed (use --keep-work to retain)"
fi
exit 0
