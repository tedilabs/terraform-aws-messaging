data "aws_subnet" "this" {
  region = var.region

  id = var.broker_subnets[0]
}

locals {
  vpc_id = data.aws_subnet.this.vpc_id

  # MSK names every KRaft version with the `.kraft` suffix (e.g. `3.9.x.kraft`, `4.1.x.kraft`).
  kraft_enabled = endswith(var.kafka_version, ".kraft")

  security_groups = concat(
    (var.default_security_group.enabled
      ? module.security_group[*].id
      : []
    ),
    var.security_groups,
  )

  # Every source in `default_security_group.ingress_rules` is allowed on each of these ports.
  broker_ports = concat(
    contains(["PLAINTEXT", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode) ? [
      {
        id   = "broker-plaintext"
        port = 9092
      },
    ] : [],
    contains(["TLS", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode) ? [
      {
        id   = "broker-tls"
        port = 9094
      },
    ] : [],
    var.authentication.sasl_scram.enabled ? [
      {
        id   = "broker-sasl-scram"
        port = 9096
      },
    ] : [],
    var.authentication.sasl_iam.enabled ? [
      {
        id   = "broker-sasl-iam"
        port = 9098
      },
    ] : [],
    [
      {
        id   = "broker-public-tls"
        port = 9194
      },
      {
        id   = "broker-public-sasl-scram"
        port = 9196
      },
      {
        id   = "broker-public-sasl-iam"
        port = 9198
      },
    ],
    # KRaft clusters have no ZooKeeper nodes.
    !local.kraft_enabled ? [
      {
        id   = "zookeeper"
        port = 2181
      },
    ] : [],
  )
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
    flatten([
      for port in local.broker_ports : [
        for rule in var.default_security_group.ingress_rules :
        merge(rule, {
          id        = "${port.id}/${rule.id}"
          protocol  = "tcp"
          from_port = port.port
          to_port   = port.port
        })
      ]
    ]),
    var.prometheus.jmx_exporter_enabled ? [
      {
        id          = "prometheus-jmx-exporter/cidrs"
        description = "Allow CIDRs to communicate with Prometheus JMX Exporter."
        protocol    = "tcp"
        from_port   = 11001
        to_port     = 11001

        ipv4_cidrs = var.prometheus.allowed_ingress_ipv4_cidrs
      },
    ] : [],
    var.prometheus.node_exporter_enabled ? [
      {
        id          = "prometheus-node-exporter/cidrs"
        description = "Allow CIDRs to communicate with Prometheus Node Exporter."
        protocol    = "tcp"
        from_port   = 11002
        to_port     = 11002

        ipv4_cidrs = var.prometheus.allowed_ingress_ipv4_cidrs
      },
    ] : [],
  )

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
