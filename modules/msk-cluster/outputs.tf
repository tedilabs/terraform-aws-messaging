output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_msk_cluster.this.region
}

output "arn" {
  description = "The ARN of the MSK cluster."
  value       = aws_msk_cluster.this.arn
}

output "uuid" {
  description = "The UUID of the MSK cluster, for use in IAM policies."
  value       = aws_msk_cluster.this.cluster_uuid
}

output "name" {
  description = "The MSK cluster name."
  value       = var.name
}

output "version" {
  description = "Current version of the MSK Cluster used for updates."
  value       = aws_msk_cluster.this.current_version
}

output "customer_action_status" {
  description = "The status indicating whether Amazon MSK requires customer action for the cluster, such as a broker reboot or a certificate renewal. Valid values are `NONE`, `ACTION_RECOMMENDED` and `CRITICAL_ACTION_REQUIRED`."
  value       = aws_msk_cluster.this.customer_action_status
}

output "kafka_version" {
  description = "The MSK cluster version."
  value       = var.kafka_version
}

output "kafka_config" {
  description = "The MSK configuration associated with the cluster. `null` if the cluster uses the MSK default configuration."
  value = (local.cluster_configuration != null
    ? {
      arn             = local.cluster_configuration.arn
      name            = local.cluster_configuration.name
      latest_revision = local.cluster_configuration.latest_revision
      properties      = local.cluster_configuration.server_properties
    }
    : null
  )
}

output "security_groups" {
  description = "A list of security group IDs which is associated with the broker nodes of the MSK cluster."
  value       = aws_msk_cluster.this.broker_node_group_info[0].security_groups
}

output "ip_address_type" {
  description = "The type of IP addresses used by the MSK cluster."
  value = {
    for k, v in local.ip_address_types :
    v => k
  }[aws_msk_cluster.this.broker_node_group_info[0].connectivity_info[0].network_type]
}

output "multi_vpc_connectivity" {
  description = <<EOF
  The configuration for multi-VPC private connectivity of the MSK cluster.
    `enabled` - Whether the multi-VPC private connectivity configuration is managed.
    `sasl_iam` - Whether IAM client authentication is enabled for multi-VPC private connectivity.
    `sasl_scram` - Whether SASL/SCRAM client authentication is enabled for multi-VPC private connectivity.
    `tls` - Whether TLS client authentication is enabled for multi-VPC private connectivity.
  EOF
  value = {
    enabled = var.multi_vpc_connectivity.enabled
    sasl_iam = {
      enabled = try(aws_msk_cluster.this.broker_node_group_info[0].connectivity_info[0].vpc_connectivity[0].client_authentication[0].sasl[0].iam, false)
    }
    sasl_scram = {
      enabled = try(aws_msk_cluster.this.broker_node_group_info[0].connectivity_info[0].vpc_connectivity[0].client_authentication[0].sasl[0].scram, false)
    }
    tls = {
      enabled = try(aws_msk_cluster.this.broker_node_group_info[0].connectivity_info[0].vpc_connectivity[0].client_authentication[0].tls, false)
    }
  }
}

output "broker_nodes" {
  description = "The information of broker nodes in the kafka cluster."
  value       = data.aws_msk_broker_nodes.this.node_info_list
}

output "broker" {
  description = <<EOF
  A configuration for brokers of the Kafka cluster.
    `size` - The number of broker nodes in the kafka cluster.
    `instance_type` - The instance type used by the kafka brokers.

    `subnets` - A list of the subnets which the broker nodes are placed in.
    `public_access_enabled` - Whether public access to MSK brokers is enabled.
  EOF
  value = {
    size          = aws_msk_cluster.this.number_of_broker_nodes
    instance_type = aws_msk_cluster.this.broker_node_group_info[0].instance_type

    subnets               = aws_msk_cluster.this.broker_node_group_info[0].client_subnets
    public_access_enabled = var.broker_public_access_enabled
  }
}

output "broker_storage" {
  description = <<EOF
  The configuration for broker storage of the MSK cluster. `null` for Express brokers, which manage their storage.
    `volume_size` - The current size in GiB of the EBS volume for each broker, including the growth by automatic scaling.
    `provisioned_throughput` - The configuration for provisioned throughput of the EBS volume.
    `autoscaling` - The configuration for automatic scaling of the broker storage.
  EOF
  value = (!local.is_express_broker
    ? {
      volume_size = aws_msk_cluster.this.broker_node_group_info[0].storage_info[0].ebs_storage_info[0].volume_size
      provisioned_throughput = {
        enabled    = try(aws_msk_cluster.this.broker_node_group_info[0].storage_info[0].ebs_storage_info[0].provisioned_throughput[0].enabled, false)
        throughput = try(aws_msk_cluster.this.broker_node_group_info[0].storage_info[0].ebs_storage_info[0].provisioned_throughput[0].volume_throughput, null)
      }
      autoscaling = {
        enabled            = var.broker_storage.autoscaling.enabled
        max_volume_size    = one(aws_appautoscaling_target.storage[*].max_capacity)
        target_utilization = one(aws_appautoscaling_policy.storage[*].target_tracking_scaling_policy_configuration[0].target_value)
      }
    }
    : null
  )
}

output "intelligent_rebalancing" {
  description = "The configuration for intelligent rebalancing of the MSK cluster. `null` for Standard brokers, which do not support intelligent rebalancing."
  value = (local.is_express_broker
    ? {
      enabled = aws_msk_cluster.this.rebalancing[0].status == "ACTIVE"
    }
    : null
  )
}

output "storage_mode" {
  description = "The storage mode of the MSK cluster."
  value       = aws_msk_cluster.this.storage_mode
}

output "authentication" {
  description = "A configuration for authentication of the Kafka cluster."
  value = {
    unauthenticated_access = {
      enabled = aws_msk_cluster.this.client_authentication[0].unauthenticated
    }
    sasl = {
      iam = {
        enabled = aws_msk_cluster.this.client_authentication[0].sasl[0].iam
      }
      scram = {
        enabled = aws_msk_cluster.this.client_authentication[0].sasl[0].scram
        kms_key = var.authentication.sasl_scram.kms_key
        users   = var.authentication.sasl_scram.users
      }
    }
    tls = {
      enabled                             = var.authentication.tls.enabled
      acm_private_certificate_authorities = try(aws_msk_cluster.this.client_authentication[0].tls[0].certificate_authority_arns, [])
    }
  }
}

output "encryption_at_rest" {
  description = <<EOF
  The configuration for encryption at rest of the Kafka cluster.
  EOF
  value = {
    kms_key = aws_msk_cluster.this.encryption_info[0].encryption_at_rest_kms_key_arn
  }
}

output "encryption_in_transit" {
  description = <<EOF
  The configuration for encryption in transit of the Kafka cluster.
  EOF
  value = {
    in_cluster_enabled = aws_msk_cluster.this.encryption_info[0].encryption_in_transit[0].in_cluster
    client_mode        = aws_msk_cluster.this.encryption_info[0].encryption_in_transit[0].client_broker
  }
}

output "logging" {
  description = <<EOF
  A configuration for logging of the Kafka cluster.
    `cloudwatch` - The configuration for MSK broker logs to CloudWatch Logs.
    `firehose` - The configuration for MSK broker logs to Kinesis Firehose.
    `s3` - The configuration for MSK broker logs to S3 Bucket.
  EOF
  value = {
    cloudwatch = {
      enabled   = aws_msk_cluster.this.logging_info[0].broker_logs[0].cloudwatch_logs[0].enabled
      log_group = aws_msk_cluster.this.logging_info[0].broker_logs[0].cloudwatch_logs[0].log_group
    }
    firehose = {
      enabled         = aws_msk_cluster.this.logging_info[0].broker_logs[0].firehose[0].enabled
      delivery_stream = aws_msk_cluster.this.logging_info[0].broker_logs[0].firehose[0].delivery_stream
    }
    s3 = {
      enabled    = aws_msk_cluster.this.logging_info[0].broker_logs[0].s3[0].enabled
      bucket     = aws_msk_cluster.this.logging_info[0].broker_logs[0].s3[0].bucket
      key_prefix = aws_msk_cluster.this.logging_info[0].broker_logs[0].s3[0].prefix
    }
  }
}

output "monitoring" {
  description = <<EOF
  A configuration for monitoring of the Kafka cluster.
    `cloudwatch_metrics` - The configuration for MSK CloudWatch Metrics.
    `prometheus` - The configuration for Prometheus open monitoring.
  EOF
  value = {
    cloudwatch_metrics = {
      monitoring_level = aws_msk_cluster.this.enhanced_monitoring
    }
    prometheus = {
      jmx_exporter_enabled  = aws_msk_cluster.this.open_monitoring[0].prometheus[0].jmx_exporter[0].enabled_in_broker
      node_exporter_enabled = aws_msk_cluster.this.open_monitoring[0].prometheus[0].node_exporter[0].enabled_in_broker
    }
  }
}

output "bootstrap_brokers" {
  description = <<EOF
  The information to bootstrap connectivity to the Kafka cluster. Each value is a comma separated list of one or more `host:port` pairs of the brokers, or an empty string if the connectivity is not available. AWS may not always return all endpoints, so the values may not be stable across applies.
    `ipv4` - The bootstrap brokers over IPv4.
      `plaintext` - Only available if `encryption_in_transit.client_mode` is `PLAINTEXT` or `TLS_PLAINTEXT`.
      `tls` - Only available if `encryption_in_transit.client_mode` is `TLS` or `TLS_PLAINTEXT`.
      `sasl_iam` - Only available if `authentication.sasl_iam` is enabled and `encryption_in_transit.client_mode` is `TLS` or `TLS_PLAINTEXT`.
      `sasl_scram` - Only available if `authentication.sasl_scram` is enabled and `encryption_in_transit.client_mode` is `TLS` or `TLS_PLAINTEXT`.
    `ipv6` - The bootstrap brokers over IPv6. `null` if `ip_address_type` is not `DUALSTACK`. With public access, the same IPv6 bootstrap brokers are used for both private and public access. The conditions of `plaintext`, `tls`, `sasl_iam` and `sasl_scram` are the same as `ipv4`.
    `public_access` - The bootstrap brokers for public access. `null` if `broker_public_access_enabled` is `false`.
      `tls` - Always available with public access.
      `sasl_iam` - Only available if `authentication.sasl_iam` is enabled.
      `sasl_scram` - Only available if `authentication.sasl_scram` is enabled.
    `multi_vpc_connectivity` - The bootstrap brokers for multi-VPC private connectivity. `null` if `multi_vpc_connectivity.enabled` is `false`. Clients connect through managed VPC connections in their VPCs.
      `tls` - Only available if `multi_vpc_connectivity.tls` is enabled.
      `sasl_iam` - Only available if `multi_vpc_connectivity.sasl_iam` is enabled.
      `sasl_scram` - Only available if `multi_vpc_connectivity.sasl_scram` is enabled.
  EOF
  value = {
    ipv4 = {
      plaintext  = aws_msk_cluster.this.bootstrap_brokers
      tls        = aws_msk_cluster.this.bootstrap_brokers_tls
      sasl_iam   = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
      sasl_scram = aws_msk_cluster.this.bootstrap_brokers_sasl_scram
    }
    ipv6 = (var.ip_address_type == "DUALSTACK"
      ? {
        plaintext  = aws_msk_cluster.this.bootstrap_brokers_ipv6
        tls        = aws_msk_cluster.this.bootstrap_brokers_tls_ipv6
        sasl_iam   = aws_msk_cluster.this.bootstrap_brokers_sasl_iam_ipv6
        sasl_scram = aws_msk_cluster.this.bootstrap_brokers_sasl_scram_ipv6
      }
      : null
    )
    public_access = (var.broker_public_access_enabled
      ? {
        tls        = aws_msk_cluster.this.bootstrap_brokers_public_tls
        sasl_iam   = aws_msk_cluster.this.bootstrap_brokers_public_sasl_iam
        sasl_scram = aws_msk_cluster.this.bootstrap_brokers_public_sasl_scram
      }
      : null
    )
    multi_vpc_connectivity = (var.multi_vpc_connectivity.enabled
      ? {
        tls        = aws_msk_cluster.this.bootstrap_brokers_vpc_connectivity_tls
        sasl_iam   = aws_msk_cluster.this.bootstrap_brokers_vpc_connectivity_sasl_iam
        sasl_scram = aws_msk_cluster.this.bootstrap_brokers_vpc_connectivity_sasl_scram
      }
      : null
    )
  }
}

output "zookeeper_connections" {
  description = <<EOF
  A configuration for connecting to the Apache Zookeeper cluster. `null` for KRaft clusters, which have no ZooKeeper nodes.
    `tcp` - A comma separated list of one or more IP:port pairs to use to connect to the Apache Zookeeper cluster.
    `tls` - A comma separated list of one or more IP:port pairs to use to connect to the Apache Zookeeper cluster via TLS.
  EOF
  value = (!local.kraft_enabled
    ? {
      tcp = aws_msk_cluster.this.zookeeper_connect_string
      tls = aws_msk_cluster.this.zookeeper_connect_string_tls
    }
    : null
  )
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}
