variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the SNS topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the `.fifo` suffix."
  type        = string
  nullable    = false

  validation {
    condition     = endswith(var.name, ".fifo")
    error_message = "The name must end with the `.fifo` suffix."
  }
}

variable "display_name" {
  description = "(Optional) The display name to use for a topic with SMS subscriptions."
  type        = string
  default     = ""
  nullable    = false
}

variable "content_based_deduplication" {
  description = "(Optional) Whether to enable default message deduplication based on message content. If set to `false`, a deduplication ID must be provided for every publish request."
  type        = bool
  default     = false
  nullable    = false
}

variable "throughput_scope" {
  description = <<EOF
  (Optional) The throughput scope of the FIFO topic. Valid values are `TOPIC` and `MESSAGE_GROUP`. Defaults to `TOPIC`.
    `TOPIC` - The throughput quota of the FIFO topic applies to the entire topic.
    `MESSAGE_GROUP` - The throughput quota of the FIFO topic applies to each message group individually, so the topic can scale beyond the topic-level quota by spreading messages across message groups.
  EOF
  type        = string
  default     = "TOPIC"
  nullable    = false

  validation {
    condition     = contains(["TOPIC", "MESSAGE_GROUP"], var.throughput_scope)
    error_message = "Valid values for `throughput_scope` are `TOPIC` and `MESSAGE_GROUP`."
  }
}

variable "message_archiving" {
  description = <<EOF
  (Optional) A configuration for message archiving of the FIFO topic. Amazon SNS stores the messages published to the topic in an archive, so that subscribers can replay them later. `message_archiving` as defined below.
    (Optional) `enabled` - Whether to enable message archiving. Defaults to `false`.
    (Optional) `retention_in_days` - The number of days to retain messages in the archive. Valid value is between `1` and `365`. Defaults to `30`.
  EOF
  type = object({
    enabled           = optional(bool, false)
    retention_in_days = optional(number, 30)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.message_archiving.retention_in_days >= 1,
      var.message_archiving.retention_in_days <= 365,
    ])
    error_message = "Valid value for `message_archiving.retention_in_days` is between `1` and `365`."
  }
}

variable "policy" {
  description = "(Optional) A valid policy JSON document. The resource-based policy defines who can publish or subscribe to the SNS topic."
  type        = string
  default     = null
}

variable "xray_tracing_enabled" {
  description = "(Optional) Whether to activate AWS X-Ray Active Tracing mode for the SNS topic. If set to Active, Amazon SNS will vend X-Ray segment data to topic owner account if the sampled flag in the tracing header is true. Defaults to `false`, and the topic passes through the tracing header it receives from an Amazon SNS publisher to its subscriptions."
  type        = bool
  default     = false
  nullable    = false
}

variable "signature_version" {
  description = "(Optional) The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS. Defaults to `1`."
  type        = number
  default     = 1
  nullable    = false
}

variable "encryption_at_rest" {
  description = <<EOF
  (Optional) A configuration to encrypt at rest in the SNS topic. Amazon SNS provides in-transit encryption by default. Enabling server-side encryption adds at-rest encryption to your topic. Amazon SNS encrypts your message as soon as it is received. The message is decrypted immediately prior to delivery. `encryption_at_rest` as defined below.
    (Optional) `enabled` - Whether to enable encryption at rest. Defaults to `false`.
    (Optional) `kms_key` - The ID of AWS KMS CMK (Customer Master Key) used for the encryption.
  EOF
  type = object({
    enabled = optional(bool, false)
    kms_key = optional(string)
  })
  default  = {}
  nullable = false
}

variable "delivery_status_logging" {
  description = <<EOF
  (Optional) A configuration for the delivery status logging of the SNS topic. Amazon SNS logs the delivery status of notification messages sent to the endpoints of the supported types to CloudWatch Logs. Each key of `delivery_status_logging` is an endpoint type as defined below.
    (Optional) `application` - The configuration for the delivery status logging of the platform application endpoints.
    (Optional) `firehose` - The configuration for the delivery status logging of the Amazon Data Firehose endpoints.
    (Optional) `http` - The configuration for the delivery status logging of the HTTP/S endpoints.
    (Optional) `lambda` - The configuration for the delivery status logging of the Lambda function endpoints.
    (Optional) `sqs` - The configuration for the delivery status logging of the SQS queue endpoints.
  Each value of `delivery_status_logging` as defined below.
    (Optional) `enabled` - Whether to enable the delivery status logging for the endpoint type. Defaults to `false`.
    (Optional) `success_feedback_role` - The ARN of the IAM role permitted to receive success feedback for the endpoint type. At least one of `success_feedback_role` or `failure_feedback_role` is required if `enabled` is `true`.
    (Optional) `success_feedback_sample_rate` - The percentage of successful deliveries to log. Valid value is between `0` and `100`. Defaults to `100`.
    (Optional) `failure_feedback_role` - The ARN of the IAM role permitted to receive failure feedback for the endpoint type. At least one of `success_feedback_role` or `failure_feedback_role` is required if `enabled` is `true`.
  EOF
  type = object({
    application = optional(object({
      enabled                      = optional(bool, false)
      success_feedback_role        = optional(string)
      success_feedback_sample_rate = optional(number, 100)
      failure_feedback_role        = optional(string)
    }), {})
    firehose = optional(object({
      enabled                      = optional(bool, false)
      success_feedback_role        = optional(string)
      success_feedback_sample_rate = optional(number, 100)
      failure_feedback_role        = optional(string)
    }), {})
    http = optional(object({
      enabled                      = optional(bool, false)
      success_feedback_role        = optional(string)
      success_feedback_sample_rate = optional(number, 100)
      failure_feedback_role        = optional(string)
    }), {})
    lambda = optional(object({
      enabled                      = optional(bool, false)
      success_feedback_role        = optional(string)
      success_feedback_sample_rate = optional(number, 100)
      failure_feedback_role        = optional(string)
    }), {})
    sqs = optional(object({
      enabled                      = optional(bool, false)
      success_feedback_role        = optional(string)
      success_feedback_sample_rate = optional(number, 100)
      failure_feedback_role        = optional(string)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for type, config in var.delivery_status_logging :
      config.success_feedback_role != null || config.failure_feedback_role != null
      if config.enabled
    ])
    error_message = "At least one of `success_feedback_role` or `failure_feedback_role` is required for each enabled endpoint type of `delivery_status_logging`."
  }
  validation {
    condition = alltrue([
      for type, config in var.delivery_status_logging :
      config.success_feedback_sample_rate >= 0 && config.success_feedback_sample_rate <= 100
    ])
    error_message = "Valid value for `success_feedback_sample_rate` of each endpoint type of `delivery_status_logging` is between `0` and `100`."
  }
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
