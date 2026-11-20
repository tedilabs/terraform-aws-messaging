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
%{for k, v in var.default_cluster_configuration.server_properties~}
${k} = ${v}
%{endfor~}
EOT

  cluster_configuration = (var.default_cluster_configuration.enabled
    ? {
      arn               = aws_msk_configuration.this[0].arn
      name              = aws_msk_configuration.this[0].name
      latest_revision   = aws_msk_configuration.this[0].latest_revision
      server_properties = aws_msk_configuration.this[0].server_properties
    }
    : (var.cluster_configuration != null
      ? {
        arn               = data.aws_msk_configuration.this[0].arn
        name              = data.aws_msk_configuration.this[0].name
        latest_revision   = data.aws_msk_configuration.this[0].latest_revision
        server_properties = data.aws_msk_configuration.this[0].server_properties
      }
      : null
    )
  )
}

resource "aws_msk_configuration" "this" {
  count = var.default_cluster_configuration.enabled ? 1 : 0

  region = var.region

  name           = coalesce(var.default_cluster_configuration.name, "${var.name}-${replace(var.kafka_version, ".", "-")}")
  description    = var.default_cluster_configuration.description
  kafka_versions = [var.kafka_version]

  server_properties = local.server_properties

  lifecycle {
    create_before_destroy = true
  }
}

# INFO: The data source finds a configuration only by name, which is the
# second segment of the ARN (`arn:...:configuration/{name}/{uuid}`).
data "aws_msk_configuration" "this" {
  count = (!var.default_cluster_configuration.enabled && var.cluster_configuration != null) ? 1 : 0

  region = var.region

  name = split("/", var.cluster_configuration)[1]
}


###################################################
# MSK Cluster
###################################################

locals {
  is_express_broker = startswith(var.broker_instance_type, "express.")

  ip_address_types = {
    "IPv4"      = "IPV4"
    "DUALSTACK" = "DUAL"
  }
}

resource "aws_msk_cluster" "this" {
  region = var.region

  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.broker_size

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    az_distribution = "DEFAULT"
    client_subnets  = var.broker_subnets
    security_groups = local.security_groups

    connectivity_info {
      network_type = local.ip_address_types[var.ip_address_type]

      public_access {
        type = var.broker_public_access_enabled ? "SERVICE_PROVIDED_EIPS" : "DISABLED"
      }

      dynamic "vpc_connectivity" {
        for_each = var.multi_vpc_connectivity.enabled ? [var.multi_vpc_connectivity] : []

        content {
          client_authentication {
            sasl {
              iam   = vpc_connectivity.value.sasl_iam.enabled
              scram = vpc_connectivity.value.sasl_scram.enabled
            }
            tls = vpc_connectivity.value.tls.enabled
          }
        }
      }
    }

    dynamic "storage_info" {
      for_each = local.is_express_broker ? [] : [var.broker_storage]

      content {
        ebs_storage_info {
          volume_size = storage_info.value.volume_size

          provisioned_throughput {
            enabled           = storage_info.value.provisioned_throughput.enabled
            volume_throughput = storage_info.value.provisioned_throughput.enabled ? storage_info.value.provisioned_throughput.throughput : null
          }
        }
      }
    }
  }
  storage_mode = var.cluster_storage_mode

  dynamic "configuration_info" {
    for_each = local.cluster_configuration != null ? [local.cluster_configuration] : []

    content {
      arn      = configuration_info.value.arn
      revision = configuration_info.value.latest_revision
    }
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


  ## Intelligent Rebalancing
  dynamic "rebalancing" {
    for_each = local.is_express_broker ? [var.intelligent_rebalancing] : []

    content {
      status = rebalancing.value.enabled ? "ACTIVE" : "PAUSED"
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
  region = var.region

  cluster_arn = aws_msk_cluster.this.arn
}
