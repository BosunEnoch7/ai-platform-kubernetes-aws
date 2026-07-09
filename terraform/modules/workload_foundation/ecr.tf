resource "aws_kms_key" "ecr" {
  description             = "Encrypts ${local.repository_name} container images"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.tags, { Name = "${local.repository_name}-ecr" })
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/${local.repository_name}-ecr"
  target_key_id = aws_kms_key.ecr.key_id
}

resource "aws_ecr_repository" "application" {
  name                 = local.repository_name
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.tags, { Name = local.repository_name })
}

resource "aws_ecr_lifecycle_policy" "application" {
  repository = aws_ecr_repository.application.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire old untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_retention_days
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Retain the most recent images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.retained_image_count
        }
        action = { type = "expire" }
      }
    ]
  })
}
