#!/usr/bin/env bash
set -euo pipefail

# Create a Dolibarr MariaDB database + user (intended for dev or prod isolation).
# Usage examples:
#   sudo scripts/deploy/create-dolibarr-db.sh \
#       --db-name dolibarr_dev --db-user doliuser_dev
#   sudo scripts/deploy/create-dolibarr-db.sh --db-pass 'Strong#Pass123'  # custom password
#
# If --db-pass not supplied a 24 char random one is generated.
# A credentials file will be written to /root/<db-name>-db.creds (mode 600).

DB_NAME="dolibarr_dev"
DB_USER="doliuser_dev"
DB_PASS=""

usage(){
  cat <<EOF
create-dolibarr-db.sh options:
  --db-name <name>   (default: dolibarr_dev)
  --db-user <user>   (default: doliuser_dev)
  --db-pass <pass>   (default: auto-generate)
  -h|--help          show help
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --db-name) DB_NAME=$2; shift 2;;
    --db-user) DB_USER=$2; shift 2;;
    --db-pass) DB_PASS=$2; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

[[ $EUID -eq 0 ]] || { echo "[ERROR] Run as root (sudo)." >&2; exit 1; }

if [[ -z "$DB_PASS" ]]; then
  if command -v openssl >/dev/null 2>&1; then
    DB_PASS=$(openssl rand -base64 24 | tr -d '=+/\n' | cut -c1-24)
  else
    DB_PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c24)
  fi
fi

echo "[INFO] Creating database/user if absent: $DB_NAME / $DB_USER"

mysql <<SQL
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
SQL

CREDS_FILE="/root/${DB_NAME}-db.creds"
{
  echo "DB_NAME=$DB_NAME"
  echo "DB_USER=$DB_USER"
  echo "DB_PASS=$DB_PASS"
} > "$CREDS_FILE"
chmod 600 "$CREDS_FILE"

echo "[OK] Database prepared. Credentials stored in $CREDS_FILE"
echo "Use these values in Dolibarr installer for the dev instance."
exit 0
