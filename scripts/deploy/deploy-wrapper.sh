#!/usr/bin/env bash
set -euo pipefail
# Restricted deployment wrapper for user (e.g.) coco-dev via authorized_keys forced command.
# Whitelist only the minimal allowed operations.

LOG_FILE="/var/log/devhub-deploy.log"
exec >>"$LOG_FILE" 2>&1
echo "==== $(date -u +%Y-%m-%dT%H:%M:%SZ) deploy-wrapper invoked by $USER ===="

cmd=${1:-}
case "$cmd" in
  sync-erp-dev)
    echo "[ACTION] Sync ERP dev instance";
    sudo /usr/bin/env bash -c 'cd /srv/devhub && scripts/deploy/sync-dolibarr-dev.sh';
    ;;
  reload-nginx)
    echo "[ACTION] Nginx test + reload";
    sudo nginx -t && sudo systemctl reload nginx;
    ;;
  tail-log)
    echo "[ACTION] Tail last 200 lines of dev ERP nginx error log";
    sudo tail -n 200 /var/log/nginx/dev_erp.error.log;
    ;;
  version)
    echo "deploy-wrapper version 1.0";
    ;;
  *)
    echo "[DENY] Command not permitted: $cmd";
    exit 2;
    ;;
esac
echo "[DONE]"
