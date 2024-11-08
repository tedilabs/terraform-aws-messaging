data "aws_subnet" "this" {
  id = var.broker_subnets[0]
}

locals {
  vpc_id = data.aws_subnet.this.vpc_id
}


###################################################
# Security Group
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 0.32.0"

  name        = "msk-${var.name}"
  description = "Security group for MSK Cluster."
  vpc_id      = local.vpc_id

  ingress_rules = concat(
    contains(["PLAINTEXT", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode) ? [
      {
        id          = "broker-plaintext/cidrs"
        description = "Allow CIDRs to communicate with Kafka brokers in plaintext."
        protocol    = "tcp"
        from_port   = 9092
        to_port     = 9092

        ipv4_cidrs = var.broker_allowed_ingress_cidrs
      },
    ] : [],
    contains(["TLS", "TLS_PLAINTEXT"], var.encryption_in_transit.client_mode) ? [
      {
        id          = "broker-tls/cidrs"
        description = "Allow CIDRs to communicate with Kafka brokers in tls."
        protocol    = "tcp"
        from_port   = 9094
        to_port     = 9094

        ipv4_cidrs = var.broker_allowed_ingress_cidrs
      },
    ] : [],
    var.authentication.sasl_scram.enabled ? [
      {
        id          = "broker-sasl-scram/cidrs"
        description = "Allow CIDRs to communicate with Kafka brokers in SASL SCRAM."
        protocol    = "tcp"
        from_port   = 9096
        to_port     = 9096

        ipv4_cidrs = var.broker_allowed_ingress_cidrs
      },
    ] : [],
    var.authentication.sasl_iam.enabled ? [
      {
        id          = "broker-sasl-iam/cidrs"
        description = "Allow CIDRs to communicate with Kafka brokers in SASL IAM."
        protocol    = "tcp"
        from_port   = 9098
        to_port     = 9098

        ipv4_cidrs = var.broker_allowed_ingress_cidrs
      },
    ] : [],
    [
      {
        id          = "broker-public-tls/cidrs"
        description = "Allow CIDRs to communicate with Kafka brokers in tls (public)."
        protocol    = "tcp"
        from_port   = 9194
        to_port     = 9194

        ipv4_cidrs = var.broker_allowed_ingress_cidrs
      },
      {
        id          = "broker-public-sasl-scram/cidrs"
        description = "Allow CIDRs to communicate with Kafka brokers in SASL SCRAM (public)."
        protocol    = "tcp"
        from_port   = 9196
        to_port     = 9196

        ipv4_cidrs = var.broker_allowed_ingress_cidrs
      },
      {
        id          = "broker-public-sasl-iam/cidrs"
        description = "Allow CIDRs to communicate with Kafka brokers in SASL IAM (public)."
        protocol    = "tcp"
        from_port   = 9198
        to_port     = 9198

        ipv4_cidrs = var.broker_allowed_ingress_cidrs
      },
      {
        id          = "zookeeper/cidrs"
        description = "Allow CIDRs to communicate with Kafka zookeepers."
        protocol    = "tcp"
        from_port   = 2181
        to_port     = 2181

        ipv4_cidrs = var.broker_allowed_ingress_cidrs
      },
    ],
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
  resource_group_enabled = false
  module_tags_enabled    = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
