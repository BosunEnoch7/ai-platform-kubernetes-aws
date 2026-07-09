# Remote-state bootstrap

This root module creates the infrastructure that protects Terraform state:

- one private S3 bucket with versioning;
- S3-native state locking;
- one customer-managed KMS key with annual rotation;
- public-access blocking and bucket-owner-enforced object ownership;
- a bucket policy that denies non-TLS access; and
- deletion protection for both the bucket and KMS key.

## Why bootstrap is separate

Terraform cannot use an S3 backend before that bucket exists. The bootstrap is
therefore initialized locally once, applied, and then its state is migrated
into the newly created backend.

This is a controlled chicken-and-egg procedure, not an excuse to keep
long-lived local state.

## Prerequisites

1. Select the intended AWS account and authenticate with short-lived
   credentials.
2. Confirm identity with `aws sts get-caller-identity`.
3. Choose a globally unique bucket name. A useful pattern is:
   `<project>-tfstate-<account-id>-<region>`.
4. Review the plan before applying it. State storage is a security boundary.

## First-time bootstrap

From `terraform/bootstrap`:

```powershell
terraform init -backend=false

terraform plan `
  -var="state_bucket_name=REPLACE_WITH_GLOBALLY_UNIQUE_NAME" `
  -out=bootstrap.tfplan

terraform apply bootstrap.tfplan
```

After the bucket exists, copy `backend.hcl.example` to a local
`backend.hcl`, replace its placeholders with output values, and migrate:

```powershell
terraform init -migrate-state -backend-config=backend.hcl
```

`backend.hcl` is ignored because backend settings are deployment-specific.
It must not contain credentials.

## Routine validation

```powershell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

## Recovery principle

Bucket versioning supports recovery from accidental state overwrites or
deletion. State locking prevents concurrent writers; it is not a backup.
Never use `-lock=false` to work around contention, and use force-unlock only
after proving no legitimate operation still owns the lock.

## Teardown warning

The state bucket and KMS key use `prevent_destroy`. Removing them is a separate
break-glass procedure because destroying the backend can make all other
infrastructure state unavailable.
