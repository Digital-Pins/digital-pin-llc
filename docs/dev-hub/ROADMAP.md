# Digital PIN Dev-Hub – Phase 1 Roadmap

Goal: Establish a secure, observable, reproducible multi-service development hub (Dolibarr first, extend to Edu + AI).

## Milestones

### M1 – Foundational Bootstrap (Week 1)
- [x] Hetzner bootstrap script & README overhaul
- [x] Security headers + CSP (Report-Only) + reporting endpoint
- [x] ERP (custom) HTTPS + automated sync scripts
- [x] Dev ERP environment (short HSTS)
- [x] Access & provisioning (coco-dev user, wrapper, sudoers examples)
- [x] GitLab project + CI scaffold
- [ ] Backup (code + DB + documents) scripted & documented
- [ ] Ops Access Policy & Environments matrix (initial) (partial)

### M2 – Reliability & Observability (Week 2)
- [ ] Backup S3 integration + retention + restore runbook
- [ ] Monitoring stack (Prometheus + Grafana docker-compose skeleton)
- [ ] Central log rotation & size thresholds
- [ ] Health endpoints for each service
- [ ] CSP tighten pass (remove unsafe-eval if feasible)

### M3 – Service Expansion (Week 3)
- [ ] ERP demo (vanilla) environment
- [ ] Edu platform demo/custom folder skeleton
- [ ] AI API playground stub (OpenAPI doc + stub handler)
- [ ] Hub landing (links + status badges + env matrix)

### M4 – Security Hardening (Week 4)
- [ ] mTLS / or Access gate for custom & staging
- [ ] Secret scanning hook (pre-push) + CI job
- [ ] SAST / dependency scan (GitLab or OSS tools)
- [ ] CSP enforcement (move from Report-Only)

### M5 – Automation & Governance
- [ ] ADRs for: Backup Strategy, Monitoring Stack choice, Secret Management
- [ ] Scheduled pipeline: nightly sync + integrity report
- [ ] Cost monitoring & resource tagging (Hetzner + Cloudflare zones)

## Tracking
Link issues to milestones: M1 .. M5. Update SESSION-LOG.md upon completion of each checklist item.
