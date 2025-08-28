#!/usr/bin/env bash
set -euo pipefail
# gen-known-hosts.sh
# Generate a KNOWN_HOSTS variable value for GitLab CI from a target host.
# Usage: ./scripts/dev-hub/gen-known-hosts.sh <host> [port]
# Default port 22.

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <host> [port]" >&2
  exit 1
fi
HOST=$1
PORT=${2:-22}

echo "[INFO] Scanning $HOST:$PORT (ed25519,rsa)" >&2
# Gather both ed25519 and rsa (some environments still present rsa)
OUT=$(ssh-keyscan -p "$PORT" -t ed25519,rsa "$HOST" 2>/dev/null || true)
if [[ -z "$OUT" ]]; then
  echo "[ERROR] ssh-keyscan returned no data" >&2
  exit 2
fi
# Print raw so user can copy directly into GitLab variable KNOWN_HOSTS
printf '%s\n' "$OUT"

echo "[INFO] Copy the above lines into GitLab -> Settings -> CI/CD -> Variables -> KNOWN_HOSTS" >&2
