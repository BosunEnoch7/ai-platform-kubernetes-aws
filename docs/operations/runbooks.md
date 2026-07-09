# Operations runbooks

Runbooks are short, repeatable procedures for common operational events.

## Runbook: app rollout stuck

Symptoms:

- Argo CD app is `Progressing` for too long.
- Deployment has unavailable replicas.

Check:

```powershell
kubectl describe application ai-inference -n argocd
kubectl rollout status deployment/ai-inference-ai-inference -n ai-platform
kubectl describe pods -n ai-platform
```

Common causes:

- image tag does not exist in ECR;
- IRSA annotation is wrong;
- ExternalSecret did not create the Kubernetes Secret;
- readiness probe is failing.

Recovery:

1. Fix the bad Git value.
2. Let Argo CD self-heal.
3. If urgent, roll back the image tag to the last known-good commit SHA.

## Runbook: ExternalSecret not ready

Check:

```powershell
kubectl describe externalsecret -n ai-platform
kubectl logs -n external-secrets deploy/external-secrets
```

Common causes:

- AWS secret value was never inserted;
- External Secrets IRSA role ARN is wrong;
- IAM policy does not include the secret ARN;
- KMS decrypt permission is missing.

Recovery:

1. Confirm Terraform output `external_secrets_role_arn`.
2. Confirm AWS Secrets Manager secret exists.
3. Confirm secret value contains the expected `api_key` property.
4. Re-sync the Argo CD app.

## Runbook: ALB returns 404

A 404 often means the ALB can reach NGINX but NGINX has no matching app route.

Check:

```powershell
kubectl get ingress -n ingress-nginx
kubectl get ingress -n ai-platform
kubectl describe ingress -n ai-platform
```

Common causes:

- host header does not match the app Ingress host;
- app Ingress class is not `nginx`;
- NGINX controller is not running;
- app Service has no endpoints.

Recovery:

1. Test with the correct host header.
2. Verify app pods are Ready.
3. Verify Service endpoints exist.

## Runbook: HPA not scaling

Check:

```powershell
kubectl describe hpa -n ai-platform
kubectl top pods -n ai-platform
kubectl get pods -n kube-system | Select-String metrics
```

Common causes:

- Metrics Server not installed or unhealthy;
- container CPU requests are missing;
- load is too low to exceed target utilization.

Recovery:

1. Fix Metrics Server.
2. Confirm the Deployment has CPU requests.
3. Generate controlled load and observe HPA events.

## Runbook: no logs in CloudWatch

Check:

```powershell
kubectl get pods -n amazon-cloudwatch
kubectl logs -n amazon-cloudwatch -l app.kubernetes.io/name=aws-for-fluent-bit
aws logs describe-log-groups --log-group-name-prefix /aws/eks/ai-platform-kubernetes-aws-dev/application
```

Common causes:

- AWS for Fluent Bit IRSA role annotation is wrong;
- log group name mismatch;
- IAM policy does not allow `logs:PutLogEvents`;
- collector pods cannot reach CloudWatch Logs.

Recovery:

1. Confirm Terraform output `aws_for_fluent_bit_role_arn`.
2. Confirm `autoCreateGroup` is false and log group exists.
3. Check collector logs for AWS API errors.

## Runbook: high inference latency alert

Check:

```powershell
kubectl top pods -n ai-platform
kubectl get hpa -n ai-platform
kubectl logs -n ai-platform deploy/ai-inference-ai-inference
```

Common causes:

- CPU saturation;
- provider slowdown;
- too few replicas;
- downstream dependency issues.

Recovery:

1. Confirm HPA behavior.
2. Scale replicas temporarily if needed.
3. Check provider failures and app logs.
4. Roll back recent image changes if latency started after deployment.
