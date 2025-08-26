# Restore Runbook (Dolibarr / Generic Service)

Updated for OCI backups + automated restore drill script.

## 1. Identify Backup (OCI)
List remote objects by prefix:
```
oci os object list --bucket-name bucket-pin --prefix erp-dev/ --fields name
```

## 2. Download & Verify
```
oci os object get --bucket-name bucket-pin --name erp-dev/erp-dev_backup_YYYYMMDD-HHMMSS.tar.gz --file /tmp/erp-dev_backup.tar.gz
oci os object get --bucket-name bucket-pin --name erp-dev/erp-dev_backup_YYYYMMDD-HHMMSS.tar.gz.sha256 --file /tmp/erp-dev_backup.tar.gz.sha256
cd /tmp && sha256sum -c erp-dev_backup.tar.gz.sha256
```

## 3. Extract
```
mkdir -p /tmp/restore-test
tar -xzf /tmp/erp-dev_backup_*.tar.gz -C /tmp/restore-test
```

Artifacts inside (oci-backup.sh format):
- SQL dump: `<service>_<db>_<timestamp>.sql`
- documents.tar.gz (contains the documents tree)
- extra_*.tar.gz (if provided)

## 4. Database Restore (Test)
```
mysql -u root -p -e 'CREATE DATABASE restore_test;'
mysql -u root -p restore_test < /tmp/restore-test/**/<service>_<db>_*.sql
```

## 5. Point an ephemeral instance (optional) to restored DB & documents for validation.

## 5a. Automated Restore Drill (Preferred)
Script: `scripts/backup/restore-drill.sh`
Example (latest archive, temp DB import, keep workdir):
```
sudo bash scripts/backup/restore-drill.sh --service erp-dev --bucket bucket-pin --import-db --keep-work --verbose
```
Options:
- `--archive prefix/objectname` use specific object (else newest)
- `--db-name name` custom temp DB name
- `--keep-work` retain extracted files for manual inspection
- `--profile PROFILE` use specific OCI CLI profile

## 5b. Manual Ephemeral Instance Validation
Point a staging Dolibarr config to the restored DB + extracted documents to validate business functionality.

## 6. Production Restore (If Approved)
1. Put service in maintenance mode (Nginx 503 or app flag).
2. Backup current state (tar current docs + fresh mysqldump).
3. Import SQL into target DB.
4. Replace documents directory atomically (rsync + move).
5. Clear caches if applicable.
6. Remove maintenance mode.
7. Validate functional & logs.

## 7. Post-Restore
- Record action in SESSION-LOG.md
- Create incident ticket if triggered by failure.

## 8. Rollback
## 9. Metrics & Monitoring
Leverage `scripts/backup/backup-health.sh` to ensure recent backup availability; extend drill script as a periodic validation (e.g., weekly) without import (`--import-db` optional to reduce load).

If restore breaks > revert using the pre-restore backup from step 2.
