# SECURITY (Bootstrap Placeholder)

## Scope
Next.js frontend + Dolibarr customization (external) + infra bootstrap.

## Immediate Hardening
- Enforce SSH key-only auth once verified.
- Add Fail2Ban (ssh & nginx) – jail.local planned.
- Regular package updates (cron / unattended-upgrades).

## Backups
Planned S3 (Hetzner object storage) daily snapshot via `scripts/backup/s3-backup.sh` (retention 7d).

## Dependencies
Weekly audit: `npm audit --omit=dev` & `npm outdated`.

## Reporting
Private issue or security email (TBD) – do NOT disclose sensitive details publicly.

