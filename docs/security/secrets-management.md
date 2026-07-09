# Secrets management

This project separates secret containers, secret values, cloud identity, and
Kubernetes projection.

## Flow

```text
Terraform
→ creates encrypted AWS Secrets Manager secret container
→ creates IRSA role for External Secrets Operator

External Secrets Operator
→ assumes IRSA role
→ reads approved Secrets Manager secret
→ creates namespaced Kubernetes Secret

FastAPI Deployment
→ consumes Kubernetes Secret with envFrom.secretRef
```

## Why Terraform does not manage the secret value

Terraform state is not a safe place for live credentials. Even encrypted remote
state can be read by people and systems with state access.

So Terraform creates only:

- the secret container;
- the KMS key;
- the IAM permissions.

The actual secret value should be inserted using an operational path such as:

```powershell
aws secretsmanager put-secret-value `
  --secret-id ai-platform-kubernetes-aws-dev/ai-provider `
  --secret-string '{ "api_key": "replace-with-real-value" }'
```

Do not commit that value to Git.

## Why External Secrets Operator

External Secrets Operator keeps Kubernetes Secrets synchronized from the cloud
secret manager. This gives Kubernetes-native consumption while keeping the
source of truth in AWS Secrets Manager.

## Permission model

The External Secrets Operator IRSA role can read only the approved app secret
ARN and decrypt only through AWS Secrets Manager.

The app consumes a Kubernetes Secret. It does not need static AWS credentials.

## Rotation behavior

ExternalSecret uses a refresh interval. When the value changes in AWS Secrets
Manager, the Kubernetes Secret is updated after the next refresh.

Some applications need a restart to pick up environment variable changes. A
future production improvement can add a reloader controller or mount secrets as
files if hot reload is required.
