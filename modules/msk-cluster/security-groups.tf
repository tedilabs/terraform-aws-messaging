data "aws_subnet" "this" {
  region = var.region

  id = var.broker_subnets[0]
}

locals {
  vpc_id = data.aws_subnet.this.vpc_id

  # MSK names every KRaft version with the `.kraft` suffix (e.g. `3.9.x.kraft`, `4.1.x.kraft`).
  kraft_enabled = endswith(var.kafka_version, ".kraft")

  security_groups = concat(module.security_group[*].id, var.security_groups)

  # Sources in `default_security_group.broker_ingress_*` are allowed on each of these ports.
  broker_ports = concat(
    contains(["PLAINTEXT", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode) ? [
      {
        id          = "broker-plaintext"
        description = "Allow to communicate with Kafka brokers in plaintext."
        port        = 9092
      },
    ] : [],
    contains(["TLS", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode) ? [
      {
        id          = "broker-tls"
        description = "Allow to communicate with Kafka brokers in tls."
        port        = 9094
      },
    ] : [],
    var.authentication.sasl_scram.enabled ? [
      {
        id          = "broker-sasl-scram"
        description = "Allow to communicate with Kafka brokers in SASL SCRAM."
        port        = 9096
      },
    ] : [],
    var.authentication.sasl_iam.enabled ? [
      {
        id          = "broker-sasl-iam"
        description = "Allow to communicate with Kafka brokers in SASL IAM."
        port        = 9098
      },
    ] : [],
    [
      {
        id          = "broker-public-tls"
        description = "Allow to communicate with Kafka brokers in tls (public)."
        port        = 9194
      },
      {
        id          = "broker-public-sasl-scram"
        description = "Allow to communicate with Kafka brokers in SASL SCRAM (public)."
        port        = 9196
      },
      {
        id          = "broker-public-sasl-iam"
        description = "Allow to communicate with Kafka brokers in SASL IAM (public)."
        port        = 9198
      },
    ],
  )

  # Sources in `default_security_group.zookeeper_ingress_*` are allowed on each of these ports.
  zookeeper_ports = concat(
    # KRaft clusters have no ZooKeeper nodes.
    !local.kraft_enabled ? [
      {
        id          = "zookeeper"
        description = "Allow to communicate with Kafka zookeepers."
        port        = 2181
      },
    ] : [],
    # ZooKeeper TLS endpoints are available only when TLS is enabled for client-broker encryption.
    !local.kraft_enabled && contains(["TLS", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode) ? [
      {
        id          = "zookeeper-tls"
        description = "Allow to communicate with Kafka zookeepers in tls."
        port        = 2182
      },
    ] : [],
  )

  # Sources in `default_security_group.prometheus_ingress_*` are allowed on each of these ports.
  prometheus_ports = concat(
    var.prometheus.jmx_exporter_enabled ? [
      {
        id          = "prometheus-jmx-exporter"
        description = "Allow to communicate with Prometheus JMX Exporter."
        port        = 11001
      },
    ] : [],
    var.prometheus.node_exporter_enabled ? [
      {
        id          = "prometheus-node-exporter"
        description = "Allow to communicate with Prometheus Node Exporter."
        port        = 11002
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
    var.default_security_group.ingress_rules,
    [
      for port in local.broker_ports : {
        id          = port.id
        description = port.description
        protocol    = "tcp"
        from_port   = port.port
        to_port     = port.port

        ipv4_cidrs      = var.default_security_group.broker_ingress_ipv4_cidrs
        ipv6_cidrs      = var.default_security_group.broker_ingress_ipv6_cidrs
        prefix_lists    = var.default_security_group.broker_ingress_prefix_lists
        security_groups = var.default_security_group.broker_ingress_security_groups
      }
      if anytrue([
        length(var.default_security_group.broker_ingress_ipv4_cidrs) > 0,
        length(var.default_security_group.broker_ingress_ipv6_cidrs) > 0,
        length(var.default_security_group.broker_ingress_prefix_lists) > 0,
        length(var.default_security_group.broker_ingress_security_groups) > 0,
      ])
    ],
    [
      for port in local.zookeeper_ports : {
        id          = port.id
        description = port.description
        protocol    = "tcp"
        from_port   = port.port
        to_port     = port.port

        ipv4_cidrs      = var.default_security_group.zookeeper_ingress_ipv4_cidrs
        ipv6_cidrs      = var.default_security_group.zookeeper_ingress_ipv6_cidrs
        prefix_lists    = var.default_security_group.zookeeper_ingress_prefix_lists
        security_groups = var.default_security_group.zookeeper_ingress_security_groups
      }
      if anytrue([
        length(var.default_security_group.zookeeper_ingress_ipv4_cidrs) > 0,
        length(var.default_security_group.zookeeper_ingress_ipv6_cidrs) > 0,
        length(var.default_security_group.zookeeper_ingress_prefix_lists) > 0,
        length(var.default_security_group.zookeeper_ingress_security_groups) > 0,
      ])
    ],
    [
      for port in local.prometheus_ports : {
        id          = port.id
        description = port.description
        protocol    = "tcp"
        from_port   = port.port
        to_port     = port.port

        ipv4_cidrs      = var.default_security_group.prometheus_ingress_ipv4_cidrs
        ipv6_cidrs      = var.default_security_group.prometheus_ingress_ipv6_cidrs
        prefix_lists    = var.default_security_group.prometheus_ingress_prefix_lists
        security_groups = var.default_security_group.prometheus_ingress_security_groups
      }
      if anytrue([
        length(var.default_security_group.prometheus_ingress_ipv4_cidrs) > 0,
        length(var.default_security_group.prometheus_ingress_ipv6_cidrs) > 0,
        length(var.default_security_group.prometheus_ingress_prefix_lists) > 0,
        length(var.default_security_group.prometheus_ingress_security_groups) > 0,
      ])
    ],
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
