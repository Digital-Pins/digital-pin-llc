#!/usr/bin/env bash
set -euo pipefail

# oci-backup.sh
# Minimal dependency backup uploader for Oracle Cloud Infrastructure (OCI) Object Storage.
# Avoids AWS CLI; uses "oci" CLI only.
#
# Features:
#  - Dump MariaDB database (single DB) (optional)
#  - Archive documents directory + optional extra paths
#  - Upload tar.gz + sha256 checksum to an OCI bucket under prefix <service>/
#  - Retention pruning (by lexicographically sorted filenames) without jq (best-effort)
#
# Prerequisites:
#  - OCI CLI installed and configured: ~/.oci/config (DEFAULT profile) OR export OCI_CLI_PROFILE
#  - Bucket already exists (created manually or via console)
#  - User principal / instance principal with write permission to the bucket
#
# Usage:
#   sudo scripts/backup/oci-backup.sh \
#       --service erp-dev \
#       --bucket DEVHUB_BACKUPS \
#       --db-name dolibarr_dev --db-user doliuser_dev --db-pass-file /root/dolibarr_dev-db.creds \
#       --documents-path /opt/dolibarr-dev/htdocs/documents --retain 7
#
# Flags:
#   --service <name>          Logical service tag (default: erp-dev)
#   --bucket <bucket_name>    Target OCI Object Storage bucket (required)
#   --prefix <prefix>         Key prefix inside bucket (default: <service>)
#   --db-name <name>          DB name (optional; if omitted no DB dump)
#   --db-user <user>          DB user (default: root)
#   --db-pass-file <file>     File containing password only (no KEY=)
#   --db-socket <path>        Socket path (overrides host)
#   --db-host <host>          Host (default: localhost)
#   --documents-path <path>   Documents dir (optional)
#   --extra-path <path>       Additional path to include (repeatable)
#   --retain <N>              Retain last N backups (default 7)
#   --dry-run                 Do not upload / create dump
#   --profile <oci_profile>   OCI CLI profile name (default: from env or DEFAULT)
#
SERVICE="erp-dev"
BUCKET=""
PREFIX=""
DB_NAME=""
DB_USER="root"
DB_PASS_FILE=""
DB_SOCKET=""
DB_HOST="localhost"
DOCS_PATH=""
EXTRA_PATHS=()
RETAIN=7
DRY=0
PROFILE=""
DATE_TAG=$(date +%Y%m%d-%H%M%S)
TMP_DIR="/tmp/oci-backup-${SERVICE}-${DATE_TAG}"

log(){ echo "[oci-backup] $*"; }
die(){ echo "[ERROR] $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --service) SERVICE=$2; shift 2;;
    --bucket) BUCKET=$2; shift 2;;
    --prefix) PREFIX=$2; shift 2;;
    --db-name) DB_NAME=$2; shift 2;;
    --db-user) DB_USER=$2; shift 2;;
    --db-pass-file) DB_PASS_FILE=$2; shift 2;;
    --db-socket) DB_SOCKET=$2; shift 2;;
    --db-host) DB_HOST=$2; shift 2;;
    --documents-path) DOCS_PATH=$2; shift 2;;
    --extra-path) EXTRA_PATHS+=("$2"); shift 2;;
    --retain) RETAIN=$2; shift 2;;
    --dry-run) DRY=1; shift;;
    --profile) PROFILE=$2; shift 2;;
    -h|--help) grep '^# ' "$0" | cut -c4-; exit 0;;
    *) die "Unknown arg: $1";;
  esac
done

[[ -n $BUCKET ]] || die "--bucket required"
[[ -x $(command -v oci || true) ]] || die "oci CLI not found"
[[ $EUID -eq 0 ]] || die "Run as root (sudo)"

[[ -n $PREFIX ]] || PREFIX="$SERVICE"
ARCHIVE_NAME="${SERVICE}_backup_${DATE_TAG}.tar.gz"
ARCHIVE_SHA="${ARCHIVE_NAME}.sha256"

mkdir -p "$TMP_DIR"

DB_DUMP=""
if [[ -n $DB_NAME ]]; then
  DB_DUMP="$TMP_DIR/${SERVICE}_${DB_NAME}_${DATE_TAG}.sql"
  MYSQL_ARGS=("--user=$DB_USER" "$DB_NAME" "--single-transaction" "--routines" "--triggers")
  if [[ -n $DB_PASS_FILE ]]; then
    [[ -f $DB_PASS_FILE ]] || die "Password file not found: $DB_PASS_FILE"
    PASS=$(<"$DB_PASS_FILE")
    MYSQL_ARGS=("--user=$DB_USER" "--password=$PASS" "$DB_NAME" "--single-transaction" "--routines" "--triggers")
  fi
  if [[ -n $DB_SOCKET ]]; then
    MYSQL_ARGS+=("--socket=$DB_SOCKET")
  else
    MYSQL_ARGS+=("--host=$DB_HOST")
  fi
  log "Dumping DB $DB_NAME"
  [[ $DRY -eq 1 ]] || mysqldump "${MYSQL_ARGS[@]}" > "$DB_DUMP"
fi

BUILD_DIR="$TMP_DIR/build"
mkdir -p "$BUILD_DIR"
[[ -n $DB_DUMP ]] && cp "$DB_DUMP" "$BUILD_DIR/"
if [[ -n $DOCS_PATH ]]; then
  if [[ -d $DOCS_PATH ]]; then
    log "Including documents path $DOCS_PATH"
    tar -C / -czf "$BUILD_DIR/documents.tar.gz" "${DOCS_PATH#/}" || die "Tar documents failed"
  else
    log "[WARN] Documents path missing: $DOCS_PATH"
  fi
fi
for ep in "${EXTRA_PATHS[@]}"; do
  if [[ -e $ep ]]; then
    base=$(basename "$ep")
    tar -C "$(dirname "$ep")" -czf "$BUILD_DIR/extra_${base}.tar.gz" "$base"
  else
    log "[WARN] Extra path missing: $ep"
  fi
done

log "Creating final archive $ARCHIVE_NAME"
[[ $DRY -eq 1 ]] || (cd "$BUILD_DIR" && tar -czf "$TMP_DIR/$ARCHIVE_NAME" .)
[[ $DRY -eq 1 ]] || sha256sum "$TMP_DIR/$ARCHIVE_NAME" > "$TMP_DIR/$ARCHIVE_SHA"

OCI_ARGS=()
[[ -n $PROFILE ]] && OCI_ARGS+=(--profile "$PROFILE")

upload(){
  local file="$1"; local name="$PREFIX/$file";
  log "Uploading $file -> bucket:$BUCKET name:$name"
  [[ $DRY -eq 1 ]] || oci "${OCI_ARGS[@]}" os object put --bucket-name "$BUCKET" --name "$name" --file "$TMP_DIR/$file" --content-type application/gzip --force >/dev/null
}

upload "$ARCHIVE_NAME"
upload "$ARCHIVE_SHA"

log "Pruning (retain $RETAIN)"
if [[ $DRY -eq 0 ]]; then
  LIST=$(oci "${OCI_ARGS[@]}" os object list --bucket-name "$BUCKET" --prefix "$PREFIX/" --fields name | grep '"name"' | sed 's/.*"name": "\(.*\)".*/\1/' | grep "${SERVICE}_backup_.*.tar.gz" | sort -r)
  COUNT=0
  while read -r obj; do
    [[ -z $obj ]] && continue
    COUNT=$((COUNT+1))
    if (( COUNT > RETAIN )); then
      log "Deleting old $obj"
      oci "${OCI_ARGS[@]}" os object delete --bucket-name "$BUCKET" --object-name "$obj" --force >/dev/null || true
      oci "${OCI_ARGS[@]}" os object delete --bucket-name "$BUCKET" --object-name "${obj}.sha256" --force >/dev/null || true
    fi
  done <<< "$LIST"
fi

log "Done"
[[ $DRY -eq 1 ]] && log "(dry-run mode: nothing uploaded)"
exit 0
