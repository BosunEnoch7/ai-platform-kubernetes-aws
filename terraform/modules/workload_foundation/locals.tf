locals {
  repository_name = "${var.name}-ai-inference"
  secret_name     = "${var.name}/ai-provider"
  role_name       = "${var.name}-ai-inference"

  tags = merge(var.tags, { Component = "workload-foundation" })
}
