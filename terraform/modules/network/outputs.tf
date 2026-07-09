output "vpc_id" {
  description = "VPC identifier."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC IPv4 CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the network."
  value       = local.availability_zones
}

output "public_subnet_ids" {
  description = "Public subnet IDs ordered by Availability Zone."
  value       = [for zone in local.availability_zones : aws_subnet.public[zone].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs ordered by Availability Zone."
  value       = [for zone in local.availability_zones : aws_subnet.private[zone].id]
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs keyed by Availability Zone."
  value       = { for zone, gateway in aws_nat_gateway.this : zone => gateway.id }
}

output "flow_log_group_name" {
  description = "CloudWatch log group for VPC Flow Logs, or null when disabled."
  value = (
    var.enable_flow_logs
    ? aws_cloudwatch_log_group.flow_logs[0].name
    : null
  )
}
