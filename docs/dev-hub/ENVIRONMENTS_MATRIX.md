# Environments Matrix (Dev Hub)

| Service | Domain | Type (demo/custom/staging/prod) | Access Model | DB Name | Deploy Method | Monitoring | Owner | Deploy User | Notes |
|---------|--------|----------------------------------|--------------|---------|---------------|------------|-------|-------------|-------|
| ERP     | erp.digitalpin.online        | custom (prod-ish) | Restricted (ACL) | dolibarr | manual script → future CI | planned | ops | root (temp) | HTTPS, CSP report-only |
| ERP Dev | dev-erp.digitalpin.online    | custom dev         | Basic Auth / key | dolibarr_dev | CI (manual trigger) | planned | ops | coco-dev | Short HSTS |
| ERP Demo| erp.demo.digitalpin.online   | demo vanilla       | Public           | dolibarr_demo | container compose | todo | ops | tbd | To provision |
| EDU Demo| edu.demo.digitalpin.online   | demo vanilla       | Public           | edu_demo | compose | todo | edu-team | tbd | Placeholder |
| EDU Dev | edu.custom.digitalpin.online | custom dev         | Auth (mTLS?)     | edu_dev | CI/CD | todo | edu-team | tbd | Placeholder |
| AI API  | ai.api.digitalpin.online     | api playground     | Token / mTLS     | n/a | container | todo | ai-team | tbd | Rate limits |
| Hub     | hub.digitalpin.online        | landing / status   | Public           | n/a | static build | todo | ops | tbd | Links matrix |
| Files   | files.digitalpin.online      | assets browser     | Auth             | n/a | container | todo | ops | tbd | Filebrowser |
| Admin   | admin.digitalpin.online      | infra cockpit      | Restricted       | n/a | container | todo | ops | tbd | Cockpit + Grafana |

Update this table upon each environment change; reference from Ops Manual.
