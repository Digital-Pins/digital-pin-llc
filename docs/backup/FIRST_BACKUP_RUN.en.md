# First Backup Run (ERP Dev -> OCI Object Storage)

Purpose: Provide a standardized, reproducible procedure for the first successful OCI backup of the dev ERP (Dolibarr) environment using the unified script `scripts/backup/oci-backup.sh`.

## Scope
- Environment: erp-dev (Dolibarr customized instance)
- Assets: MariaDB schema (dolibarr_dev) + documents directory + optional extras
- Target: OCI Object Storage bucket `bucket-pin` (versioning enabled)
- Tooling: OCI CLI + `oci-backup.sh` + systemd timer

## Preconditions
1. OCI CLI installed and configured (`~/.oci/config` for user running backup or root).
2. Bucket `bucket-pin` exists and user has put/list/delete permissions.
3. DB credentials file present (e.g. `/root/dolibarr_dev-db.creds`, mode 600, contains only the password line).
4. Documents path exists: `/opt/dolibarr-dev/htdocs/documents`.
5. Script deployed to `/opt/dev-hub/scripts/backup/oci-backup.sh`.

## Variables
| Name | Example | Notes |
|------|---------|-------|
| SERVICE | erp-dev | Used as logical tag & prefix (unless `--prefix` provided) |
| DB_NAME | dolibarr_dev | Empty -> skip DB dump |
| DB_USER | dolibarr_dev | Prefer non-root DB user |
| DB_PASS_FILE | /root/dolibarr_dev-db.creds | Password only; no key= value |
| DOCS_PATH | /opt/dolibarr-dev/htdocs/documents | Optional; will warn if missing |
| BUCKET | bucket-pin | Must pre-exist |
| RETAIN | 7 | Number of newest archives to keep (per service) |

## Quick Credential Check
```
mysql -u dolibarr_dev -p"$(cat /root/dolibarr_dev-db.creds)" dolibarr_dev -e "SHOW TABLES LIMIT 3;"
```
Expect rows -> credentials OK.

## Dry Run
```
sudo bash /opt/dev-hub/scripts/backup/oci-backup.sh \
  --service erp-dev \
  --bucket bucket-pin \
  --db-name dolibarr_dev \
  --db-user dolibarr_dev \
  --db-pass-file /root/dolibarr_dev-db.creds \
  --documents-path /opt/dolibarr-dev/htdocs/documents \
  --retain 7 \
  --dry-run
```
Verify: No errors, shows planned upload & pruning.

## First Real Backup
```
sudo bash /opt/dev-hub/scripts/backup/oci-backup.sh \
  --service erp-dev \
  --bucket bucket-pin \
  --db-name dolibarr_dev \
  --db-user dolibarr_dev \
  --db-pass-file /root/dolibarr_dev-db.creds \
  --documents-path /opt/dolibarr-dev/htdocs/documents \
  --retain 7
```

## Post-Run Verification
```
oci os object list --bucket-name bucket-pin --prefix erp-dev/ | grep erp-dev_backup_
```
(Optional) integrity sample:
```
OBJ=$(oci os object list --bucket-name bucket-pin --prefix erp-dev/ --fields name | grep 'erp-dev_backup_' | head -1 | sed 's/.*"name": "\(.*\)".*/\1/')
oci os object get --bucket-name bucket-pin --name "$OBJ" --file /tmp/test.tar.gz
sha256sum /tmp/test.tar.gz
```
Compare with the `.sha256` object of same name.

## Systemd Scheduling
Install units (if not yet):
```
sudo install -m 644 /opt/dev-hub/scripts/backup/systemd/devhub-oci-backup.service /etc/systemd/system/
sudo install -m 644 /opt/dev-hub/scripts/backup/systemd/devhub-oci-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now devhub-oci-backup.timer
systemctl list-timers | grep devhub-oci-backup
```
Manual trigger:
```
sudo systemctl start devhub-oci-backup.service
journalctl -u devhub-oci-backup.service -n 50 --no-pager
```

## Best Practices
- Use dedicated DB user with least privileges.
- File permissions: credentials (600 root:root), private OCI key (600 coco-dev), config (600).
- Keep bucket versioning enabled for recoverability.
- Monitor backup success via journal scraping or future Prometheus exporter.
- Avoid exposing password on command line (already avoided by pass file). Future improvement: use `--defaults-extra-file` temporary file.

## Comparison: Why Not a Separate backup.sh?
| Aspect | Unified oci-backup.sh | Ad-hoc backup.sh |
|--------|----------------------|------------------|
| Single archive + checksum | Yes | No checksum, multiple files |
| Remote retention pruning | Yes | No |
| Prefix/service structuring | Yes | Manual |
| Less password exposure | Yes | No (mysqldump -p) |
| Duplication risk | Low | High |

## Success Checklist
| Item | Status |
|------|--------|
| DB connectivity validated | ✅ |
| Dry run clean | ✅ |
| First archive uploaded | ✅ |
| Checksum verified | ✅ |
| Retention policy confirmed (after >7 runs) | ⏳ |
| Timer active | ✅ |

## Next Steps
- Extend to prod (`erp-prod`).
- Add monitoring hook (exporter or simple health file).
- Integrate restore drills quarterly.

## Reference Docs
- `docs/backup/OCI_BACKUP_SETUP.md`
- `docs/backup/RESTORE_RUNBOOK.md`
