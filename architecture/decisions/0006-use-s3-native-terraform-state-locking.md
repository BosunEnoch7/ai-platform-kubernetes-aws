# ADR 0006: Use S3-native Terraform state locking

- **Status:** Accepted
- **Date:** 2026-07-04

## Context

Terraform state can contain infrastructure identifiers and sensitive values.
Local state is unsuitable for team workflows, and concurrent writers can
corrupt state or create conflicting infrastructure changes.

Older AWS designs commonly pair an S3 state bucket with a DynamoDB lock table.
Terraform now supports S3-native lockfiles and deprecates DynamoDB-based
locking.

## Decision

Store state in a private, versioned, KMS-encrypted S3 bucket and enable
`use_lockfile = true` in the S3 backend.

Bootstrap the bucket and key with local state once, then migrate the bootstrap
state into that backend. Keep credentials out of backend configuration.

## Consequences

### Benefits

- State is encrypted, recoverable through versioning, and protected from
  concurrent writers.
- Avoids a DynamoDB table whose only purpose is a deprecated locking pattern.
- Uses fewer AWS resources and has a smaller operational surface.

### Costs and risks

- Initial creation requires a documented local-to-remote migration.
- Anyone administering state needs carefully scoped S3 and KMS permissions.
- Locking prevents concurrent mutation but does not replace versioning,
  backups, or plan review.

## Guardrails

- Deny public access and non-TLS requests.
- Enable KMS rotation and S3 bucket keys.
- Use `prevent_destroy` on the bucket and key.
- Never bypass contention with `-lock=false`.
- Treat force-unlock as a break-glass operation.
