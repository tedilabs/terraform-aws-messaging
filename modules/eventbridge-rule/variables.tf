variable "event_bus" {
  description = "(Optional) The name or ARN of the event bus to associate with this rule. If you omit this, the `default` event bus is used."
  type        = string
  default     = "default"
  nullable    = false
}

variable "name" {
  description = "(Required) A name of the rule for the event bus."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the rule."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "state" {
  description = <<EOF
  (Optional) The state of the rule. Valid values are `DISABLED`, `ENABLED`, and `ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS`. Defaults to `ENABLED`.
    `DISABLED` - The rule is disabled. EventBridge does not match any events against the rule.
    `ENABLED` - The rule is enabled. EventBridge matches events against the rule, except for Amazon Web Services management events delivered through CloudTrail.
    `ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS` - The rule is enabled for all events, including Amazon Web Services management events delivered through CloudTrail. Management events provide visibility into management operations that are performed on resources in your Amazon Web Services account. These are also known as control plane operations. This value is only valid for rules on the default event bus or custom event buses. It does not apply to partner event buses.
  EOF
  type        = string
  default     = "ENABLED"
  nullable    = false

  validation {
    condition     = contains(["DISABLED", "ENABLED", "ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS"], var.state)
    error_message = "Valid values for `state` are `DISABLED`, `ENABLED`, and `ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS`."
  }
}

variable "default_execution_role" {
  description = <<EOF
  (Optional) A configuration for the default execution role to use for the rule that is used for target invocation. Use `execution_role` if `default_execution_role.enabled` is `false`. `default_execution_role` as defined below.
    (Optional) `enabled` - Whether to create the default execution role. Defaults to `true`.
    (Optional) `name` - The name of the default execution role. Defaults to `aws-eventbridge-$${var.event_bus}-rule-$${var.name}`.
    (Optional) `path` - The path of the default execution role. Defaults to `/`.
    (Optional) `description` - The description of the default execution role.
    (Optional) `policies` - A list of IAM policy ARNs to attach to the default execution role. Defaults to `[]`.
    (Optional) `inline_policies` - A Map of inline IAM policies to attach to the default execution role. (`name` => `policy`).
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    path        = optional(string, "/")
    description = optional(string, "Managed by Terraform.")

    policies        = optional(list(string), [])
    inline_policies = optional(map(string), {})
  })
  default  = {}
  nullable = false
}

variable "execution_role" {
  description = <<EOF
  (Optional) The ARN (Amazon Resource Name) of the IAM role associated with the rule that is used for target invocation. Only required if `default_execution_role.enabled` is `false`.
  EOF
  type        = string
  default     = null
  nullable    = true
}

variable "trigger" {
  description = <<EOF
  (Required) The configuration for the rule trigger. At least one of `schedule_expression` or `event_pattern` is required. `trigger` as defined below.
    (Optional) `event_pattern` - The event pattern to trigger when an event matching the pattern occurs. This is described in a JSON object. The `event_pattern` size is 2048 by default but it is adjustable up to 4096 characters by submitting a service quota increase request.
    (Optional) `schedule_expression` - The scheduling expression. For example, `cron(0 20 * * ? *)` or `rate(5 minutes)`. Can only be used on the default event bus.
  EOF
  type = object({
    event_pattern       = optional(string)
    schedule_expression = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition = (var.trigger.event_pattern != null
      || var.trigger.schedule_expression != null
    )
    error_message = "At least one of `schedule_expression` or `event_pattern` is required."
  }
}

variable "event_bus_targets" {
  description = <<EOF
  (Optional) The configuration to manage the specified EventBridge event bus targets for the rule. Each item of `event_bus_targets` as defined below.
    (Required) `id` - The unique ID of the target within the specified rule. Use this ID to reference the target when updating the rule.
    (Required) `event_bus` - The Amazon Resource Name (ARN) of the target event bus.

    (Optional) `execution_role` - The ARN (Amazon Resource Name) of the IAM role to be used for this target when the rule is triggered. Only required if `default_execution_role.enabled` is `false`.

    (Optional) `dead_letter_queue` - The configuration for dead-letter queue of the rule target. Dead letter queues are used for collecting and storing events that were not successfully delivered to targets. `dead_letter_queue` as defined below.
      (Optional) `enabled` - Whether to enable the dead letter queue. Defaults to `false`.
      (Optional) `sqs_queue` - The Amazon Resource Name (ARN) of the SQS queue specified as the target for the dead letter queue.
  EOF
  type = list(object({
    id        = string
    event_bus = string

    execution_role = optional(string)

    dead_letter_queue = optional(object({
      enabled   = optional(bool, false)
      sqs_queue = optional(string)
    }), {})
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.event_bus_targets) <= 5
    error_message = "A maximum of 5 targets are allowed."
  }
  validation {
    condition = alltrue([
      for target in var.event_bus_targets :
      strcontains(target.event_bus, ":event-bus/")
    ])
    error_message = "The `event_bus` must be an ARN of the EventBridge event bus."
  }
}

# TODO: Support EventBridge API Destination targets
variable "api_destination_targets" {
  description = <<EOF
  (Optional) The configuration to manage the specified EventBridge API destination targets for the rule. Each item of `api_destination_targets` as defined below.
    (Required) `id` - The unique ID of the target within the specified rule. Use this ID to reference the target when updating the rule.
    (Required) `api_destination` - The Amazon Resource Name (ARN) of the target API destination.

    (Optional) `execution_role` - The ARN (Amazon Resource Name) of the IAM role to be used for this target when the rule is triggered. Only required if `default_execution_role.enabled` is `false`.

    (Optional) `dead_letter_queue` - The configuration for dead-letter queue of the rule target. Dead letter queues are used for collecting and storing events that were not successfully delivered to targets. `dead_letter_queue` as defined below.
      (Optional) `enabled` - Whether to enable the dead letter queue. Defaults to `false`.
      (Optional) `sqs_queue` - The Amazon Resource Name (ARN) of the SQS queue specified as the target for the dead letter queue.
    (Optional) `retry_policy` - The configuration for retry policy of the rule target. Retry policies are used for specifying how many times to retry sending an event to a target after an error occurs. `retry_policy` as defined below.
      (Optional) `maximum_event_age` - The maximum amount of time, in seconds, to continue to make retry attempts. Defaults to `86400` (1 hour).
      (Optional) `maximum_retry_attempts` - The maximum number of times to retry sending an event to a target after an error occurs. Defaults to `185`.
  EOF
  type = list(object({
    id              = string
    api_destination = string

    execution_role = optional(string)

    dead_letter_queue = optional(object({
      enabled   = optional(bool, false)
      sqs_queue = optional(string)
    }), {})
    retry_policy = optional(object({
      maximum_event_age      = optional(number, 86400)
      maximum_retry_attempts = optional(number, 185)
    }), {})
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.api_destination_targets) <= 5
    error_message = "A maximum of 5 targets are allowed."
  }
  validation {
    condition = alltrue([
      for target in var.api_destination_targets :
      strcontains(target.api_destination, ":api-destination/")
    ])
    error_message = "The `api_destination` must be an ARN of the EventBridge API destination."
  }
}

variable "aws_service_targets" {
  description = <<EOF
  (Optional) The configuration to manage the specified AWS service targets for the rule. Targets are the resources that are invoked when a rule is triggered. Each item of `aws_service_targets` as defined below.
    (Required) `id` - The unique ID of the target within the specified rule. Use this ID to reference the target when updating the rule.
    (Required) `target` - The Amazon Resource Name (ARN) of the target.

    (Optional) `execution_role` - The ARN (Amazon Resource Name) of the IAM role to be used for this target when the rule is triggered. Only required if `default_execution_role.enabled` is `false`.

    (Optional) `dead_letter_queue` - The configuration for dead-letter queue of the rule target. Dead letter queues are used for collecting and storing events that were not successfully delivered to targets. `dead_letter_queue` as defined below.
      (Optional) `enabled` - Whether to enable the dead letter queue. Defaults to `false`.
      (Optional) `sqs_queue` - The Amazon Resource Name (ARN) of the SQS queue specified as the target for the dead letter queue.
    (Optional) `retry_policy` - The configuration for retry policy of the rule target. Retry policies are used for specifying how many times to retry sending an event to a target after an error occurs. `retry_policy` as defined below.
      (Optional) `maximum_event_age` - The maximum amount of time, in seconds, to continue to make retry attempts. Defaults to `86400` (1 hour).
      (Optional) `maximum_retry_attempts` - The maximum number of times to retry sending an event to a target after an error occurs. Defaults to `185`.
  EOF
  type = list(object({
    id     = string
    target = string

    execution_role = optional(string)

    dead_letter_queue = optional(object({
      enabled   = optional(bool, false)
      sqs_queue = optional(string)
    }), {})
    retry_policy = optional(object({
      maximum_event_age      = optional(number, 86400)
      maximum_retry_attempts = optional(number, 185)
    }), {})
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(var.aws_service_targets) <= 5
    error_message = "A maximum of 5 targets are allowed."
  }
  validation {
    condition = alltrue([
      for target in var.aws_service_targets :
      alltrue([
        !strcontains(target.target, ":event-bus/"),
        !strcontains(target.target, ":api-destination/"),
      ])
    ])
    error_message = "The `target` must not be an ARN of the EventBridge event bus or API destination."
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

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
  nullable    = false
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}
