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
