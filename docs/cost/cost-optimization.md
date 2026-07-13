# Cost optimization guide

This project is production-inspired, but it should still be safe to run as a
portfolio demo. Cost control is part of the architecture.

Use the AWS Pricing Calculator for exact estimates:

```text
https://calculator.aws/
```

Prices vary by region, usage, discounts, support tier, data transfer, and date.

## Main cost drivers

| Area | Why it costs money | Project control |
|---|---|---|
| EKS control plane | EKS has a per-cluster hourly charge. | Use one dev cluster; destroy when not needed. |
| Worker nodes | EC2 instances and EBS volumes run the workloads. | Small node group, low replica counts, HPA bounds. |
| NAT Gateway | Charged while provisioned and for data processed. | Default dev mode uses one NAT gateway, not one per AZ. |
| Load balancer | ALB/NLB resources bill while active. | One shared ALB bridge for the portfolio baseline. |
| CloudWatch Logs | Log ingestion and storage can grow quickly. | 30-day application log retention. |
| VPC Flow Logs | Useful, but creates log ingestion/storage cost. | 30-day retention and explicit enablement. |
| Prometheus stack | Uses node CPU/memory/storage. | Modest resource requests and 7-day Prometheus retention. |
| ECR | Image storage and scanning. | Immutable tags plus lifecycle policy for untagged images. |
| Secrets Manager | Per-secret and API access costs. | One app secret container for the baseline. |

## Cost-aware defaults already in the project

### Single NAT gateway for development

The network module supports:

```hcl
nat_gateway_mode = "single"
```

This reduces development cost compared with one NAT gateway per Availability
Zone.

Trade-off: single NAT is less resilient. For production, use:

```hcl
nat_gateway_mode = "per_az"
```

### Small managed node group

The dev environment defaults to:

```hcl
node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
```

This is enough for a portfolio baseline but not a high-throughput production
cluster.

### Bounded HPA

The app HPA is bounded:

```yaml
minReplicas: 2
maxReplicas: 6
```

Autoscaling without an upper bound can create surprise capacity cost.

### Log retention

Application logs are retained for 30 days:

```hcl
application_log_retention_days = 30
```

Prometheus retention is 7 days in the monitoring stack baseline.

### ECR lifecycle

The ECR repository removes untagged images after the configured retention
period. This keeps failed/intermediate image pushes from accumulating forever.

## Demo mode vs production mode

| Decision | Demo mode | Production mode |
|---|---|---|
| NAT gateways | single | per-AZ |
| Node capacity | small on-demand nodes | right-sized nodes, Spot where safe, Savings Plans after usage stabilizes |
| Log retention | 30 days | retention based on compliance and incident needs |
| Prometheus retention | 7 days | longer retention or remote write |
| ALB/NGINX | both enabled for portfolio demonstration | simplify if latency/cost matters more than feature demonstration |
| Cluster lifetime | destroy after demo | long-lived with budgets, alerts, and upgrade process |

## Cost controls to enable in AWS

Before applying the infrastructure:

- create an AWS Budget for the account;
- enable budget alerts to email;
- review Cost Explorer daily while testing;
- tag all resources with `Project`, `Environment`, and `Owner`;
- destroy the dev environment when not actively using it.

The Terraform modules already apply common project tags.

## Cost review checklist

Run this checklist before leaving the environment running overnight:

- Do I still need the EKS cluster running?
- Is the ALB still provisioned?
- Are NAT gateways still provisioned?
- Are log groups retaining more data than needed?
- Are there old ECR images?
- Did HPA scale replicas higher than expected?
- Are there unattached EBS volumes or unused Elastic IPs?

## Safe teardown order

For a demo environment, tear down from the top down:

1. Delete Argo CD Applications for app workloads.
2. Delete platform add-on Applications.
3. Confirm LoadBalancer/ALB resources are removed.
4. Run Terraform destroy for the dev environment.
5. Destroy bootstrap only if you no longer need remote state storage.

Example:

```powershell
kubectl delete -f argocd/applications/ai-inference.yaml
kubectl delete -f argocd/applications/platform-addons.yaml
terraform -chdir=terraform/environments/dev destroy
```

Do not destroy remote state storage until after dependent environments are gone.

## What recruiters should notice

This project does not pretend production architecture is free. It shows:

- cost-aware NAT design;
- explicit log retention;
- bounded autoscaling;
- image lifecycle cleanup;
- clear demo-vs-production trade-offs;
- teardown discipline.

That is the mindset expected from platform engineers and SREs.
