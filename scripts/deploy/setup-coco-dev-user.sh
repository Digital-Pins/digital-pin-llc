#!/usr/bin/env bash
set -euo pipefail

# Purpose: Provision restricted deployment user coco-dev.
# This script DOES NOT hardcode a weak password. Pass one via --password (NOT RECOMMENDED) or prefer SSH key only.
# Example (SSH key only):
#   sudo ./scripts/deploy/setup-coco-dev-user.sh --pubkey-file /root/coco-dev.pub --allow-password no
# Example (temporary password + key):
#   sudo ./scripts/deploy/setup-coco-dev-user.sh --pubkey-file /root/coco-dev.pub --password 'Temp#1234'
#
# Flags:
#   --user <name>            (default: coco-dev)
#   --password <pass>        (optional; if omitted and allow-password yes, script will prompt)
#   --allow-password <yes|no> (default: no)
#   --pubkey-file <path>     (optional path to public key to install)
#   --force                  (continue if user already exists)
#   --deploy-wrapper-path <path> (default installs from repo scripts/deploy/deploy-wrapper.sh)

USER_NAME="coco-dev"
PASSWORD=""
ALLOW_PASSWORD="no"
PUBKEY_FILE=""
FORCE=0
WRAPPER_SRC="scripts/deploy/deploy-wrapper.sh"
WRAPPER_DST="/usr/local/bin/deploy-wrapper.sh"

die(){ echo "[ERROR] $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --user) USER_NAME=$2; shift 2;;
    --password) PASSWORD=$2; shift 2;;
    --allow-password) ALLOW_PASSWORD=$2; shift 2;;
    --pubkey-file) PUBKEY_FILE=$2; shift 2;;
    --force) FORCE=1; shift;;
    --deploy-wrapper-path) WRAPPER_SRC=$2; shift 2;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# //'; exit 0;;
    *) die "Unknown arg: $1";;
  esac
done

[[ $EUID -eq 0 ]] || die "Run as root"

if id "$USER_NAME" >/dev/null 2>&1; then
  if [[ $FORCE -eq 0 ]]; then
    die "User $USER_NAME already exists (use --force to continue hardening)"
  else
    echo "[INFO] User $USER_NAME exists; continuing to (re)apply config";
  fi
else
  echo "[INFO] Creating user $USER_NAME (nologin until configured)"
  useradd --create-home --shell /bin/bash "$USER_NAME"
fi

HOME_DIR=$(getent passwd "$USER_NAME" | cut -d: -f6)
[[ -n $HOME_DIR && -d $HOME_DIR ]] || die "Could not resolve home directory"

SSH_DIR="$HOME_DIR/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
chown "$USER_NAME:$USER_NAME" "$SSH_DIR"

if [[ -n "$PUBKEY_FILE" ]]; then
  [[ -f $PUBKEY_FILE ]] || die "Public key file not found: $PUBKEY_FILE"
  cat "$PUBKEY_FILE" >> "$SSH_DIR/authorized_keys"
  sort -u "$SSH_DIR/authorized_keys" -o "$SSH_DIR/authorized_keys"
  chmod 600 "$SSH_DIR/authorized_keys"
  chown "$USER_NAME:$USER_NAME" "$SSH_DIR/authorized_keys"
  echo "[INFO] Installed public key from $PUBKEY_FILE"
fi

if [[ $ALLOW_PASSWORD == "yes" ]]; then
  if [[ -z "$PASSWORD" ]]; then
    read -r -s -p "Enter password for $USER_NAME: " PASSWORD; echo
  fi
  echo "$USER_NAME:$PASSWORD" | chpasswd
  echo "[WARN] Password authentication enabled; recommend disabling after key setup.";
else
  passwd -l "$USER_NAME" >/dev/null 2>&1 || true
  echo "[INFO] Password login disabled (account locked)."
fi

echo "[INFO] Installing deploy wrapper"
[[ -f $WRAPPER_SRC ]] || die "Wrapper source not found: $WRAPPER_SRC"
install -m 755 "$WRAPPER_SRC" "$WRAPPER_DST"

LOG_FILE="/var/log/devhub-deploy.log"
touch "$LOG_FILE"
chmod 640 "$LOG_FILE"
chown root:"$USER_NAME" "$LOG_FILE" || true

SUDO_FILE="/etc/sudoers.d/${USER_NAME}"
echo "[INFO] Writing sudoers policy $SUDO_FILE"
cat > "$SUDO_FILE" <<POLICY
Defaults:${USER_NAME} !requiretty
${USER_NAME} ALL=(root) NOPASSWD: /usr/sbin/nginx, /usr/bin/systemctl reload nginx, /usr/bin/systemctl restart php8.1-fpm, /usr/bin/env bash -c *sync-dolibarr-dev.sh*, /usr/bin/tail /var/log/nginx/dev_erp.error.log
POLICY
chmod 440 "$SUDO_FILE"
visudo -c >/dev/null || die "sudoers validation failed"

echo "[INFO] Provision complete"
echo "Summary:";
echo "  User:         $USER_NAME"
echo "  Home:         $HOME_DIR"
echo "  SSH keys:     $( [[ -f $SSH_DIR/authorized_keys ]] && wc -l < $SSH_DIR/authorized_keys || echo 0 ) entries"
echo "  Password:     $( [[ $ALLOW_PASSWORD == yes ]] && echo 'ENABLED' || echo 'DISABLED (locked)' )"
echo "  Wrapper:      $WRAPPER_DST"
echo "  Sudo policy:  $SUDO_FILE"
echo "  Log file:     $LOG_FILE"
exit 0
