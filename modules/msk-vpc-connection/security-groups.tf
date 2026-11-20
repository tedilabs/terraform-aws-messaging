locals {
  # The network load balancer of the multi-VPC private connectivity listens on these ports.
  broker_port_range = {
    from = 14001
    to   = 14100
  }
}


###################################################
# Security Group
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 1.4.0"

  count = var.default_security_group.enabled ? 1 : 0

  region = var.region

  name        = coalesce(var.default_security_group.name, var.name)
  description = var.default_security_group.description
  vpc_id      = local.vpc_id

  ingress_rules = concat(
    var.default_security_group.ingress_rules,
    anytrue([
      length(var.default_security_group.broker_ingress_ipv4_cidrs) > 0,
      length(var.default_security_group.broker_ingress_ipv6_cidrs) > 0,
      length(var.default_security_group.broker_ingress_prefix_lists) > 0,
      length(var.default_security_group.broker_ingress_security_groups) > 0,
      ]) ? [
      {
        id          = "broker"
        description = "Allow to communicate with Kafka brokers through the VPC connection."
        protocol    = "tcp"
        from_port   = local.broker_port_range.from
        to_port     = local.broker_port_range.to

        ipv4_cidrs      = var.default_security_group.broker_ingress_ipv4_cidrs
        ipv6_cidrs      = var.default_security_group.broker_ingress_ipv6_cidrs
        prefix_lists    = var.default_security_group.broker_ingress_prefix_lists
        security_groups = var.default_security_group.broker_ingress_security_groups
      },
    ] : [],
  )
  egress_rules = var.default_security_group.egress_rules

  revoke_rules_on_delete = true

  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )

  telemetry = {
    enabled = false
  }
}
