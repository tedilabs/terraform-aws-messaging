variable "name" {
  description = "(Required) The name of the new event bus. The name of custom event bus can't contain the `/` character, but you can use the `/` character in partner event bus names. You can't use the name `default` for a custom event bus, as this name is already used for your account's default event bus."
  type        = string
  nullable    = false
}

variable "policy" {
  description = "(Optional) A valid policy JSON document. The resource-based policy defines who can access your event bus. By default, only the event bus owner can send events to the event bus."
  type        = string
  default     = null
}

variable "archives" {
  description = <<EOF
  (Required) The configuration to create archives for the event bus. Events are continuously saved in archives, and individual events will be deleted after the retention period. An archive will persist until you manually delete it. Each block of `archives` as defined below.
    (Required) `name` - The name of the new event archive. Maximum of 48 characters consisting of numbers, lower/upper case letters, `.`, `-`, `_`. You can't change the name of the archive after it is created.
    (Optional) `description` - The description of the new event archive.
    (Optional) `retention_in_days` - The maximum number of days to retain events in the new event archive. `0` is equivalent to Indefinite. The maximum is 2 billion days. Defaults to `0`.
    (Optional) `event_pattern` - An event pattern to use to filter events sent to the archive.
  EOF
  type = list(object({
    name              = string
    description       = optional(string, "Managed by Terraform.")
    retention_in_days = optional(number, 0)
    event_pattern     = optional(string)
  }))
  default  = []
  nullable = false
}

variable "schema_discovery" {
  description = <<EOF
  (Required) The configuration for schema discovery of the event bus. Enabling event discovery on an event bus will generate EventBridge Schemas for events on that bus. This may incur a cost (the first five million ingested events in each month is free). `schema_discovery` as defined below.
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
