# Workload foundation module

This module creates the private ECR repository, encrypted Secrets Manager
container, and least-privilege IRSA role needed by the inference workload.

It deliberately does not create a secret version. Supplying a value through
Terraform would persist it in state. Populate the secret later through an
approved operator or CI/CD path.

ECR tags are immutable, so CI should publish unique commit-SHA tags rather than
overwrite a tag such as `latest`.
