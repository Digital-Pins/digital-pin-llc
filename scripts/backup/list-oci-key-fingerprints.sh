#!/usr/bin/env bash
# list-oci-key-fingerprints.sh
# Enumerate private key files in a directory (default: /home/coco-dev/oci or $1)
# and print their OCI-style MD5 fingerprints so you can match which key is
# already registered in the OCI Console (User -> API Keys).
#
# Usage:
#   bash scripts/backup/list-oci-key-fingerprints.sh [dir]
#
# Notes:
# - OCI fingerprint = MD5 of the public key DER (what the Console shows)
# - Only files containing 'BEGIN PRIVATE KEY' or 'BEGIN RSA PRIVATE KEY' are processed.
# - Requires: openssl
set -euo pipefail
DIR="${1:-/home/coco-dev/oci}"
[ -d "$DIR" ] || { echo "Directory not found: $DIR" >&2; exit 1; }

shopt -s nullglob
found=0
for f in "$DIR"/*.pem; do
  if grep -q 'BEGIN PRIVATE KEY' "$f" 2>/dev/null || grep -q 'BEGIN RSA PRIVATE KEY' "$f" 2>/dev/null; then
    found=1
    perm=$(stat -c '%a' "$f" 2>/dev/null || echo '?')
    owner=$(stat -c '%U:%G' "$f" 2>/dev/null || echo '?')
    size=$(stat -c '%s' "$f" 2>/dev/null || echo '?')
    fp=$(openssl rsa -in "$f" -pubout 2>/dev/null | openssl md5 -c 2>/dev/null | awk '{print $2}') || true
    if [ -n "$fp" ]; then
      echo "FILE=$f"
      echo "  OWNER=$owner PERM=$perm SIZE=$size BYTES"
      echo "  FINGERPRINT=$fp"
    else
      echo "FILE=$f (could not derive fingerprint)" >&2
    fi
  fi
done

if [ $found -eq 0 ]; then
  echo "No private key *.pem files found in $DIR" >&2
  exit 2
fi

cat <<'POST'
---
Next:
  1. Match FINGERPRINT with the one shown in OCI Console for the API Key.
  2. Choose that file as your key_file path in ~/.oci/config.
  3. (Optional) Symlink to a stable name, e.g.:
       ln -sf /home/coco-dev/oci/<chosen>.pem /home/coco-dev/oci/oci_api_key.pem
  4. Ensure permissions: chown coco-dev:coco-dev <file>; chmod 600 <file>
POST
