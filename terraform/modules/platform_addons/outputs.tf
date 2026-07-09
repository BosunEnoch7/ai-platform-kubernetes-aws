output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN for AWS Load Balancer Controller."
  value       = aws_iam_role.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_namespace" {
  description = "Namespace expected by the AWS Load Balancer Controller Helm release."
  value       = var.aws_load_balancer_controller_namespace
}

output "aws_load_balancer_controller_service_account" {
  description = "Service account expected by the AWS Load Balancer Controller Helm release."
  value       = var.aws_load_balancer_controller_service_account
}

output "aws_load_balancer_controller_helm_values" {
  description = "Non-secret Helm values needed when installing AWS Load Balancer Controller."
  value = {
    clusterName = var.cluster_name
    vpcId       = var.vpc_id
    region      = data.aws_region.current.region
    serviceAccount = {
      create = true
      name   = var.aws_load_balancer_controller_service_account
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
      }
    }
  }
}

output "external_secrets_role_arn" {
  description = "IRSA role ARN for External Secrets Operator."
  value       = aws_iam_role.external_secrets.arn
}

output "external_secrets_namespace" {
  description = "Namespace expected by the External Secrets Operator Helm release."
  value       = var.external_secrets_namespace
}

output "external_secrets_service_account" {
  description = "Service account expected by the External Secrets Operator Helm release."
  value       = var.external_secrets_service_account
}

output "external_secrets_helm_values" {
  description = "Non-secret Helm values needed when installing External Secrets Operator."
  value = {
    serviceAccount = {
      create = true
      name   = var.external_secrets_service_account
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
      }
    }
  }
}

output "application_log_group_name" {
  description = "CloudWatch Logs log group for application container logs."
  value       = aws_cloudwatch_log_group.application.name
}

output "aws_for_fluent_bit_role_arn" {
  description = "IRSA role ARN for AWS for Fluent Bit."
  value       = aws_iam_role.aws_for_fluent_bit.arn
}

output "aws_for_fluent_bit_namespace" {
  description = "Namespace expected by the AWS for Fluent Bit Helm release."
  value       = var.aws_for_fluent_bit_namespace
}

output "aws_for_fluent_bit_service_account" {
  description = "Service account expected by the AWS for Fluent Bit Helm release."
  value       = var.aws_for_fluent_bit_service_account
}

output "aws_for_fluent_bit_helm_values" {
  description = "Non-secret Helm values needed when installing AWS for Fluent Bit."
  value = {
    cloudWatchLogs = {
      region             = data.aws_region.current.region
      logGroupName       = aws_cloudwatch_log_group.application.name
      autoCreateLogGroup = false
    }
    serviceAccount = {
      create = true
      name   = var.aws_for_fluent_bit_service_account
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.aws_for_fluent_bit.arn
      }
    }
  }
}
