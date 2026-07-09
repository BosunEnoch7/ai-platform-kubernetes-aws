locals {
  aws_load_balancer_controller_role_name = "${var.name}-aws-load-balancer-controller"
  external_secrets_role_name             = "${var.name}-external-secrets"
  aws_for_fluent_bit_role_name           = "${var.name}-aws-for-fluent-bit"
  application_log_group_name             = "/aws/eks/${var.name}/application"

  aws_load_balancer_controller_subject = "system:serviceaccount:${var.aws_load_balancer_controller_namespace}:${var.aws_load_balancer_controller_service_account}"
  external_secrets_subject             = "system:serviceaccount:${var.external_secrets_namespace}:${var.external_secrets_service_account}"
  aws_for_fluent_bit_subject           = "system:serviceaccount:${var.aws_for_fluent_bit_namespace}:${var.aws_for_fluent_bit_service_account}"

  tags = merge(var.tags, { Component = "platform-addons" })
}
