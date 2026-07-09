# Documentation

Documentation will be developed alongside the system rather than added after
the implementation.

## Planned sections

- [CI/CD pipeline](ci-cd.md)
- [Platform add-ons](platform-addons.md)
- [Local container deployment](deployment/local-container.md)
- [GitOps application deployment](deployment/gitops-application.md)
- [Production-inspired deployment guide](deployment/production-deployment-guide.md)
- [Verification checklist](deployment/verification-checklist.md)
- [Operations runbooks](operations/runbooks.md)
- [Rollback guide](operations/rollback.md)
- [Secrets management](security/secrets-management.md)
- [Monitoring foundation](observability/monitoring.md)
- [Alertmanager routing](observability/alertmanager-routing.md)
- [Grafana hardening](observability/grafana-hardening.md)
- [CloudWatch logging](observability/cloudwatch-logging.md)

- `deployment/`: prerequisites, bootstrap, deployment, verification, and
  teardown.
- `operations/`: runbooks, rollback, recovery, and troubleshooting.
- `security/`: identity, secrets, trust boundaries, and hardening.
- `cost/`: estimates, budget controls, and optimization.
- `portfolio/`: interview guide, STAR stories, resume bullets, lessons
  learned, future improvements, LinkedIn post, and screenshot checklist.
- `reference/`: glossary and supporting technical notes.

Only documentation backed by implemented and verified behavior will be marked
complete.
