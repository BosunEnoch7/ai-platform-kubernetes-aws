# ADR 0014: Use GitHub Actions for CI and image delivery

## Status

Accepted

## Context

The AI inference platform needs automated validation and container image
delivery. The project also uses Argo CD for deployment reconciliation, so CI/CD
must not bypass GitOps ownership.

## Decision

Use GitHub Actions for:

- Python linting and tests;
- Terraform format and validation;
- Helm linting and rendering;
- YAML parsing;
- Docker image build and push to Amazon ECR.

Use GitHub Actions OIDC to assume an AWS role instead of storing long-lived AWS
access keys.

## Rationale

GitHub Actions is a familiar CI/CD system for recruiters and platform teams.
OIDC-based AWS access demonstrates modern cloud security practice. Immutable
image tags make deployments auditable.

Argo CD remains responsible for applying Kubernetes desired state.

## Trade-offs

The first version requires a manual GitOps image-tag update after the image is
pushed. Fully automated image updates are possible, but they add another moving
part and can hide what changed from learners.

## Consequences

- CI validates app, infrastructure, Helm, and manifests before merge.
- ECR receives immutable commit-SHA image tags.
- No static AWS keys are required in GitHub.
- Kubernetes deployment remains GitOps-driven.
