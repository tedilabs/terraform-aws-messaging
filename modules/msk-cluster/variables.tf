variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) Name of the MSK cluster."
  type        = string
  nullable    = false
}

variable "kafka_version" {
  description = "(Optional) Kafka version to use for the MSK cluster. Use the version string of MSK, such as `3.9.x`, `3.9.x.kraft` or `4.1.x.kraft`. KRaft versions end with `.kraft`. Defaults to `3.9.x`, the version recommended by AWS."
  type        = string
  default     = "3.9.x"
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.([0-9]+|x)(\\.[0-9]+)?(\\.(kraft|tiered))?$", var.kafka_version))
    error_message = "`kafka_version` must be an MSK version string such as `3.9.x`, `3.9.x.kraft` or `4.1.x.kraft`."
  }
}

variable "default_cluster_configuration" {
  description = <<EOF
  (Optional) The configuration of the default MSK configuration for the cluster. Use `cluster_configuration` if `default_cluster_configuration.enabled` is `false`. `default_cluster_configuration` as defined below.
    (Optional) `enabled` - Whether to create and use the default MSK configuration managed by this module. Defaults to `true`.
    (Optional) `name` - The name of the default MSK configuration. Defaults to `{name}-{kafka_version}` with dots in the Kafka version replaced by hyphens (e.g. `my-cluster-3-9-x-kraft`). The Kafka version is part of the default name because changing `kafka_version` replaces the MSK configuration, and the replacement is created before the old one is deleted. If you set a fixed name, change it together with `kafka_version` to avoid a name conflict.
    (Optional) `description` - The description of the default MSK configuration. Defaults to `Managed by Terraform.`.
    (Optional) `server_properties` - The key/value set for the contents of the `server.properties` file. Each key is the name of the Kafka property. Each value is the value of the Kafka property. Defaults to `{}`.
  EOF
  type = object({
    enabled           = optional(bool, true)
    name              = optional(string)
    description       = optional(string, "Managed by Terraform.")
    server_properties = optional(map(string), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = (var.default_cluster_configuration.name != null
      ? can(regex("^[0-9A-Za-z][0-9A-Za-z-]*$", var.default_cluster_configuration.name))
      : true
    )
    error_message = "`default_cluster_configuration.name` must start with a letter or digit and contain only letters, digits and hyphens."
  }
}

variable "cluster_configuration" {
  description = "(Optional) The ARN of the MSK configuration to associate with the cluster. The latest revision of the configuration is always used. Only used if `default_cluster_configuration.enabled` is `false`. If omitted, the cluster uses the MSK default configuration."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (var.cluster_configuration != null
      ? can(regex("^arn:aws[a-z-]*:kafka:[a-z0-9-]+:[0-9]{12}:configuration/[^/]+/.+$", var.cluster_configuration))
      : true
    )
    error_message = "`cluster_configuration` must be the ARN of an MSK configuration."
  }
}

variable "broker_size" {
  description = "(Required) The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of subnets in `broker_subnets`, because MSK places the same number of brokers in each subnet."
  type        = number
  nullable    = false

  validation {
    condition     = floor(var.broker_size) == var.broker_size
    error_message = "`broker_size` must be a whole number."
  }
  validation {
    condition     = var.broker_size >= 1
    error_message = "`broker_size` must be greater than or equal to `1`."
  }
  validation {
    condition = (length(var.broker_subnets) > 0
      ? var.broker_size % length(var.broker_subnets) == 0
      : true
    )
    error_message = "`broker_size` must be a multiple of the number of subnets in `broker_subnets`."
  }
}

variable "broker_instance_type" {
  description = "(Optional) The instance type to use for the kafka brokers. Standard brokers use `kafka.*` instance types (e.g. `kafka.m5.large`), and Express brokers use `express.*` instance types (e.g. `express.m7g.large`). Defaults to `kafka.m5.large`."
  type        = string
  default     = "kafka.m5.large"
  nullable    = false
}

variable "broker_subnets" {
  description = "(Required) A list of subnet IDs to place ENIs of the MSK cluster broker nodes within."
  type        = list(string)
  nullable    = false
}

variable "broker_public_access_enabled" {
  description = <<EOF
  (Optional) Whether to allow public access to MSK brokers. Defaults to `false`. Public access cannot be turned on while creating a cluster; create the cluster first, then turn it on with an update. The cluster must meet the following conditions:
    - The subnets of the brokers must be public subnets.
    - `authentication.unauthenticated_access` must be disabled, and at least one of `authentication.sasl_iam`, `authentication.sasl_scram` and `authentication.tls` must be enabled.
    - `encryption_in_transit.in_cluster_enabled` must be `true`. It cannot be turned on for a cluster created with it turned off.
    - `encryption_in_transit.client_mode` must be `TLS`.
    - With SASL/SCRAM or mTLS, Apache Kafka ACLs must be set and `allow.everyone.if.no.acl.found` must be `false` in the cluster configuration.
  MSK does not support restricting public access by IP address. Allow the public ports (`9194`, `9196`, `9198`) only from the required sources with the security groups (e.g. `default_security_group.broker_ingress_ipv4_cidrs`).
  EOF
  type        = bool
  default     = false
  nullable    = false

  validation {
    condition     = !var.broker_public_access_enabled || !var.authentication.unauthenticated_access.enabled
    error_message = "Public access requires `authentication.unauthenticated_access` to be disabled."
  }

  validation {
    condition = !var.broker_public_access_enabled || anytrue([
      var.authentication.sasl_iam.enabled,
      var.authentication.sasl_scram.enabled,
      var.authentication.tls.enabled,
    ])
    error_message = "Public access requires at least one of `authentication.sasl_iam`, `authentication.sasl_scram` and `authentication.tls` to be enabled."
  }

  validation {
    condition     = !var.broker_public_access_enabled || var.encryption_in_transit.in_cluster_enabled
    error_message = "Public access requires `encryption_in_transit.in_cluster_enabled` to be `true`."
  }

  validation {
    condition     = !var.broker_public_access_enabled || var.encryption_in_transit.client_mode == "TLS"
    error_message = "Public access requires `encryption_in_transit.client_mode` to be `TLS`."
  }
}

variable "ip_address_type" {
  description = <<EOF
  (Optional) The type of IP addresses used by the MSK cluster. Valid values are `IPv4` and `DUALSTACK`. Only updating from `IPv4` to `DUALSTACK` is allowed. Defaults to `IPv4`.
    `IPv4` - The brokers are reachable over IPv4 only.
    `DUALSTACK` - The brokers are reachable over both IPv4 and IPv6. The subnets of the brokers must have IPv6 CIDR blocks. Not supported on the `kafka.t3.small` broker instance type.
  With `DUALSTACK`, IPv6 clients connect to the brokers on separate ports (`20092`, `20094`, `20096`, `20098`), and the default security group allows the sources in `default_security_group.broker_ingress_*` on them. ZooKeeper nodes are reachable over IPv4 only.
  EOF
  type        = string
  default     = "IPv4"
  nullable    = false

  validation {
    condition     = contains(["IPv4", "DUALSTACK"], var.ip_address_type)
    error_message = "Valid values for `ip_address_type` are `IPv4` and `DUALSTACK`."
  }

  validation {
    condition     = var.ip_address_type != "DUALSTACK" || var.broker_instance_type != "kafka.t3.small"
    error_message = "`DUALSTACK` is not supported on the `kafka.t3.small` broker instance type."
  }
}

variable "multi_vpc_connectivity" {
  description = <<EOF
  (Optional) The configuration for multi-VPC private connectivity (powered by AWS PrivateLink) of the MSK cluster. Clients in other VPCs or AWS accounts connect to the brokers through AWS PrivateLink without VPC peering. Multi-VPC private connectivity can only be turned on for an existing cluster, is not supported on the `kafka.t3.small` broker instance type, and each client authentication type must also be enabled on the cluster via `authentication`. `multi_vpc_connectivity` is defined below.
    (Optional) `enabled` - Whether to manage the multi-VPC private connectivity configuration of the cluster. Defaults to `false`.
    (Optional) `sasl_iam` - The configuration for IAM client authentication for multi-VPC private connectivity. `sasl_iam` is defined below.
      (Optional) `enabled` - Whether to enable IAM client authentication. Defaults to `false`.
    (Optional) `sasl_scram` - The configuration for SASL/SCRAM client authentication for multi-VPC private connectivity. `sasl_scram` is defined below.
      (Optional) `enabled` - Whether to enable SASL/SCRAM client authentication. Defaults to `false`.
    (Optional) `tls` - The configuration for TLS client authentication for multi-VPC private connectivity. `tls` is defined below.
      (Optional) `enabled` - Whether to enable TLS client authentication. Defaults to `false`.
  EOF
  type = object({
    enabled = optional(bool, false)
    sasl_iam = optional(object({
      enabled = optional(bool, false)
    }), {})
    sasl_scram = optional(object({
      enabled = optional(bool, false)
    }), {})
    tls = optional(object({
      enabled = optional(bool, false)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      !var.multi_vpc_connectivity.sasl_iam.enabled || var.authentication.sasl_iam.enabled,
      !var.multi_vpc_connectivity.sasl_scram.enabled || var.authentication.sasl_scram.enabled,
      !var.multi_vpc_connectivity.tls.enabled || var.authentication.tls.enabled,
    ])
    error_message = "Each client authentication type of `multi_vpc_connectivity` must also be enabled on the cluster via `authentication`."
  }

  validation {
    condition     = !var.multi_vpc_connectivity.enabled || var.broker_instance_type != "kafka.t3.small"
    error_message = "Multi-VPC private connectivity is not supported on the `kafka.t3.small` broker instance type."
  }
}

variable "default_security_group" {
  description = <<EOF
  (Optional) The configuration of the default security group for the MSK cluster. `default_security_group` block as defined below.
    (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.
    (Optional) `name` - The name of the default security group. If not provided, the cluster name is used for the name of security group.
    (Optional) `description` - The description of the default security group. Defaults to `Managed by Terraform.`.
    (Optional) `ingress_rules` - A list of ingress rules in a security group. Defaults to `[]`. Each block of `ingress_rules` as defined below.
      (Required) `id` - The ID of the ingress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule. Defaults to `Managed by Terraform.`.
      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
      (Required) `from_port` - The start of port range for the protocols.
      (Required) `to_port` - The end of port range for the protocols.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The source security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
    (Optional) `egress_rules` - A list of egress rules in a security group. Defaults to `[]`. Each block of `egress_rules` as defined below.
      (Required) `id` - The ID of the egress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule. Defaults to `Managed by Terraform.`.
      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
      (Required) `from_port` - The start of port range for the protocols.
      (Required) `to_port` - The end of port range for the protocols.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The destination security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a destination to this egress rule.
    (Optional) `broker_ingress_ipv4_cidrs` - A list of IPv4 CIDR ranges to allow on the Kafka broker ports that the cluster uses. Defaults to `[]`.
    (Optional) `broker_ingress_ipv6_cidrs` - A list of IPv6 CIDR ranges to allow on the Kafka broker ports that the cluster uses. Defaults to `[]`.
    (Optional) `broker_ingress_prefix_lists` - A list of prefix list IDs to allow on the Kafka broker ports that the cluster uses. Defaults to `[]`.
    (Optional) `broker_ingress_security_groups` - A list of security group IDs to allow on the Kafka broker ports that the cluster uses. Defaults to `[]`.
    (Optional) `zookeeper_ingress_ipv4_cidrs` - A list of IPv4 CIDR ranges to allow on the ZooKeeper ports. Only applied to the ZooKeeper-based clusters, and ignored for KRaft clusters. Defaults to `[]`.
    (Optional) `zookeeper_ingress_ipv6_cidrs` - A list of IPv6 CIDR ranges to allow on the ZooKeeper ports. MSK serves ZooKeeper over IPv4 only, so this takes effect only when MSK adds IPv6 support for ZooKeeper. Only applied to the ZooKeeper-based clusters, and ignored for KRaft clusters. Defaults to `[]`.
    (Optional) `zookeeper_ingress_prefix_lists` - A list of prefix list IDs to allow on the ZooKeeper ports. Only applied to the ZooKeeper-based clusters, and ignored for KRaft clusters. Defaults to `[]`.
    (Optional) `zookeeper_ingress_security_groups` - A list of security group IDs to allow on the ZooKeeper ports. Only applied to the ZooKeeper-based clusters, and ignored for KRaft clusters. Defaults to `[]`.
    (Optional) `prometheus_ingress_ipv4_cidrs` - A list of IPv4 CIDR ranges to allow on the enabled Prometheus exporter ports. Defaults to `[]`.
    (Optional) `prometheus_ingress_ipv6_cidrs` - A list of IPv6 CIDR ranges to allow on the enabled Prometheus exporter ports. Defaults to `[]`.
    (Optional) `prometheus_ingress_prefix_lists` - A list of prefix list IDs to allow on the enabled Prometheus exporter ports. Defaults to `[]`.
    (Optional) `prometheus_ingress_security_groups` - A list of security group IDs to allow on the enabled Prometheus exporter ports. Defaults to `[]`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    description = optional(string, "Managed by Terraform.")
    ingress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      []
    )
    egress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      []
    )
    broker_ingress_ipv4_cidrs          = optional(list(string), [])
    broker_ingress_ipv6_cidrs          = optional(list(string), [])
    broker_ingress_prefix_lists        = optional(list(string), [])
    broker_ingress_security_groups     = optional(list(string), [])
    zookeeper_ingress_ipv4_cidrs       = optional(list(string), [])
    zookeeper_ingress_ipv6_cidrs       = optional(list(string), [])
    zookeeper_ingress_prefix_lists     = optional(list(string), [])
    zookeeper_ingress_security_groups  = optional(list(string), [])
    prometheus_ingress_ipv4_cidrs      = optional(list(string), [])
    prometheus_ingress_ipv6_cidrs      = optional(list(string), [])
    prometheus_ingress_prefix_lists    = optional(list(string), [])
    prometheus_ingress_security_groups = optional(list(string), [])
  })
  default  = {}
  nullable = false
}

variable "security_groups" {
  description = "(Optional) A list of security group IDs to associate with ENIs of the MSK cluster broker nodes, in addition to the default security group."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "broker_storage" {
  description = <<EOF
  (Optional) The configuration for broker storage of the MSK cluster. Ignored for Express brokers (`express.*` broker instance types), which manage their storage. `broker_storage` is defined below.
    (Optional) `volume_size` - The initial size in GiB of the EBS volume for the data drive on each broker node. Minimum value of `1` and maximum value of `16384`. Defaults to `1000`. Only applied when the cluster is created; later changes are ignored so that Terraform does not revert the storage grown by `autoscaling`. Use `autoscaling` to grow the storage, or scale it up manually with the MSK console or the `UpdateBrokerStorage` API.
    (Optional) `provisioned_throughput` - The configuration for provisioned throughput of the EBS volume. `provisioned_throughput` is defined below.
      (Optional) `enabled` - Whether provisioned throughput is enabled or not. You can specify the provisioned throughput rate in MiB per second for clusters whose brokers are of type `kafka.m5.4xlarge` or larger and if the storage volume is 10 GiB or greater. Defaults to `false`.
      (Optional) `throughput` - Throughput value of the EBS volumes for the data drive on each kafka broker node in MiB per second. The minimum value is `250`. The maximum value varies between broker type.
    (Optional) `autoscaling` - The configuration for automatic scaling of the broker storage with Application Auto Scaling. MSK grows the storage of every broker by the larger of 10 GiB or 10% of the current size when the `KafkaBrokerStorageUtilization` metric reaches the target. The storage never shrinks, and a scaling action can occur only once every six hours. `autoscaling` is defined below.
      (Optional) `enabled` - Whether to enable automatic scaling of the broker storage. Not supported on Express brokers (`express.*` broker instance types). Defaults to `false`.
      (Optional) `max_volume_size` - The maximum size in GiB that automatic scaling can grow the storage of each broker to. Must be between `volume_size` and `16384`. Required if `enabled` is `true`.
      (Optional) `target_utilization` - The storage utilization in percent that triggers a scaling action. Valid values are between `10` and `80`. AWS recommends between `50` and `60`. Defaults to `60`.
  EOF
  type = object({
    volume_size = optional(number, 1000)
    provisioned_throughput = optional(object({
      enabled    = optional(bool, false)
      throughput = optional(number)
    }), {})
    autoscaling = optional(object({
      enabled            = optional(bool, false)
      max_volume_size    = optional(number)
      target_utilization = optional(number, 60)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.broker_storage.volume_size >= 1,
      var.broker_storage.volume_size <= 16384,
    ])
    error_message = "Valid value for `volume_size` is between `1` and `16384`."
  }
  validation {
    condition = anytrue([
      var.broker_storage.provisioned_throughput.enabled == false,
      var.broker_storage.provisioned_throughput.enabled == true && var.broker_storage.provisioned_throughput.throughput >= 250,
    ])
    error_message = "Valid value for `throughput` is at least `250`."
  }
  validation {
    condition     = !var.broker_storage.autoscaling.enabled || var.broker_storage.autoscaling.max_volume_size != null
    error_message = "`autoscaling.max_volume_size` is required when `autoscaling.enabled` is `true`."
  }
  validation {
    condition = (var.broker_storage.autoscaling.enabled && var.broker_storage.autoscaling.max_volume_size != null
      ? var.broker_storage.autoscaling.max_volume_size >= var.broker_storage.volume_size
      : true
    )
    error_message = "`autoscaling.max_volume_size` must be greater than or equal to `volume_size`."
  }
  validation {
    condition = (var.broker_storage.autoscaling.enabled && var.broker_storage.autoscaling.max_volume_size != null
      ? var.broker_storage.autoscaling.max_volume_size <= 16384
      : true
    )
    error_message = "`autoscaling.max_volume_size` must be less than or equal to `16384`."
  }
  validation {
    condition = alltrue([
      var.broker_storage.autoscaling.target_utilization >= 10,
      var.broker_storage.autoscaling.target_utilization <= 80,
    ])
    error_message = "Valid value for `autoscaling.target_utilization` is between `10` and `80`."
  }
  validation {
    condition     = !var.broker_storage.autoscaling.enabled || !startswith(var.broker_instance_type, "express.")
    error_message = "`autoscaling` is not supported on Express brokers (`express.*` broker instance types), which manage their storage."
  }
}

variable "intelligent_rebalancing" {
  description = <<EOF
  (Optional) The configuration for intelligent rebalancing of the MSK cluster. Intelligent rebalancing automatically adjusts the MSK Provisioned clusters with Express brokers when the broker count changes, without any additional cost. It can be paused or resumed if needed. Only applied to the clusters with Express brokers (`express.*` broker instance types), and ignored for Standard brokers. `intelligent_rebalancing` is defined below.
    (Optional) `enabled` - Whether to enable intelligent rebalancing. If enabled, MSK continuously monitors the cluster health and automatically distributes partitions when it detects resource imbalance or broker count changes. If disabled (paused), you need to monitor the cluster health and manually rebalance partitions when you scale the cluster. Defaults to `true`, the default of AWS for new Express clusters.
  EOF
  type = object({
    enabled = optional(bool, true)
  })
  default  = {}
  nullable = false
}

variable "storage_mode" {
  description = <<EOF
  (Optional) Controls storage mode for supported storage tiers. Valid values are `LOCAL` or `TIERED`. Defaults to `LOCAL`.
    `LOCAL` - Storage mode that uses local storage for all topics.
    `TIERED` - Storage mode that uses remote, longer-term tiered storage for certain topics at a lower cost. A remote tier automatically expands your storage capacity if necessary. Not supported on Express brokers (`express.*` broker instance types).
  EOF
  type        = string
  default     = "LOCAL"
  nullable    = false

  validation {
    condition     = contains(["LOCAL", "TIERED"], var.storage_mode)
    error_message = "Valid values for `storage_mode` are `LOCAL` or `TIERED`."
  }

  validation {
    condition     = var.storage_mode != "TIERED" || !startswith(var.broker_instance_type, "express.")
    error_message = "`TIERED` storage mode is not supported on Express brokers (`express.*` broker instance types), which manage their storage."
  }
}

variable "authentication" {
  description = <<EOF
  The configuration for authentication of the MSK cluster. `authentication` is defined below.
    (Optional) `unauthenticated_access.enabled` - Whether to enable unauthenticated access. Defaults to `true`.
    (Optional) `sasl_iam.enabled` - Whether to enable IAM client authentication. Defaults to `false`.
    (Optional) `sasl_scram` - The configuration for SASL/SCRAM client authentication. `sasl_scram` is defined below.
      (Optional) `enabled` - Whether to enable SCRAM client authentication via AWS Secrets Manager. Defaults to `false`.
      (Optional) `kms_key` - The ARN of a KMS key to encrypt AWS SecretsManager Secret resources for storing SASL/SCRAM authentication data. Only required when the MSK cluster has SASL/SCRAM authentication enabled. The Username/Password Authentication based on SASL/SCRAM needs to create a Secret resource in AWS SecretsManager with a custom AWS KMS Key. A secret created with the default AWS KMS key cannot be used with an Amazon MSK cluster.
      (Optional) `users` - A list of usernames to be allowed for SASL/SCRAM authentication to the MSK cluster. The password for each username is randomly generated and stored in AWS SecretsManager secret.
    (Optional) `tls` - The configuration for TLS client authentication. `tls` is defined below.
      (Optional) `enabled` - Whether to enable TLS client authentication. Defaults to `false`.
      (Optional) `acm_private_certificate_authorities` - A list of ACM Private CA ARNs to enable client authentication.
  EOF
  type = object({
    unauthenticated_access = optional(object({
      enabled = optional(bool, true)
    }), {})
    sasl_iam = optional(object({
      enabled = optional(bool, false)
    }), {})
    sasl_scram = optional(object({
      enabled = optional(bool, false)
      kms_key = optional(string)
      users   = optional(set(string), [])
    }), {})
    tls = optional(object({
      enabled                             = optional(bool, false)
      acm_private_certificate_authorities = optional(list(string), [])
    }), {})
  })
  default  = {}
  nullable = false
}

variable "encryption_at_rest" {
  description = <<EOF
  The configuration for at-rest encryption of the MSK cluster. `encryption_at_rest` is defined below.
    (Optional) `kms_key` - The short ID or ARN of the KMS key to use for at-rest encryption. If not supplied, uses AWS managed encryption key.
  EOF
  type = object({
    kms_key = optional(string)
  })
  default  = {}
  nullable = false
}

variable "encryption_in_transit" {
  description = <<EOF
  The configuration for in-transit encryption of the MSK cluster.
    (Optional) `in_cluster_enabled` - Whether data communication among broker nodes is encrypted. Defaults to `true`.
    (Optional) `client_mode` - Encryption setting for data in transit between clients and brokers. Valid values are `TLS`, `TLS_PLAINTEXT`, `PLAINTEXT`. Defaults to `TLS`.
  EOF
  type = object({
    in_cluster_enabled = optional(bool, true)
    client_mode        = optional(string, "TLS")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["TLS", "TLS_PLAINTEXT", "PLAINTEXT"], var.encryption_in_transit.client_mode)
    error_message = "Valid values for `client_mode` are `TLS`, `TLS_PLAINTEXT`, `PLAINTEXT`."
  }
}

variable "logging" {
  description = <<EOF
  The configuration for logging of the MSK cluster. `logging` is defined below.
    (Optional) `cloudwatch_logs` - The configuration for logging with CloudWatch Logs of the MSK cluster. `cloudwatch_logs` is defined below.
      (Optional) `enabled` - Whether to enable or disable streaming broker logs to Cloudwatch Logs.
      (Optional) `log_group` - The name of the CloudWatch Log Group to deliver logs to.
    (Optional) `firehose` - The configuration for logging with Kinesis Data Firehose of the MSK cluster. `firehose` is defined below.
      (Optional) `enabled` - Whether to enable or disable streaming broker logs to Kinesis Data Firehose.
      (Optional) `delivery_stream` - The name of the Kinesis Data Firehose delivery stream to deliver logs to.
    (Optional) `s3` - The configuration for logging with S3 of the MSK cluster. `s3` is defined below.
      (Optional) `enabled` - Whether to enable or disable streaming broker logs to S3.
      (Optional) `bucket` - The name of the S3 bucket to deliver logs to.
      (Optional) `key_prefix` - The prefix to append to the folder name.
  EOF
  type = object({
    cloudwatch_logs = optional(object({
      enabled   = optional(bool, false)
      log_group = optional(string)
    }), {})
    firehose = optional(object({
      enabled         = optional(bool, false)
      delivery_stream = optional(string)
    }), {})
    s3 = optional(object({
      enabled    = optional(bool, false)
      bucket     = optional(string)
      key_prefix = optional(string)
    }), {})
  })
  default  = {}
  nullable = false
}

variable "cloudwatch_metrics" {
  description = <<EOF
  The configuration for CloudWatch Metrics of the MSK cluster. `cloudwatch_metrics` is defined below.
    (Optional) `monitoring_level` - The desired enhanced MSK CloudWatch monitoring level. `DEFAULT`, `PER_BROKER`, `PER_TOPIC_PER_BROKER`, `PER_TOPIC_PER_PARTITION` are available. Defaults to `DEFAULT`.
  EOF
  type = object({
    monitoring_level = optional(string, "DEFAULT")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["DEFAULT", "PER_BROKER", "PER_TOPIC_PER_BROKER", "PER_TOPIC_PER_PARTITION"], var.cloudwatch_metrics.monitoring_level)
    error_message = "Valid values for `monitoring_level` are `DEFAULT`, `PER_BROKER`, `PER_TOPIC_PER_BROKER`, `PER_TOPIC_PER_PARTITION`."
  }
}

variable "prometheus" {
  description = <<EOF
  The configuration for Open Monitoring with Prometheus of the MSK cluster. `prometheus` is defined below.
    (Optional) `jmx_exporter_enabled` - Whether to enable or disable the JMX Exporter.
    (Optional) `node_exporter_enabled` - Whether to enable or disable the Node Exporter.
  EOF
  type = object({
    jmx_exporter_enabled  = optional(bool, false)
    node_exporter_enabled = optional(bool, false)
  })
  default  = {}
  nullable = false
}

variable "policy" {
  description = "(Optional) A valid policy JSON document. The resource-based policy of the MSK cluster defines who can access the cluster from other AWS accounts, such as for multi-VPC private connectivity (`kafka:CreateVpcConnection`) or MSK Replicator."
  type        = string
  default     = null
  nullable    = true
}

variable "timeouts" {
  description = "(Optional) How long to wait for the MSK cluster to be created/updated/deleted."
  type        = map(string)
  default = {
    create = "120m"
    update = "120m"
    delete = "120m"
  }
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module information."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group" {
  description = <<EOF
  (Optional) A configuration of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}
