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
