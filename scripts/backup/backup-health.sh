#!/usr/bin/env bash
set -euo pipefail
# backup-health.sh
# Emit simple Prometheus-style metrics about latest OCI Object Storage backup for a service.
#
# Metrics:
#   digitalpin_backup_latest_timestamp{service="<svc>"} <unix_epoch>
#   digitalpin_backup_age_seconds{service="<svc>"} <age>
#   digitalpin_backup_ok{service="<svc>"} 1|0
#   digitalpin_backup_objects_total{service="<svc>"} <count>
# Exit codes: 0 success (metrics emitted even if none found), 1 missing args, 2 oci failure.
#
# Usage (reads OCI CLI profile from env if set):
#   ./scripts/backup/backup-health.sh --bucket bucket-pin --service erp-dev [--profile DEFAULT] [--max-age 86400]
#
# Optional: place output into node_exporter textfile collector directory, e.g.:
#   ./backup-health.sh --bucket bucket-pin --service erp-dev > /var/lib/node_exporter/textfile_collector/backup_erp-dev.prom

BUCKET=""
SERVICE=""
PROFILE=""
MAX_AGE=0  # seconds; 0 = no threshold (still prints age)
INCLUDE_SIZE=0  # if 1, emit size metric for latest object

die(){ echo "[ERR] $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case $1 in
    --bucket) BUCKET=$2; shift 2;;
    --service) SERVICE=$2; shift 2;;
    --profile) PROFILE=$2; shift 2;;
  --max-age) MAX_AGE=$2; shift 2;;
  --include-size) INCLUDE_SIZE=1; shift;;
    -h|--help) grep '^# ' "$0" | sed 's/^# //'; exit 0;;
    *) die "Unknown arg: $1";;
  esac
done

[[ -n $BUCKET && -n $SERVICE ]] || die "--bucket and --service required"
command -v oci >/dev/null || die "oci CLI not found"

OCI_ARGS=()
[[ -n $PROFILE ]] && OCI_ARGS+=(--profile "$PROFILE")

set +e
JSON=$(oci "${OCI_ARGS[@]}" os object list --bucket-name "$BUCKET" --prefix "$SERVICE/" --fields name 2>/dev/null)
RC=$?
set -e
if (( RC != 0 )); then
  # Emit failure metrics
  now=$(date +%s)
  cat <<EOF
digitalpin_backup_ok{service="${SERVICE}"} 0
digitalpin_backup_latest_timestamp{service="${SERVICE}"} 0
digitalpin_backup_age_seconds{service="${SERVICE}"} 0
digitalpin_backup_objects_total{service="${SERVICE}"} 0
EOF
  exit 2
fi

# Extract object names (simple grep/sed to avoid jq dependency)
NAMES=$(echo "$JSON" | grep '"name"' | sed 's/.*"name": "\(.*\)".*/\1/' | grep "${SERVICE}_backup_" || true)
COUNT=0
LATEST=""
while IFS= read -r n; do
  [[ -z $n ]] && continue
  COUNT=$((COUNT+1))
  # Names are of form <service>_backup_YYYYmmdd-HHMMSS.tar.gz
  base=$(basename "$n")
  ts_part=${base#${SERVICE}_backup_}
  ts_part=${ts_part%.tar.gz}
  # Convert timestamp to epoch (assumes UTC format %Y%m%d-%H%M%S)
  epoch=$(date -u -d "${ts_part:0:8} ${ts_part:9:6}" +%s 2>/dev/null || echo 0)
  if [[ -z $LATEST ]]; then
    LATEST="$epoch $n"
  else
    read -r cur_epoch _ <<<"$LATEST"
    if (( epoch > cur_epoch )); then
      LATEST="$epoch $n"
    fi
  fi
done <<< "$NAMES"

latest_epoch=0
latest_name=""
if [[ -n $LATEST ]]; then
  read -r latest_epoch latest_name <<<"$LATEST"
fi

now=$(date +%s)
age=0
(( latest_epoch > 0 )) && age=$(( now - latest_epoch ))

OK=1
if (( latest_epoch == 0 )); then
  OK=0
elif (( MAX_AGE > 0 && age > MAX_AGE )); then
  OK=0
fi

size_metric=""
if (( INCLUDE_SIZE == 1 )) && (( latest_epoch > 0 )); then
  # Query object HEAD for size (Content-Length)
  set +e
  HEAD=$(oci "${OCI_ARGS[@]}" os object head --bucket-name "$BUCKET" --object-name "$latest_name" 2>/dev/null)
  HR=$?
  set -e
  if (( HR == 0 )); then
    # Extract content length
    bytes=$(echo "$HEAD" | grep -i 'content-length' | sed 's/.*: \([0-9][0-9]*\).*/\1/' | head -1)
    if [[ -n ${bytes:-} ]]; then
      size_metric="digitalpin_backup_latest_size_bytes{service=\"${SERVICE}\"} $bytes"
    fi
  fi
fi

cat <<EOF
digitalpin_backup_ok{service="${SERVICE}"} $OK
digitalpin_backup_latest_timestamp{service="${SERVICE}"} $latest_epoch
digitalpin_backup_age_seconds{service="${SERVICE}"} $age
digitalpin_backup_objects_total{service="${SERVICE}"} $COUNT
EOF
[[ -n $size_metric ]] && echo "$size_metric"

exit 0
