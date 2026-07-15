# Teardown guide

This guide helps remove demo resources safely.

## Why teardown matters

EKS, NAT Gateways, load balancers, worker nodes, logs, and public IP resources
can continue billing after a demo is finished.

## Emergency cost stop

If you only have time to stop the biggest charges, check and remove these first:

```powershell
aws eks list-clusters --region eu-west-1
aws ec2 describe-nat-gateways --region eu-west-1 --filter Name=state,Values=available,pending,deleting
aws elbv2 describe-load-balancers --region eu-west-1
aws ec2 describe-addresses --region eu-west-1
```

Priority order:

1. EKS clusters.
2. NAT Gateways.
3. Public load balancers.
4. Unattached Elastic IPs.
5. Worker nodes, EBS volumes, and large log groups.

Terraform destroy is still the preferred path because it preserves dependency
order. Manual deletion is for emergencies, abandoned state, or interrupted
demos.

## 1. Remove app GitOps resources

```powershell
kubectl delete -f argocd/applications/ai-inference.yaml
```

Wait for app resources to disappear:

```powershell
kubectl get all -n ai-platform
kubectl get ingress -n ai-platform
```

## 2. Remove platform add-ons

```powershell
kubectl delete -f argocd/applications/platform-addons.yaml
```

Confirm AWS-facing resources are gone:

```powershell
kubectl get ingress -A
```

Also check the AWS console for remaining load balancers.

## 3. Destroy Terraform dev environment

```powershell
terraform -chdir=terraform/environments/dev plan -destroy
terraform -chdir=terraform/environments/dev destroy
```

Review the destroy plan before approving.

## 4. Confirm high-cost resources are gone

Check:

- EKS cluster;
- EC2 worker nodes;
- NAT gateways;
- load balancers;
- unattached EBS volumes;
- Elastic IPs;
- CloudWatch log groups;
- ECR repositories.

Some resources, such as log groups or ECR repositories, may be intentionally
retained depending on Terraform lifecycle decisions. Decide whether you still
need them.

## 5. Destroy bootstrap only when safe

Only destroy bootstrap resources if you no longer need Terraform remote state:

```powershell
terraform -chdir=terraform/bootstrap plan -destroy
terraform -chdir=terraform/bootstrap destroy
```

Do not delete the state bucket while active environments still depend on it.
