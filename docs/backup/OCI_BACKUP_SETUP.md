# OCI Backup Automation Setup

> Quick start / first full manual run guides:
> - English walkthrough: `docs/backup/FIRST_BACKUP_RUN.en.md`
> - Arabic walkthrough: `docs/backup/FIRST_BACKUP_RUN.ar.md`

## 1. Prerequisites
1. OCI CLI installed (`pip install oci-cli` or package).
2. Configured auth (user/instance principal). Test: `oci os ns get`.
3. Bucket created (e.g. `DEVHUB_BACKUPS`).
4. Password file for DB at `/root/dolibarr_dev-db.pass` (contents = password only, mode 600).

## 2. Adjust Service Template (if needed)
File: `scripts/backup/systemd/devhub-oci-backup.service`
Edit flags (bucket, db name, documents path, retain) before installation.
Ensure repository (or exported scripts subset) is present at `/opt/dev-hub` (standard fixed path) so ExecStart path remains stable.

## 3. Install systemd Units
```bash
sudo install -m 644 scripts/backup/systemd/devhub-oci-backup.service /etc/systemd/system/
sudo install -m 644 scripts/backup/systemd/devhub-oci-backup.timer /etc/systemd/system/
sudo ln -sfn /opt/dev-hub /srv/dev-hub 2>/dev/null || true  # (optional legacy symlink)
sudo systemctl daemon-reload
sudo systemctl enable --now devhub-oci-backup.timer
```

## 4. Test Run
```bash
sudo systemctl start devhub-oci-backup.service
journalctl -u devhub-oci-backup.service -n 100 --no-pager
```

## 5. Verify in Bucket
List objects under prefix `erp-dev/`:
```bash
oci os object list --bucket-name DEVHUB_BACKUPS --prefix erp-dev/
```

## 6. Retention
Retention handled inside script (`--retain 7`). Timer runs daily at 02:15 UTC (+ random jitter up to 15 min).

## 7. Security Hardening
- Service runs as root with tightened systemd sandboxing.
- Remove capabilities not required if DB dump works without CHOWN/FOWNER (test then prune CapabilityBoundingSet).
- Keep password file mode 600 root:root.

## 8. Restore Reference
See `docs/backup/RESTORE_RUNBOOK.md` (adapt commands using `oci os object get` instead of `aws s3 cp`). For context on how the initial archive was produced, consult `FIRST_BACKUP_RUN.en.md` or `FIRST_BACKUP_RUN.ar.md`.

## 9. Future Enhancements
- Add Prometheus textfile metric export (backup timestamp + size).
- Add notification hook (email / webhook) on failure via `OnFailure=` + a notifier unit.
 - (Implemented) Simple metrics script: `scripts/backup/backup-health.sh` (see below Quick Metrics).

### Quick Metrics (Optional)
Generate Prometheus-friendly metrics (latest backup epoch, age, object count, ok flag):
```
sudo bash scripts/backup/backup-health.sh --bucket bucket-pin --service erp-dev --max-age 900 > /var/lib/node_exporter/textfile_collector/backup_erp-dev.prom
```
Interpretation:
| Metric | Meaning |
|--------|---------|
| digitalpin_backup_ok | 1=healthy (latest exists & within max-age if set) |
| digitalpin_backup_latest_timestamp | Unix epoch of newest archive |
| digitalpin_backup_age_seconds | Age in seconds (now - latest) |
| digitalpin_backup_objects_total | Count of matching archives in prefix |
| digitalpin_backup_latest_size_bytes | (Optional --include-size) size of latest archive |

