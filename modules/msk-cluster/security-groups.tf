data "aws_subnet" "this" {
  region = var.region

  id = var.broker_subnets[0]
}

locals {
  vpc_id = data.aws_subnet.this.vpc_id

  kraft_enabled = endswith(var.kafka_version, ".kraft")

  dualstack_enabled = var.ip_address_type == "DUALSTACK"

  security_groups = concat(module.security_group[*].id, var.security_groups)

  plaintext_listener_enabled = contains(["PLAINTEXT", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode)
  tls_listener_enabled = (contains(["TLS", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode)
    && (var.authentication.unauthenticated_access.enabled || var.authentication.tls.enabled)
  )
  public_tls_listener_enabled = var.broker_public_access_enabled && var.authentication.tls.enabled

  broker_ports = concat(
    local.plaintext_listener_enabled ? [
      {
        id          = "broker-plaintext"
        description = "Allow to communicate with Kafka brokers in plaintext."
        port        = 9092
      },
    ] : [],
    local.tls_listener_enabled ? [
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
    local.public_tls_listener_enabled ? [
      {
        id          = "broker-public-tls"
        description = "Allow to communicate with Kafka brokers in tls (public)."
        port        = 9194
      },
    ] : [],
    var.broker_public_access_enabled && var.authentication.sasl_scram.enabled ? [
      {
        id          = "broker-public-sasl-scram"
        description = "Allow to communicate with Kafka brokers in SASL SCRAM (public)."
        port        = 9196
      },
    ] : [],
    var.broker_public_access_enabled && var.authentication.sasl_iam.enabled ? [
      {
        id          = "broker-public-sasl-iam"
        description = "Allow to communicate with Kafka brokers in SASL IAM (public)."
        port        = 9198
      },
    ] : [],
    local.dualstack_enabled && local.plaintext_listener_enabled ? [
      {
        id          = "broker-ipv6-plaintext"
        description = "Allow to communicate with Kafka brokers in plaintext over IPv6."
        port        = 20092
      },
    ] : [],
    local.dualstack_enabled && local.tls_listener_enabled ? [
      {
        id          = "broker-ipv6-tls"
        description = "Allow to communicate with Kafka brokers in tls over IPv6."
        port        = 20094
      },
    ] : [],
    local.dualstack_enabled && var.authentication.sasl_scram.enabled ? [
      {
        id          = "broker-ipv6-sasl-scram"
        description = "Allow to communicate with Kafka brokers in SASL SCRAM over IPv6."
        port        = 20096
      },
    ] : [],
    local.dualstack_enabled && var.authentication.sasl_iam.enabled ? [
      {
        id          = "broker-ipv6-sasl-iam"
        description = "Allow to communicate with Kafka brokers in SASL IAM over IPv6."
        port        = 20098
      },
    ] : [],
  )

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
