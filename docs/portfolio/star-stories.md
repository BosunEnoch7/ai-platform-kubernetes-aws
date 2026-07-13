# STAR stories

Use these stories to answer behavioral and technical interview questions.

## Story 1: Building a production-inspired AI platform

### Situation

I wanted to build a flagship portfolio project that went beyond deploying a
simple AI API. The goal was to show how AI workloads are deployed and operated
on Kubernetes in a production-inspired AWS environment.

### Task

I needed to design the platform architecture, define tool ownership, build the
inference service, provision AWS infrastructure, package the app, set up GitOps,
secure secrets, and add observability.

### Action

I split the system into layers. Terraform owns AWS infrastructure and IAM. Helm
packages the FastAPI inference workload. Argo CD owns Kubernetes reconciliation.
GitHub Actions validates code and builds immutable images. I used IRSA for AWS
access, External Secrets Operator for Secrets Manager integration, and
Prometheus/Grafana/Alertmanager plus CloudWatch for observability.

### Result

The result is a production-inspired AI platform with documented architecture,
security boundaries, deployment process, rollback guide, troubleshooting guide,
and cost controls. The project demonstrates platform engineering, MLOps, DevOps,
Kubernetes, AWS, and SRE thinking.

## Story 2: Avoiding secret leakage

### Situation

The AI workload needed provider credentials, but storing secret values in Git or
Terraform state would be unsafe.

### Task

I needed a way for the app to consume secrets without committing values or
embedding static AWS credentials in the container.

### Action

I used AWS Secrets Manager as the source of truth. Terraform creates the secret
container and KMS key, but not the secret value. External Secrets Operator uses
IRSA to read only the approved secret and project it into a Kubernetes Secret.
The app consumes the Kubernetes Secret using `envFrom.secretRef`.

### Result

Secret values are excluded from Git and Terraform state. AWS access is scoped by
IRSA, and the application does not need static AWS credentials.

## Story 3: Separating CI/CD from GitOps

### Situation

Many pipelines deploy directly to Kubernetes after building an image, but this
can conflict with GitOps tools.

### Task

I needed to design a delivery flow where CI/CD builds artifacts but Argo CD
remains the source of truth for cluster state.

### Action

I created GitHub Actions workflows for tests, linting, Terraform validation,
Helm rendering, YAML parsing, and ECR image publishing. The container workflow
pushes immutable Git SHA image tags. Argo CD Applications deploy the Helm chart
from Git.

### Result

The deployment model is auditable and rollback-friendly. CI produces verified
artifacts; Argo CD reconciles Kubernetes state.

## Story 4: Making observability actionable

### Situation

The platform needed more than just logs. It needed metrics, dashboards, alerts,
and centralized log shipping.

### Task

I needed to expose useful app metrics and wire them into Kubernetes-native
monitoring tools.

### Action

The FastAPI app exposes bounded Prometheus metrics for request count, latency,
and provider failures. The Helm chart creates a ServiceMonitor and
PrometheusRule. Grafana gets a starter dashboard, Alertmanager has a routing
model, and AWS for Fluent Bit ships JSON logs to CloudWatch.

### Result

The platform can detect high error rate, high p95 latency, and provider
failures. Logs are centralized for troubleshooting, and the observability
strategy is documented.

## Story 5: Making cost trade-offs explicit

### Situation

EKS-based platforms can become expensive, especially for a portfolio demo.

### Task

I needed to keep the architecture production-inspired while controlling cost.

### Action

I used a single NAT Gateway by default for development, small managed node
groups, bounded HPA scaling, ECR lifecycle cleanup, 30-day CloudWatch log
retention, and a teardown guide.

### Result

The project demonstrates cost-aware architecture. It also documents when to move
from demo defaults to production settings such as per-AZ NAT Gateways.
