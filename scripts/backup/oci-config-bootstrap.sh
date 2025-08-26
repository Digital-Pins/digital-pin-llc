#!/usr/bin/env bash
# oci-config-bootstrap.sh
# Purpose: Non-interactively create/update an OCI CLI config (~/.oci/config) for the current user
# and optionally generate an API signing key pair.
#
# Safe to re-run: will back up existing config as config.bak.TIMESTAMP before modifying.
#
# Requirements:
#   - Provide the following required environment variables (export or inline):
#       OCI_TENANCY_OCID       (ocid1.tenancy....)
#       OCI_USER_OCID          (ocid1.user.... for the *API* user)
#       OCI_REGION             (e.g. eu-frankfurt-1)
#   - Either:
#       a) Provide an existing private key via OCI_KEY_FILE (path) and its public key already uploaded, OR
#       b) Allow this script to generate a new key (set OCI_GEN_KEY=1) then you must upload the public key output.
#   - If using an existing uploaded key you must set OCI_KEY_FINGERPRINT (matches the Console displayed fingerprint) OR
#     you can let the script compute it from the private key if available.
#
# Optional env vars:
#       OCI_PROFILE (default: DEFAULT)
#       OCI_CONFIG_DIR (default: ~/.oci)
#       OCI_KEY_FILE (path to private key; default: $OCI_CONFIG_DIR/oci_api_key.pem)
#       OCI_KEY_PASSPHRASE (optional passphrase if private key is encrypted; recommends none for automation)
#       OCI_GEN_KEY=1 (generate fresh 2048-bit key if no key exists)
#       DRY_RUN=1 (show what would be done, don't change filesystem)
#
# After running (if a new key was generated) upload the public key printed to stdout to: 
#   Console -> Identity -> Users -> <User> -> API Keys -> Add Public Key
# Then re-run this script to insert the fingerprint (or let it auto-detect).
#
# Exit codes:
#   0 success, 1 missing required vars, 2 key issues, 3 write/perm issues.
set -euo pipefail

err() { echo "[ERR] $*" >&2; }
log() { echo "[INF] $*" >&2; }
warn() { echo "[WRN] $*" >&2; }

tenancy=${OCI_TENANCY_OCID:-}
user=${OCI_USER_OCID:-}
region=${OCI_REGION:-}
profile=${OCI_PROFILE:-DEFAULT}
config_dir=${OCI_CONFIG_DIR:-$HOME/.oci}
config_file="$config_dir/config"
key_file=${OCI_KEY_FILE:-$config_dir/oci_api_key.pem}
need_gen=${OCI_GEN_KEY:-0}
passphrase=${OCI_KEY_PASSPHRASE:-}
fingerprint=${OCI_KEY_FINGERPRINT:-}
dry=${DRY_RUN:-0}

# Validate required
missing=()
[ -z "$tenancy" ] && missing+=(OCI_TENANCY_OCID)
[ -z "$user" ] && missing+=(OCI_USER_OCID)
[ -z "$region" ] && missing+=(OCI_REGION)
if [ ${#missing[@]} -gt 0 ]; then
  err "Missing required env vars: ${missing[*]}"
  exit 1
fi

if [ "$dry" = 1 ]; then
  log "DRY RUN mode enabled - no filesystem changes will occur."
fi

# Ensure dir
if [ ! -d "$config_dir" ]; then
  log "Creating dir $config_dir"
  [ "$dry" = 1 ] || mkdir -p "$config_dir"
fi

# Generate key if requested / missing
if [ ! -f "$key_file" ]; then
  if [ "$need_gen" = 1 ]; then
    log "Generating new API private key: $key_file"
    if [ "$dry" != 1 ]; then
      openssl genrsa -out "$key_file" 2048 >/dev/null 2>&1
      chmod 600 "$key_file"
      openssl rsa -in "$key_file" -pubout -out "$key_file.pub" >/dev/null 2>&1
      log "Public key saved to $key_file.pub -- upload this to the OCI Console (API Keys)."
    else
      log "(dry) Would generate RSA key pair at $key_file(.pub)"
    fi
  else
    err "Key file $key_file does not exist. Set OCI_GEN_KEY=1 to generate or provide OCI_KEY_FILE."
    exit 2
  fi
fi

# Compute fingerprint if not provided and key exists
if [ -z "$fingerprint" ] && [ -f "$key_file" ]; then
  if command -v openssl >/dev/null; then
    # Fingerprint method per OCI docs: MD5 of DER public key
    fingerprint=$(openssl rsa -in "$key_file" -pubout 2>/dev/null | openssl md5 -c 2>/dev/null | awk '{print $2}') || true
    [ -n "$fingerprint" ] && log "Detected fingerprint: $fingerprint" || warn "Could not derive fingerprint automatically."
  fi
fi

if [ -z "$fingerprint" ]; then
  warn "No fingerprint set yet. After uploading (or identifying) the key, export OCI_KEY_FINGERPRINT and re-run for full config."
fi

# Backup existing config
if [ -f "$config_file" ]; then
  ts=$(date +%Y%m%d-%H%M%S)
  log "Backing up existing config to $config_file.bak.$ts"
  [ "$dry" = 1 ] || cp "$config_file" "$config_file.bak.$ts"
fi

# Build new profile snippet
new_profile=$(cat <<EOF
[$profile]
tenancy=$tenancy
user=$user
region=$region
key_file=$key_file
EOF
)
[ -n "$fingerprint" ] && new_profile+=$'\nfingerprint='"$fingerprint"
[ -n "$passphrase" ] && new_profile+=$'\npass_phrase='"$passphrase"
new_profile+=$'\n'

# Merge: remove existing profile block then append
if [ -f "$config_file" ]; then
  tmp=$(mktemp)
  awk -v p="[$profile]" 'BEGIN{drop=0} {
    if($0==p){drop=1}
    else if(drop && /^\[/){drop=0}
    if(!drop) print $0
  } END{}' "$config_file" > "$tmp"
  [ "$dry" = 1 ] || mv "$tmp" "$config_file"
fi

log "Writing profile [$profile] to $config_file"
if [ "$dry" != 1 ]; then
  printf "%s" "$new_profile" >> "$config_file"
  chmod 600 "$config_file"
fi

log "Done. Next steps:"
log "1. If fingerprint was missing: upload public key (if generated) then set OCI_KEY_FINGERPRINT and re-run."
log "2. Test: oci os ns get --profile $profile"
log "3. Test bucket: oci os bucket get --name <bucket> --profile $profile"

