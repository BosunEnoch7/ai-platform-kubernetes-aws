# Screenshots and running evidence

This folder stores sanitized running evidence from a real deployment window.

The project should not commit invented cloud screenshots. If the AWS
environment has been torn down to control cost, use the evidence manifest in
[`docs/portfolio/evidence.md`](../docs/portfolio/evidence.md) and capture these
screenshots during the next short live demo.

Do not commit:

- AWS access keys;
- secret values;
- bearer tokens;
- private keys;
- sensitive account details;
- private customer or user data.

## Recommended files

Use descriptive names such as:

```text
01-github-readme.png
02-github-actions-ci-passing.png
03-ecr-image-tag.png
04-eks-cluster-overview.png
05-argocd-apps-healthy.png
06-ai-platform-pods-ready.png
07-hpa-status.png
08-ingress-alb-address.png
09-health-live-response.png
10-inference-response.png
11-prometheus-target-up.png
12-grafana-dashboard.png
13-cloudwatch-logs.png
```

## Capture checklist

The full checklist lives at:

```text
docs/portfolio/screenshots-checklist.md
```

Add screenshots only after the infrastructure is deployed and verified. After
capture, tear down the environment using
[`docs/cost/teardown.md`](../docs/cost/teardown.md).
