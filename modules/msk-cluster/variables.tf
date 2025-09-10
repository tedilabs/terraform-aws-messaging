variable "name" {
  description = "(Required) Name of the MSK cluster."
  type        = string
  nullable    = false
}

variable "kafka_version" {
  description = "(Optional) Kafka version to use for the MSK cluster."
  type        = string
  default     = "3.6.0"
  nullable    = false
}

variable "kafka_server_properties" {
  description = "(Optional) Contents of the `server.properties` file for configuration of Kafka."
  type        = map(string)
  default     = {}
  nullable    = false
}

# TODO: naming
# TODO: validation
variable "broker_size" {
  description = "(Required) The desired total number of broker nodes in the kafka cluster. It must be a multiple of the number of specified client subnets."
  type        = number
  nullable    = false
}

variable "broker_instance_type" {
  description = "(Optional) The instance type to use for the kafka brokers."
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
  description = "(Optional) Whether to allow public access to MSK brokers."
  type        = bool
  default     = false
  nullable    = false
}

variable "broker_allowed_ingress_cidrs" {
  description = "(Optional) A list of CIDR for MSK ingress access."
  type        = list(string)
  default     = ["10.0.0.0/8"]
  nullable    = false
}

variable "broker_additional_security_groups" {
  description = "(Optional) A list of security group IDs to associate with ENIs to control who can communicate with the cluster."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "broker_storage" {
  description = <<EOF
  (Optional) The configuration for broker storage of the MSK cluster. `broker_storage` is defined below.
    (Optional) `volume_size` - The size in GiB of the EBS volume for the data drive on each broker node. Minimum value of `1` and maximum value of `16384`. Defaults to `1000`.
    (Optional) `provisioned_throughput` - The configuration for provisioned throughput of the EBS volume. `provisioned_throughput` is defined below.
      (Optional) `enabled` - Whether provisioned throughput is enabled or not. You can specify the provisioned throughput rate in MiB per second for clusters whose brokers are of type `kafka.m5.4xlarge` or larger and if the storage volume is 10 GiB or greater. Defaults to `false`.
      (Optional) `throughput` - Throughput value of the EBS volumes for the data drive on each kafka broker node in MiB per second. The minimum value is `250`. The maximum value varies between broker type.
  EOF
  type = object({
    volume_size = optional(number, 1000)
    provisioned_throughput = optional(object({
      enabled    = optional(bool, false)
      throughput = optional(number)
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
    error_message = "Valid value for `throughput` is greater than `250`."
  }
}

variable "cluster_storage_mode" {
  description = <<EOF
  (Optional) Controls storage mode for supported storage tiers. Valid values are are `LOCAL` or `TIERED`. Defaults to `LOCAL`.
    `LOCAL` - Storage mode that uses local storage for all topics.
    `TIERED` - Storage mode that uses remote, longer-term tiered storage for certain topics at a lower cost. A remote tier automatically expands your storage capacity if necessary.
  EOF
  type        = string
  default     = "LOCAL"
  nullable    = false

  validation {
    condition     = contains(["LOCAL", "TIERED"], var.cluster_storage_mode)
    error_message = "Valid values for `cluster_storage_mode` are `LOCAL` or `TIERED`."
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
    (Optional) `client_mode` - Encryption setting for data in transit between clients and brokers. Valid values are `TLS`, `TLS_PLAINTEXT`, `PLAINTEXT`. Defaults to `TLS_PLAINTEXT`.
  EOF
  type = object({
    in_cluster_enabled = optional(bool, true)
    client_mode        = optional(string, "TLS_PLAINTEXT")
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
  The configuration for CloudWatch Metrics of the MSK cluster. `cloudwatch_mterics` is defined below.
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
    (Optional) `allowed_ingress_ipv4_cidrs` - A list of IPv4 CIDRs to allow ingress access to Prometheus endpoint.
  EOF
  type = object({
    jmx_exporter_enabled       = optional(bool, false)
    node_exporter_enabled      = optional(bool, false)
    allowed_ingress_ipv4_cidrs = optional(set(string), ["10.0.0.0/8"])
  })
  default  = {}
  nullable = false
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
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################




variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
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
