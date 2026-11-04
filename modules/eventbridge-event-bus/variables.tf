variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Optional) The name of the new event bus. The name of custom event bus can't contain the `/` character, but you can use the `/` character in partner event bus names. You can't use the name `default` for a custom event bus, as this name is already used for your account's default event bus. If the value is `default`, it will load the `default` event bus that already exists instead of creating a new one. Defaults to `default`."
  type        = string
  default     = "default"
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the event bus. Only applied to a custom event bus."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "policy" {
  description = "(Optional) A valid policy JSON document. The resource-based policy defines who can access your event bus. By default, only the event bus owner can send events to the event bus."
  type        = string
  default     = null
}

variable "encryption_at_rest" {
  description = <<EOF
  (Optional) A configuration to encrypt events at rest in the event bus. EventBridge encrypts events at rest with an AWS owned key by default. `encryption_at_rest` as defined below. Only applied to a custom event bus.
    (Optional) `kms_key` - The identifier of the customer managed KMS key to encrypt events at rest. Valid values are the key ID, key ARN, alias name or alias ARN. If not provided, an AWS owned key is used.
  EOF
  type = object({
    kms_key = optional(string)
  })
  default  = {}
  nullable = false
}

variable "dead_letter_queue" {
  description = <<EOF
  (Optional) A configuration for the dead-letter queue of the event bus. Events that could not be delivered are sent to the dead-letter queue. `dead_letter_queue` as defined below. Only applied to a custom event bus.
    (Optional) `enabled` - Whether to enable the dead-letter queue. Defaults to `false`.
    (Optional) `sqs_queue` - The ARN of the SQS queue specified as the target for the dead-letter queue. Required if `enabled` is `true`.
  EOF
  type = object({
    enabled   = optional(bool, false)
    sqs_queue = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition     = !var.dead_letter_queue.enabled || var.dead_letter_queue.sqs_queue != null
    error_message = "`dead_letter_queue.sqs_queue` is required if `dead_letter_queue.enabled` is `true`."
  }
}

variable "logging" {
  description = <<EOF
  (Optional) A configuration for logging of the event bus. EventBridge generates a log record for each event lifecycle step and delivers it to CloudWatch Logs, S3 or Amazon Data Firehose through the CloudWatch Logs delivery configured separately. `logging` as defined below. Only applied to a custom event bus.
    (Optional) `level` - The level of logging detail to include. Valid values are `OFF`, `ERROR`, `INFO` and `TRACE`. Defaults to `OFF`.
      `OFF` - Logging is disabled.
      `ERROR` - Log only the errors that occur during event processing.
      `INFO` - Log the errors and the key steps of event processing.
      `TRACE` - Log the errors and every step of event processing, including the details of the calls to the targets.
    (Optional) `include_detail_enabled` - Whether to include the event detail (the event payloads, the input transformer outputs, the target responses) in the log records. Defaults to `false`.
  EOF
  type = object({
    level                  = optional(string, "OFF")
    include_detail_enabled = optional(bool, false)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["OFF", "ERROR", "INFO", "TRACE"], var.logging.level)
    error_message = "Valid values for `logging.level` are `OFF`, `ERROR`, `INFO` and `TRACE`."
  }
}

variable "archives" {
  description = <<EOF
  (Optional) The configuration to create archives for the event bus. Events are continuously saved in archives, and individual events will be deleted after the retention period. An archive will persist until you manually delete it. Each block of `archives` as defined below.
    (Required) `name` - The name of the new event archive. Maximum of 48 characters consisting of numbers, lower/upper case letters, `.`, `-`, `_`. You can't change the name of the archive after it is created.
    (Optional) `description` - The description of the new event archive.
    (Optional) `retention_in_days` - The maximum number of days to retain events in the new event archive. `0` is equivalent to Indefinite. The maximum is 2 billion days. Defaults to `0`.
    (Optional) `event_pattern` - An event pattern to use to filter events sent to the archive. All events from the source will be archived when `event_pattern` is not provided.
    (Optional) `kms_key` - The identifier of the customer managed KMS key to encrypt the archived events at rest. Valid values are the key ID, key ARN, alias name or alias ARN. If not provided, an AWS owned key is used.
  EOF
  type = list(object({
    name              = string
    description       = optional(string, "Managed by Terraform.")
    retention_in_days = optional(number, 0)
    event_pattern     = optional(string)
    kms_key           = optional(string)
  }))
  default  = []
  nullable = false
}

variable "schema_discovery" {
  description = <<EOF
  (Optional) The configuration for schema discovery of the event bus. Enabling event discovery on an event bus will generate EventBridge Schemas for events on that bus. This may incur a cost (the first five million ingested events in each month is free). `schema_discovery` as defined below.
    (Optional) `enabled` - Whether to enable schema discovery. Defaults to `false`.
    (Optional) `description` - The description of the schema discoverer. Maximum of 256 characters.
  EOF
  type = object({
    enabled     = optional(bool, false)
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
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
