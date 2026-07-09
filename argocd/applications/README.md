# Argo CD Applications

This directory contains bootstrap `Application` manifests.

## Current applications

| Application | Purpose |
|---|---|
| `platform-addons` | App-of-apps entrypoint for shared platform controllers. |
| `ai-inference` | Deploys the FastAPI AI inference Helm chart. |

## Required replacements before applying

Replace these placeholders before applying to a real cluster:

- `REPLACE_WITH_GITHUB_USERNAME`
- `000000000000.dkr.ecr.eu-west-1.amazonaws.com/...`
- `replace-with-commit-sha`
- `arn:aws:iam::000000000000:role/...`

The real values should come from:

- Terraform outputs for ECR repository URL and IRSA role ARN;
- CI/CD output for the immutable image tag.

## Why image tag is not `latest`

GitOps works best when the desired state is exact. A mutable `latest` tag can
change without a Git commit, which breaks auditability and rollback confidence.
This project uses immutable commit SHA tags instead.
