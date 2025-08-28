## Title
infra + docs bootstrap (Hetzner script + README smoke test)

## Summary
- Adds initial Hetzner provisioning script (`bootstrap_digitalpin_hetzner.sh`).
- Overhauls `README.md` (Arabic + structured + smoke test section).
- Stores Dolibarr per-user filecache toggle patch under `docs/patches/` (reference only; not applied upstream yet).

## Verification Checklist
- [ ] `bootstrap_digitalpin_hetzner.sh` is executable and shellcheck clean (or documented exceptions)
- [ ] README smoke test commands run successfully on a fresh Hetzner VM
- [ ] Patch file present at `docs/patches/dolibarr-filecache-toggle.patch`
- [ ] `SESSION-LOG.md` updated with this PR context
- [ ] No secrets or credentials committed
- [ ] CI passes (lint/tests) (if configured)

## Next Steps (Not in this PR)
- Decide Dolibarr integration strategy (submodule vs fork vs patch set)
- Add backup script (`scripts/backup/s3-backup.sh`) and baseline `SECURITY.md`
- Plan CI/CD pipeline and initial Playwright e2e tests

## Labels
infra, docs, bootstrap

## Merge Strategy
Squash merge recommended to keep main history clean.

## Additional Notes
Provide any deviations, assumptions, or follow‑up ADR references here.
