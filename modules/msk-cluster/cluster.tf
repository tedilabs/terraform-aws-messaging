locals {
  metadata = {
    package = "terraform-aws-messaging"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}


###################################################
# Configuration for MSK Cluster
###################################################

locals {
  server_properties = <<EOT
%{for k, v in var.kafka_server_properties~}
${k} = ${v}
%{endfor~}
EOT
}

resource "aws_msk_configuration" "this" {
  name           = var.name
  description    = "Configuration for ${var.name} Kafka Cluster."
  kafka_versions = [var.kafka_version]

  server_properties = local.server_properties

  lifecycle {
    create_before_destroy = true
  }
}


###################################################
# MSK Cluster
###################################################

resource "aws_msk_cluster" "this" {
  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.broker_size

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    az_distribution = "DEFAULT"
    client_subnets  = var.broker_subnets
    security_groups = concat(
      [module.security_group.id],
      var.broker_additional_security_groups
    )

    # TODO: `vpc_connectivity`
    # TODO: public access cidrs
    connectivity_info {
      public_access {
        type = var.broker_public_access_enabled ? "SERVICE_PROVIDED_EIPS" : "DISABLED"
      }
    }

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_storage.volume_size

        provisioned_throughput {
          enabled           = var.broker_storage.provisioned_throughput.enabled
          volume_throughput = var.broker_storage.provisioned_throughput.enabled ? var.broker_storage.provisioned_throughput.throughput : null
        }
      }
    }
  }
  storage_mode = var.cluster_storage_mode

  configuration_info {
    arn      = aws_msk_configuration.this.arn
    revision = aws_msk_configuration.this.latest_revision
  }


  ## Authentiation
  client_authentication {
    unauthenticated = var.authentication.unauthenticated_access.enabled

    sasl {
      iam   = var.authentication.sasl_iam.enabled
      scram = var.authentication.sasl_scram.enabled
    }

    dynamic "tls" {
      for_each = var.authentication.tls.enabled ? [var.authentication.tls] : []

      content {
        certificate_authority_arns = tls.value.acm_private_certificate_authorities
      }
    }
  }


  ## Encryption
  encryption_info {
    encryption_at_rest_kms_key_arn = var.encryption_at_rest.kms_key

    encryption_in_transit {
      in_cluster    = var.encryption_in_transit.in_cluster_enabled
      client_broker = var.encryption_in_transit.client_mode
    }
  }


  ## Logging
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = var.logging.cloudwatch_logs.enabled
        log_group = var.logging.cloudwatch_logs.log_group
      }
      firehose {
        enabled         = var.logging.firehose.enabled
        delivery_stream = var.logging.firehose.delivery_stream
      }
      s3 {
        enabled = var.logging.s3.enabled
        bucket  = var.logging.s3.bucket
        prefix  = var.logging.s3.key_prefix
      }
    }
  }


  ## Monitoring
  enhanced_monitoring = var.cloudwatch_metrics.monitoring_level

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = var.prometheus.jmx_exporter_enabled
      }

      node_exporter {
        enabled_in_broker = var.prometheus.node_exporter_enabled
      }
    }
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}

data "aws_msk_broker_nodes" "this" {
  cluster_arn = aws_msk_cluster.this.arn
}
