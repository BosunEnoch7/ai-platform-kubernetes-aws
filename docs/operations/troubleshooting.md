# Troubleshooting guide

This guide helps diagnose common failure modes in the AI platform.

Use the pattern:

```text
Symptom → narrow the layer → inspect events/logs → fix source of truth
```

Do not start by randomly restarting pods. Find the ownership layer first:

| Symptom area | Likely owner |
|---|---|
| AWS resources, IAM, VPC, EKS | Terraform |
| Controller install or drift | Argo CD platform add-ons |
| App pods, HPA, Service, Ingress | Argo CD app + Helm chart |
| Secret values | AWS Secrets Manager + External Secrets |
| Metrics and alerts | Prometheus stack |
| Logs | AWS for Fluent Bit + CloudWatch Logs |

## Terraform failures

### Symptom

`terraform validate` or `terraform plan` fails.

### Check

```powershell
terraform -chdir=terraform fmt -recursive -check
terraform -chdir=terraform/environments/dev init -backend=false
terraform -chdir=terraform/environments/dev validate
```

### Likely causes

- module was added but `terraform init` was not re-run;
- provider download failed;
- variable type mismatch;
- AWS credentials are missing for plan/apply.

### Fix

- run `terraform init` again after module changes;
- validate locally before applying;
- never apply until the plan is reviewed.

## EKS nodes not Ready

### Symptom

```powershell
kubectl get nodes
```

shows nodes as `NotReady` or no nodes appear.

### Check

```powershell
kubectl describe nodes
kubectl get pods -n kube-system
terraform -chdir=terraform/environments/dev output eks_node_group_name
```

### Likely causes

- node group did not create successfully;
- worker nodes cannot reach required AWS APIs;
- VPC CNI is unhealthy;
- subnet or security group configuration is wrong.

### Fix

- review Terraform apply output;
- inspect EKS node group health in AWS;
- check `aws-node`, `coredns`, and `kube-proxy` pods.

## Argo CD Application degraded

### Symptom

Argo CD shows `Degraded`, `OutOfSync`, or stuck `Progressing`.

### Check

```powershell
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd
```

### Likely causes

- placeholder values were not replaced;
- Helm chart cannot render;
- CRDs are missing;
- target namespace cannot be created;
- Git repository URL is wrong.

### Fix

- fix the manifest in Git;
- commit and push;
- let Argo CD reconcile;
- avoid manual patching unless it is an emergency.

## ImagePullBackOff

### Symptom

AI inference pods show `ImagePullBackOff`.

### Check

```powershell
kubectl get pods -n ai-platform
kubectl describe pod <pod-name> -n ai-platform
```

### Likely causes

- image tag does not exist in ECR;
- wrong ECR repository URL;
- node IAM lacks ECR pull permission;
- image was not pushed by GitHub Actions.

### Fix

- confirm the GitHub Actions container workflow succeeded;
- verify `image.repository` and `image.tag`;
- use the full Git SHA tag, not `latest`.

## Pods running but not Ready

### Symptom

Deployment exists, but pods fail readiness.

### Check

```powershell
kubectl describe pod <pod-name> -n ai-platform
kubectl logs <pod-name> -n ai-platform
kubectl get secret -n ai-platform ai-provider
```

### Likely causes

- readiness endpoint returns non-200;
- provider configuration is wrong;
- required Kubernetes Secret does not exist;
- app container cannot start with current config.

### Fix

- inspect app logs;
- verify ExternalSecret created `ai-provider`;
- roll back to last known-good image if readiness broke after deployment.

## ExternalSecret not syncing

### Symptom

Kubernetes Secret is missing or ExternalSecret is not Ready.

### Check

```powershell
kubectl get externalsecret -n ai-platform
kubectl describe externalsecret -n ai-platform
kubectl logs -n external-secrets deploy/external-secrets
```

### Likely causes

- AWS secret value has not been inserted;
- secret property name is wrong;
- External Secrets IRSA role annotation is wrong;
- IAM policy does not include secret ARN or KMS key.

### Fix

- confirm AWS secret exists;
- confirm the secret string contains `api_key`;
- confirm Terraform output `external_secrets_role_arn`;
- re-sync the External Secrets Argo CD app.

## ALB has no address

### Symptom

```powershell
kubectl get ingress -n ingress-nginx alb-to-nginx
```

shows no address.

### Check

```powershell
kubectl describe ingress -n ingress-nginx alb-to-nginx
kubectl logs -n kube-system deploy/aws-load-balancer-controller
```

### Likely causes

- AWS Load Balancer Controller is not running;
- controller IRSA role is wrong;
- public subnets are not tagged for ELB;
- ALB annotations are invalid.

### Fix

- verify controller pod logs;
- verify Terraform output `aws_load_balancer_controller_role_arn`;
- confirm public subnets have `kubernetes.io/role/elb = 1`.

## ALB returns 404

### Symptom

ALB DNS responds, but request returns 404.

### Check

```powershell
kubectl get ingress -n ai-platform
kubectl describe ingress -n ai-platform
```

### Likely causes

- host header does not match app Ingress host;
- NGINX has no matching route;
- app Ingress class is wrong;
- Service has no endpoints.

### Fix

Test with host header:

```powershell
curl -H "Host: ai-platform.local" http://<alb-dns>/health/live
```

Then verify app Service endpoints:

```powershell
kubectl get endpoints -n ai-platform
```

## HPA shows unknown metrics

### Symptom

HPA exists but shows `<unknown>` for CPU.

### Check

```powershell
kubectl describe hpa -n ai-platform
kubectl top pods -n ai-platform
kubectl get pods -n kube-system | Select-String metrics
```

### Likely causes

- Metrics Server is unhealthy;
- CPU requests are missing;
- pods are not Ready long enough for metrics.

### Fix

- repair Metrics Server;
- confirm Deployment has CPU requests;
- wait for metrics collection interval.

## Prometheus not scraping app

### Symptom

Grafana has no app metrics, or Prometheus target is down.

### Check

```powershell
kubectl get servicemonitor -n ai-platform
kubectl describe servicemonitor -n ai-platform
kubectl port-forward -n ai-platform svc/ai-inference-ai-inference 8080:80
curl http://localhost:8080/metrics
```

### Likely causes

- ServiceMonitor label does not match Prometheus selector;
- Service port name is wrong;
- `/metrics` endpoint is failing;
- kube-prometheus-stack CRDs are missing.

### Fix

- confirm label `monitoring.ai-platform/enabled: "true"`;
- confirm Service port name is `http`;
- verify `/metrics` locally with port-forward.

## Alertmanager not sending notifications

### Symptom

Alerts fire, but no one receives notifications.

### Check

```powershell
kubectl get secret -n monitoring
kubectl logs -n monitoring alertmanager-kube-prometheus-stack-alertmanager-0
```

### Likely causes

- dev receivers are intentionally empty;
- production receiver secrets are not configured;
- Alertmanager config is invalid.

### Fix

- add real receivers through External Secrets;
- keep webhook URLs and tokens out of Git;
- validate Alertmanager config before production use.

## No logs in CloudWatch

### Symptom

CloudWatch log group exists, but no application log streams appear.

### Check

```powershell
kubectl get pods -n amazon-cloudwatch
kubectl logs -n amazon-cloudwatch -l app.kubernetes.io/name=aws-for-fluent-bit
aws logs describe-log-groups --log-group-name-prefix /aws/eks/ai-platform-kubernetes-aws-dev/application
```

### Likely causes

- AWS for Fluent Bit IRSA role is wrong;
- log group name mismatch;
- CloudWatch Logs IAM permissions are missing;
- collector cannot reach CloudWatch Logs.

### Fix

- confirm Terraform output `aws_for_fluent_bit_role_arn`;
- confirm `autoCreateGroup: false` and pre-created log group match;
- check Fluent Bit pod logs for AWS API errors.

## Useful escalation rule

If a fix requires changing desired state, prefer this order:

1. update Git or Terraform;
2. review the diff/plan;
3. let Argo CD or Terraform reconcile;
4. document any emergency manual change afterward.
