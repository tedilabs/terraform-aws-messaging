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

variable "policies" {
  description = <<EOF
  (Optional) A map of authorization policies for the SES identity. The authorization policy is a JSON document that you attach to an identity to specify what API actions you're allowing or denying for that identity, and under which conditions. Each key is the name of the policy, and the value is the policy document.
  EOF
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "dkim" {
  description = <<EOF
  (Optional) The configuration for the DKIM (DomainKeys Identified Mail). `dkim` as defined below.
    (Optional) `type` - Whether to use either Easy DKIM (`EASY_DKIM`) or Bring Your Own DKIM (`BYODKIM`), and depending on your choice, you'll have to configure the signing key length of the private key. Valid values are `EASY_DKIM` and `BYODKIM`. Defaults to `EASY_DKIM`.
    (Optional) `signing_key_type` - The key type of the future DKIM key pair to be generated. This can be changed at most once per day. The signing key length of the private key. Valid values are `RSA_1024` and `RSA_2048`. Defaults to `RSA_2048`. Only required if `type` is `EASY_DKIM`.
    (Optional) `private_key` - A private key that's used to generate a DKIM signature. The private key must use 1024 or 2048-bit RSA encryption, and must be encoded using base64 encoding. Only required if `type` is `BYODKIM`.
    (Optional) `selector_name` - A string that's used to identify a public key in the DNS configuration for a domain. Only required if `type` is `BYODKIM`.
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

variable "email_feedback_forwarding" {
  description = <<EOF
  (Optional) The configuration for Email Feedback Forwarding. `email_feedback_forwarding` as defined below.
    (Optional) `enabled` - Whether to enable email feedback forwarding. Amazon SES will automatically notify you by email when a bounce or a complaint event occurs. If you have another method in place, you can disable this feature to avoid receiving multiple notifications for the same event. Defaults to `true`.
  EOF
  type = object({
    enabled = optional(bool, true)
  })
  default  = {}
  nullable = false
}

variable "custom_mail_from" {
  description = <<EOF
  (Optional) The configuration for Custom Mail From. Configuring a custom MAIL FROM domain for messages sent from this identity enables the MAIL FROM address to align with the From address. Domain alignment must be achieved in order to be DMARC compliant. `custom_mail_from` as defined below.
    (Optional) `enabled` - Whether to enable custom mail from.
    (Optional) `domain` - The custom MAIL FROM domain that you want the verified identity to use. The MAIL FROM domain must meet the following criteria:
      - It has to be a subdomain of the verified identity.
      - It can't be used to receive email.
      - It can't be used in a "From" address if the MAIL FROM domain is a destination for feedback forwarding emails.
    (Optional) `behavior_on_mx_failure` - The action to take if the MAIL FROM domain is not found or not verified. Valid values are `REJECT_MESSAGE` and `USE_DEFAULT_VALUE`. Defaults to `REJECT_MESSAGE`.
  EOF
  type = object({
    enabled                = optional(bool, false)
    domain                 = optional(string, "")
    behavior_on_mx_failure = optional(string, "REJECT_MESSAGE")
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.custom_mail_from.enabled ? var.custom_mail_from.domain != "" : true
    error_message = "The value for `custom_mail_from.domain` must be provided if `custom_mail_from.enabled` is `true`."
  }
  validation {
    condition     = contains(["REJECT_MESSAGE", "USE_DEFAULT_VALUE"], var.custom_mail_from.behavior_on_mx_failure)
    error_message = "The value for `custom_mail_from.behavior_on_mx_failure` must be either `REJECT_MESSAGE` or `USE_DEFAULT_VALUE`."
  }
  validation {
    condition     = var.custom_mail_from.enabled ? strcontains(var.custom_mail_from.domain, var.name) : true
    error_message = "The value for `custom_mail_from.domain` must be a subdomain of the verified identity."
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
