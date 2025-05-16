variable "name" {
  description = "(Required) The domain name of the SES domain identity."
  type        = string
  nullable    = false
}

variable "configuration_set" {
  description = <<EOF
  (Optional) The configuration set to use by default when sending from this identity. Note that any configuration set defined in the email sending request takes precedence.
  EOF
  type        = string
  default     = null
  nullable    = true
}

variable "dkim" {
  description = <<EOF
  (Optional) The configuration for the DKIM (DomainKeys Identified Mail). `dkim` as defined below.
    (Optional) `type` - Whether to use either Easy DKIM (`EASY_DKIM`) or Bring Your Own DKIM (`BYODKIM`), and depending on your choice, you'll have to configure the signing key length of the private key. Valid values are `EASY_DKIM` and `BYODKIM`. Defaults to `EASY_DKIM`.
    (Optional) `signing_key_type` - The key type of the future DKIM key pair to be generated. This can be changed at most once per day. The signing key length of the private key. Valid values are `RSA_1024` and `RSA_2048`. Defaults to `RSA_2048`. Only required if `type` is `EASY_DKIM`.
    (Optional) `private_key` - A private key that's used to generate a DKIM signature. The private key must use 1024 or 2048-bit RSA encryption, and must be encoded using base64 encoding. Only required if `type` is `BYODKIM`.
    (Optional) `selector_name` - A string that's used to identify a public key in the DNS configuration for a domain. Only required if `type` is `BYODKIM`.
    (Optional) `verification` - A configuration for the DKIM verification. `verification` as defined below.
      (Optional) `enabled` - Whether to process DKIM verification by creating the necessary domain records in the module. Defaults to `false`.
      (Optional) `zone_id` - The ID of Hosted Zone to automatically manage the records for DKIM verification.
  EOF
  type = object({
    type             = optional(string, "EASY_DKIM")
    signing_key_type = optional(string, "RSA_2048")
    private_key      = optional(string)
    selector_name    = optional(string)
    verification = optional(object({
      enabled = optional(bool, false)
      zone_id = optional(string)
    }))
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["EASY_DKIM", "BYODKIM"], var.dkim.type)
    error_message = "The value for `dkim.type` must be either `EASY_DKIM` or `BYODKIM`."
  }
  validation {
    condition     = contains(["RSA_1024", "RSA_2048"], var.dkim.signing_key_type)
    error_message = "The value for `dkim.signing_key_type` must be either `RSA_1024` or `RSA_2048`."
  }
  validation {
    condition     = var.dkim.type == "BYODKIM" ? var.dkim.private_key != null : true
    error_message = "The value for `dkim.private_key` must be provided if `dkim.type` is `BYODKIM`."
  }
  validation {
    condition     = var.dkim.type == "BYODKIM" ? var.dkim.selector_name != null : true
    error_message = "The value for `dkim.selector_name` must be provided if `dkim.type` is `BYODKIM`."
  }
}

# variable "display_name" {
#   description = "(Optional) The display name to use for a topic with SMS subscriptions."
#   type        = string
#   default     = ""
#   nullable    = false
# }

# variable "display_name" {
#   description = "(Optional) The display name to use for a topic with SMS subscriptions."
#   type        = string
#   default     = ""
#   nullable    = false
# }

# variable "content_based_deduplication" {
#   description = "(Optional) Whether to enable default message deduplication based on message content. If set to `false`, a deduplication ID must be provided for every publish request."
#   type        = bool
#   default     = false
#   nullable    = false
# }

# variable "policy" {
#   description = "(Optional) A valid policy JSON document. The resource-based policy defines who can publish or subscribe to the SNS topic."
#   type        = string
#   default     = null
# }

# variable "xray_tracing_enabled" {
#   description = "(Optional) Whether to activate AWS X-Ray Active Tracing mode for the SNS topic. If set to Active, Amazon SNS will vend X-Ray segment data to topic owner account if the sampled flag in the tracing header is true. Defaults to `false`, and the topic passes through the tracing header it receives from an Amazon SNS publisher to its subscriptions."
#   type        = bool
#   default     = false
#   nullable    = false
# }

# variable "signature_version" {
#   description = "(Optional) The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS. Defaults to `1`."
#   type        = number
#   default     = 1
#   nullable    = false
# }

# variable "encryption_at_rest" {
#   description = <<EOF
#   (Optional) A configuration to encrypt at rest in the SNS topic. Amazon SNS provides in-transit encryption by default. Enabling server-side encryption adds at-rest encryption to your topic. Amazon SNS encrypts your message as soon as it is received. The message is decrypted immediately prior to delivery. `encryption_at_rest` as defined below.
#     (Optional) `enabled` - Whether to enable encryption at rest. Defaults to `false`.
#     (Optional) `kms_key` - The ID of AWS KMS CMK (Customer Master Key) used for the encryption.
#   EOF
#   type = object({
#     enabled = optional(bool, false)
#     kms_key = optional(string)
#   })
#   default  = {}
#   nullable = false
# }

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
