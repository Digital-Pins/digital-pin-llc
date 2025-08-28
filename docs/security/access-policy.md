# Access Policy (Dev Hub)

Principle: Least privilege, environment isolation, traceability.

## Accounts
| Account | Purpose | Auth | Sudo Scope | Rotation | Notes |
|---------|---------|------|------------|----------|-------|
| coco-dev | Dev deployments (ERP dev) | SSH key forced-command | nginx reload, php-fpm restart, sync script, tail log | 90d review | No DB direct access |
| (future) ci-bot | CI/CD automated deploys | Deploy key / token | none (runs in pipeline) | 90d | GitLab protected variables |

## SSH Key Policy
1 key per role. No key reuse across GitHub/GitLab/server. Forced commands for limited actions.

## Secrets Storage
Non-production creds: /etc/devhub-secrets (750 root:deploy). Production secrets kept off this host.

## Allowed Commands (coco-dev)
- sync ERP dev code
- test & reload nginx
- restart php-fpm (version-specific)
- read last lines of dev ERP error log

## Prohibited
- Direct DB shells
- Arbitrary docker access (root escalation risk)
- Editing system config outside whitelisted commands

## Review Cadence
Quarterly: keys validity, sudoers diff, rotation schedule.

## Incident Response
Revoke key (remove from authorized_keys) → lock user → rotate any exposed secrets → update SESSION-LOG.md.
