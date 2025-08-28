#!/usr/bin/env bash
set -euo pipefail
# s3-backup.sh (placeholder)
# Purpose: Dump database(s) + archive assets -> push to S3 (Hetzner)
# Requirements:
#   - Export credentials: AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY
#   - Set BUCKET (e.g. eu-central-1) & ENDPOINT (e.g. https://your-endpoint)
#   - Tools: awscli OR s3cmd; mariadb-client; tar; date

# Config (edit as needed)
BACKUP_NAME_PREFIX="digitalpin"
BACKUP_DIR="/tmp/digitalpin-backup"
ASSETS_DIRS=("public" )
OUT_BUCKET="s3://CHANGE_ME_BUCKET/backups"
ENDPOINT="https://CHANGE_ME_ENDPOINT"  # e.g. https://fsn1.your-objectstorage.com
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"
TS=$(date +%Y%m%d-%H%M%S)
ARCHIVE="$BACKUP_DIR/${BACKUP_NAME_PREFIX}-${TS}.tar.gz"

# Example DB dump command (uncomment & adjust):
# mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" --all-databases > "$BACKUP_DIR/db.sql"

tar czf "$ARCHIVE" ${ASSETS_DIRS[@]} || { echo "Archive failed" >&2; exit 1; }

echo "(Placeholder) Upload step – configure aws or s3cmd first"
# Example:
# AWS_ENDPOINT_URL="$ENDPOINT" aws s3 cp "$ARCHIVE" "$OUT_BUCKET/"

# Retention placeholder:
# aws s3 ls "$OUT_BUCKET/" | awk '{print $4}' | sort | head -n -${RETENTION_DAYS} | while read f; do aws s3 rm "$OUT_BUCKET/$f"; done

echo "Backup placeholder complete: $ARCHIVE"
