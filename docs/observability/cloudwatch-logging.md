# CloudWatch logging

This project sends Kubernetes application container logs to CloudWatch Logs with
AWS for Fluent Bit.

## Logging flow

```text
FastAPI app
→ JSON logs to stdout/stderr
→ container runtime log files on EKS nodes
→ AWS for Fluent Bit DaemonSet
→ CloudWatch Logs log group
```

## Why the app logs to stdout

Kubernetes workloads should normally write logs to stdout/stderr. A node-level
collector ships those logs to the logging backend.

This keeps the app independent of AWS logging SDKs and avoids giving every app
direct CloudWatch permissions.

## Terraform ownership

Terraform creates:

- the CloudWatch Logs log group;
- retention policy;
- AWS for Fluent Bit IRSA role;
- IAM permissions to write log streams and events.

The dev application log group is:

```text
/aws/eks/ai-platform-kubernetes-aws-dev/application
```

Retention is `30` days by default.

## GitOps ownership

Argo CD installs AWS for Fluent Bit from the pinned AWS EKS Helm chart.

The Application manifest lives at:

```text
argocd/platform-addons/aws-for-fluent-bit.yaml
```

## Security considerations

- Do not log prompts, API keys, tokens, request bodies, or secrets.
- Use structured logs with stable fields.
- Keep log retention intentional; infinite retention is expensive.
- Use IAM scoped to the intended log group.

## Production improvements

- Split log groups by namespace or workload criticality.
- Add metric filters for high-value errors.
- Enable subscription filters to a SIEM if required.
- Add CloudWatch Logs Insights saved queries.
- Use data protection policies to detect sensitive data patterns.
