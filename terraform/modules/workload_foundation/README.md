# Workload foundation module

This module creates the private ECR repository, encrypted Secrets Manager
container, least-privilege IRSA role needed by the inference workload, and
GitHub Actions OIDC role used for image publishing.

It deliberately does not create a secret version. Supplying a value through
Terraform would persist it in state. Populate the secret later through an
approved operator or CI/CD path.

ECR tags are immutable, so CI should publish unique commit-SHA tags rather than
overwrite a tag such as `latest`.

The GitHub Actions publisher role is scoped to one repository and branch. Its
ARN should be configured as the GitHub environment secret
`AWS_ROLE_TO_ASSUME`; the ECR repository name should be configured as the
environment variable `ECR_REPOSITORY`.
