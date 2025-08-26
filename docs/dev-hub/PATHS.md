# Dev-Hub Path Conventions

Decision Date: 2025-08-24

## Fixed Root
All Dev-Hub integration scripts expect a stable checkout (or exported subset) at:
```
/opt/dev-hub
```

Rationale:
- Avoid confusion with other servers / repos (e.g. production or separate mono-repo clones under `/opt/digital-pin-llc`).
- Predictable absolute paths inside systemd unit definitions, cron/systemd timers, and reverse proxy includes.
- Simplifies future service templates (e.g. `/opt/dev-hub/infra/docker/...`).

## Layout Under /opt/dev-hub (Target State)
| Path | Purpose |
|------|---------|
| /opt/dev-hub/scripts | Operational & deploy scripts |
| /opt/dev-hub/docs    | Documentation synced from VCS |
| /opt/dev-hub/apps    | Service source trees (custom) |
| /opt/dev-hub/infra   | Infra as code (terraform/ansible/docker) |
| /opt/dev-hub/tmp     | Ephemeral build / packaging space (gitignored) |

## Deployment Options
1. Full git clone into `/opt/dev-hub` (dev-friendly).  
2. CI artifact extract (clean, no .git) for “immutable” deploy nodes.  
3. Hybrid: git clone + periodic `git pull` guarded by signature verification (future).

## Symlinks
Legacy references may use `/srv/dev-hub`; create a symlink if needed:
```
sudo ln -sfn /opt/dev-hub /srv/dev-hub
```

## Ownership & Permissions
- Root owns base path: `root:root` 755 to prevent accidental mutation by non-privileged users.
- Write operations (e.g. build artifacts) go to `/opt/dev-hub/tmp` which can be group‑writable (deploy group) if required.

## Backups
Backup scripts reference only data state (DB dumps & documents) not the git working tree. Code is reproducible from upstream VCS.

## Next Steps
- Adjust any remaining scripts referencing `/srv/digital-pin-llc` or other transitional paths.
- Add CI variable `DEVHUB_ROOT=/opt/dev-hub` and source it inside future deployment jobs.
