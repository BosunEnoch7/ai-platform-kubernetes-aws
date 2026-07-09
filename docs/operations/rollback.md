# Rollback guide

Rollback should be boring. This project uses immutable image tags and GitOps so
rollback means returning Git to a known-good desired state.

## Application rollback

Find the last known-good image tag:

```powershell
git log --oneline
```

Update the Argo CD Application image tag parameter:

```yaml
image.tag: <last-known-good-git-sha>
```

Commit and push the change. Argo CD will reconcile the Deployment.

Verify:

```powershell
kubectl rollout status deployment/ai-inference-ai-inference -n ai-platform
kubectl get pods -n ai-platform
```

## Helm chart rollback

If the chart template changed badly, revert the Git commit that changed the
chart:

```powershell
git revert <commit-sha>
```

Push the revert and let Argo CD reconcile.

## Platform add-on rollback

For add-ons, rollback by reverting the chart version or Helm values in the
relevant Argo CD Application.

Examples:

- `argocd/platform-addons/ingress-nginx.yaml`
- `argocd/platform-addons/kube-prometheus-stack.yaml`
- `argocd/platform-addons/aws-for-fluent-bit.yaml`

Platform rollback should be slower and more deliberate than app rollback
because add-ons can affect many workloads.

## Terraform rollback

Terraform rollback is not the same as application rollback.

If an infrastructure change is bad:

1. Revert the Terraform commit.
2. Run `terraform plan`.
3. Review the proposed changes carefully.
4. Apply only after confirming no destructive surprise.

Never run destructive Terraform changes just to “get back quickly” without
reviewing the plan.

## Emergency manual intervention

Manual cluster changes may be needed during incidents, but they create drift.

If you manually patch something:

1. Record the exact command.
2. Open a follow-up issue.
3. Convert the fix back into Git/Terraform.
4. Let Argo CD or Terraform own the final state.
