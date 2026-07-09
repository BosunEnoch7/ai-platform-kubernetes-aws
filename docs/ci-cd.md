# CI/CD pipeline

This project uses GitHub Actions for validation and image delivery.

## Pipeline responsibilities

| Workflow | Responsibility |
|---|---|
| `.github/workflows/ci.yml` | Tests, linting, Terraform validation, Helm rendering, YAML parsing |
| `.github/workflows/container.yml` | Builds the Docker image and pushes an immutable tag to Amazon ECR |

## Delivery boundary

GitHub Actions does not apply Kubernetes manifests directly.

```text
GitHub Actions → build, test, push image
Argo CD        → reconcile Kubernetes desired state from Git
```

This matters because if CI deploys directly with `kubectl apply`, Argo CD no
longer has a single source of truth. Production teams usually avoid that split
brain.

## Required GitHub configuration

Create a GitHub environment named `dev` and configure:

### Environment secret

- `AWS_ROLE_TO_ASSUME`: IAM role ARN trusted by GitHub Actions OIDC.

### Environment variables

- `AWS_REGION`: for example `eu-west-1`.
- `ECR_REPOSITORY`: Terraform output `ecr_repository_name`.

## Why OIDC instead of AWS access keys

OIDC lets GitHub Actions request short-lived AWS credentials at runtime. No
long-lived AWS access keys need to be stored in GitHub secrets.

That reduces credential leakage risk and makes revocation easier.

## Image tagging strategy

Images are tagged with the full Git commit SHA:

```text
<account>.dkr.ecr.<region>.amazonaws.com/<repository>:<git-sha>
```

This is intentionally not `latest`.

Immutable tags make rollback and incident investigation much easier because the
running image maps back to one exact commit.

## GitOps handoff

After the image is pushed, update the Argo CD application desired state:

```yaml
image.tag: <git-sha>
```

In a later production-hardening phase, this can be automated with a pull request
or an image updater controller. For the baseline, making the handoff explicit is
easier to understand and safer for a portfolio demo.
