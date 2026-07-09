locals {
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    var.availability_zone_count
  )

  nat_gateway_zones = var.nat_gateway_mode == "single" ? toset([
    local.availability_zones[0]
  ]) : toset(local.availability_zones)

  interface_endpoint_services = toset([
    "ecr.api",
    "ecr.dkr",
    "logs",
    "sts",
  ])

  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "terraform"
      Component   = "network"
    },
    var.tags
  )
}
