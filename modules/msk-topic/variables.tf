variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "cluster" {
  description = "(Required) The ARN of the MSK cluster to create the topic in. The cluster must be an MSK Provisioned cluster in the `ACTIVE` state, running Apache Kafka 3.6.0 or later. Changing this value replaces the topic."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:kafka:[a-z0-9-]+:[0-9]{12}:cluster/[^/]+/.+$", var.cluster))
    error_message = "`cluster` must be the ARN of an MSK cluster."
  }
}

variable "name" {
  description = "(Required) The name of the Kafka topic. A topic name can have a maximum of 249 characters, including letters, numbers, dots, underscores, and hyphens. Changing this value replaces the topic."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,249}$", var.name))
    error_message = "`name` must be 1 to 249 characters of letters, numbers, dots, underscores and hyphens."
  }
  validation {
    condition     = !contains([".", ".."], var.name)
    error_message = "`name` cannot be `.` or `..`."
  }
}

variable "partition_count" {
  description = "(Required) The number of partitions for the topic. Kafka can only increase the number of partitions of a topic; decreasing it fails. Increasing it changes the partition of keyed messages, which breaks the ordering of messages with the same key."
  type        = number
  nullable    = false

  validation {
    condition     = floor(var.partition_count) == var.partition_count
    error_message = "`partition_count` must be a whole number."
  }
  validation {
    condition     = var.partition_count >= 1
    error_message = "`partition_count` must be greater than or equal to `1`."
  }
}

variable "replication_factor" {
  description = "(Required) The number of replicas for each partition of the topic. It cannot be greater than the number of brokers in the cluster. Changing this value replaces the topic, which deletes all messages in the topic."
  type        = number
  nullable    = false

  validation {
    condition     = floor(var.replication_factor) == var.replication_factor
    error_message = "`replication_factor` must be a whole number."
  }
  validation {
    condition     = var.replication_factor >= 1
    error_message = "`replication_factor` must be greater than or equal to `1`."
  }
}

variable "configs" {
  description = "(Optional) A map of the topic-level Kafka configurations which override the cluster defaults. Each key is the name of the configuration, such as `retention.ms`, `cleanup.policy` and `min.insync.replicas`. Each value is the value of the configuration as a string. Removing a key from this map does not reset the configuration on the topic. Defaults to `{}`."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "timeouts" {
  description = <<EOF
  (Optional) How long to wait for the topic to be created, updated or deleted. `timeouts` as defined below.
    (Optional) `create` - Timeout for creating the topic. Defaults to `30m`.
    (Optional) `update` - Timeout for updating the topic. Defaults to `30m`.
    (Optional) `delete` - Timeout for deleting the topic. Defaults to `30m`.
  EOF
  type = object({
    create = optional(string, "30m")
    update = optional(string, "30m")
    delete = optional(string, "30m")
  })
  default  = {}
  nullable = false
}
