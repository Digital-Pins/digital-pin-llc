# SESSION LOG – Bootstrap Phase

Date: 2025-08-23
Branch: feature/user-filecache-toggle-bootstrap

Actions:
- Added Hetzner bootstrap script (nginx/php-fpm/mariadb skeleton) in parent repo.
- Rebuilt README (structure + smoke test).
- Captured Dolibarr per-user MAIN_ACTIVATE_FILECACHE toggle patch (docs/patches/dolibarr-filecache-toggle.patch).
<<<<<<< HEAD
- Added deployment scripts (apply-dolibarr-patch, nginx template) + restore-test backup script.
- Recorded ADR-001 repository structure decision (planned modular /services & /infra adoption).
- Created initial /services/ structure with placeholders (frontend-next, erp-dolibarr, lms-pinlearn, ai-pin-kit, api-gateway, monitoring) – content migration pending.
- Added ERP nginx config (standard + custom-cert variant) and documented custom certificate deployment steps.
=======
>>>>>>> 4645c57 (docs(security): add SECURITY.md, session log, and S3 backup script placeholder)

Pending:
- Backup script (S3) + systemd timer.
- SECURITY.md baseline.
- CI (GitHub Actions), Playwright e2e.
- Decide Dolibarr integration model.
<<<<<<< HEAD
- Apply ADR-001 structure (relocate frontend to services/ after initial PR merge).
=======
>>>>>>> 4645c57 (docs(security): add SECURITY.md, session log, and S3 backup script placeholder)

Risks:
- Dolibarr customization not versioned upstream yet.
- No automated backups implemented.

Next:
1. Merge bootstrap PR.
2. Implement backup + security docs.
3. Add CI pipeline and tests.

<<<<<<< HEAD
PR Comment Placed / To Place Externally:
- "Squash merge recommended to keep main clean." (Add this as a GitHub PR comment if not already included.)

---
Date: 2025-08-24
Branch: refactor/services-move-frontend (working context) / main staging

Actions:
- Centralized security headers include (nginx-security-headers.conf) with CSP (Report-Only) + COOP/CORP.
- Refactored nginx site configs (digitalpin + erp) to include shared headers file.
- Added CSP report collection API endpoint `/api/csp-report` (Next.js) + updated CSP header with report-uri.
- Added phased CSP hardening plan into AGENDA (CSP Hardening Plan table).
- Implemented ERP enable automation script `scripts/deploy/ubuntu-enable-erp.sh` (custom vs letsencrypt mode).
- Implemented Let’s Encrypt certificate request helper `scripts/deploy/request-letsencrypt-cert.sh`.
- Added local Content-Security-Policy-Report-Only adoption tasks to agenda.
- Added dev ERP nginx template `nginx-erp-dev.conf` for new subdomain dev-erp.digitalpin.online (isolated /opt/dolibarr-dev + shorter HSTS, optional Basic Auth).
- Added database helper script `create-dolibarr-db.sh` to provision isolated dev DB + user.
- Added dev security headers include `nginx-security-headers-dev.conf` (short HSTS, reuse CSP Report-Only).
- GitLab migration scaffolding: `.gitlab-ci.yml`, `docs/dev-hub/MIGRATION.md`, subtree push script `scripts/dev-hub/push-subtree.sh` (initial focus on dolibarr-custom subtree => dev-hub project).
- Added operational templates: PR template, deploy wrapper, sudoers example, authorized_keys example, environments matrix.
- Added provisioning script `setup-coco-dev-user.sh` for restricted deployment user.
- Added security/access docs: access-policy, logrotate example, limits example, updated environments matrix with Deploy User column.
- Added Phase 1 roadmap, S3 backup script, restore runbook (initial backup framework ready for integration & scheduling).
- Added OCI native backup script (oci-backup.sh) to avoid AWS tooling expansion.
- Added systemd service/timer templates for automated OCI backups + setup docs.
- Standardized Dev-Hub fixed path at /opt/dev-hub (service + docs updated, path conventions doc + prepare script added).

Pending:
- Integrate s3-backup.sh with systemd timer (daily) and test restore.
- Execute ERP enable script on production Ubuntu host (choose mode, likely letsencrypt).
- Confirm php-fpm socket path on Ubuntu and adjust nginx fastcgi_pass if needed.
- Run certificate issuance (if custom cert not final) and reload nginx.
- Begin CSP report collection (enable LOG_CSP_REPORTS=1) and review after 72h.
- Implement monitoring stack skeleton (Prometheus/Grafana).

Risks / Notes:
- ERP domain currently timing out (Nginx absent on target host) – blocked until Ubuntu-side deployment executed.
- Need to ensure DNS A record stable and Cloudflare proxy mode correct (grey cloud during LE issuance).
- Potential mismatch of php-fpm socket name (e.g. php8.2-fpm.sock) on Ubuntu vs generic php-fpm.sock used in template.

Next:
1. SSH to Ubuntu host and run ubuntu-enable-erp.sh (select cert mode) then verify 80/443.
2. If using LE: request-letsencrypt-cert.sh (if not embedded in prior step) then switch to full ERP config.
3. Verify headers + CSP report flow; start log sampling.
4. Document successful ERP bring-up in this log and close initial deployment milestone.

---
Date: 2025-08-25
Branch: ci/gitlab-hardening

Actions:

Pending (CI related):

Risks / Notes:

Next:
1. Populate KNOWN_HOSTS in GitLab variables using `ssh-keyscan -t ed25519 <host>`.
2. Add real static analysis tools & baseline suppressions.
3. Introduce minimal unit/integration tests for critical scripts.
4. Plan atomic deploy mechanism.

---
Date: 2025-08-26
Branch: refactor/services-move-frontend

Actions:
- Quick snapshot: created branch `preserve/site-snapshot-<timestamp>` and archived repository artifacts to `~/backups/digital-pin-llc/` to preserve the current published design and working state before further infra changes.

Next:
- Prepare full backup (webroot, uploads, DB dump) — will require sudo and DB credentials. Run as a controlled maintenance window to ensure consistency.



=======
>>>>>>> 4645c57 (docs(security): add SECURITY.md, session log, and S3 backup script placeholder)
