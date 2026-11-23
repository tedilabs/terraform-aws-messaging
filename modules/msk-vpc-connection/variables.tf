variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) A name to identify the VPC connection. Used for the `Name` tag of the VPC connection and the name of the default security group. It is not sent to Amazon MSK."
  type        = string
  nullable    = false
}

variable "cluster" {
  description = "(Required) The ARN of the MSK cluster to connect to. The cluster must have multi-VPC private connectivity turned on for `authentication`, and a cluster policy which allows the account of the client VPC to create a VPC connection if the cluster is in another account. Changing this value replaces the VPC connection."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^arn:aws[a-z-]*:kafka:[a-z0-9-]+:[0-9]{12}:cluster/[^/]+/.+$", var.cluster))
    error_message = "`cluster` must be the ARN of an MSK cluster."
  }
}

variable "authentication" {
  description = "(Required) The authentication type of the clients which connect through the VPC connection. Valid values are `SASL_IAM`, `SASL_SCRAM` and `TLS`. Create one VPC connection for each authentication type that the clients use. Changing this value replaces the VPC connection."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["SASL_IAM", "SASL_SCRAM", "TLS"], var.authentication)
    error_message = "Valid values for `authentication` are `SASL_IAM`, `SASL_SCRAM` and `TLS`."
  }
}

variable "subnets" {
  description = "(Required) A list of subnet IDs in the client VPC to place the endpoints of the VPC connection. Provide the same number of subnets as the broker subnets of the cluster, in the same Availability Zone IDs. The VPC of the first subnet is used as the client VPC. Changing this value replaces the VPC connection."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.subnets) > 0
    error_message = "`subnets` requires at least one subnet."
  }
}

variable "default_security_group" {
  description = <<EOF
  (Optional) The configuration of the default security group for the VPC connection. `default_security_group` block as defined below.
    (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.
    (Optional) `name` - The name of the default security group. If not provided, `name` is used for the name of security group.
    (Optional) `description` - The description of the default security group. Defaults to `Managed by Terraform.`.
    (Optional) `ingress_rules` - A list of ingress rules in a security group. Defaults to `[]`. Each block of `ingress_rules` as defined below.
      (Required) `id` - The ID of the ingress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule. Defaults to `Managed by Terraform.`.
      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
      (Required) `from_port` - The start of port range for the protocols.
      (Required) `to_port` - The end of port range for the protocols.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The source security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
    (Optional) `egress_rules` - A list of egress rules in a security group. Defaults to `[]`. Each block of `egress_rules` as defined below.
      (Required) `id` - The ID of the egress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule. Defaults to `Managed by Terraform.`.
      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
      (Required) `from_port` - The start of port range for the protocols.
      (Required) `to_port` - The end of port range for the protocols.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The destination security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a destination to this egress rule.
    (Optional) `broker_ingress_ipv4_cidrs` - A list of IPv4 CIDR ranges to allow on the Kafka broker ports of the VPC connection (`14001`-`14100`). Defaults to `[]`.
    (Optional) `broker_ingress_ipv6_cidrs` - A list of IPv6 CIDR ranges to allow on the Kafka broker ports of the VPC connection (`14001`-`14100`). Defaults to `[]`.
    (Optional) `broker_ingress_prefix_lists` - A list of prefix list IDs to allow on the Kafka broker ports of the VPC connection (`14001`-`14100`). Defaults to `[]`.
    (Optional) `broker_ingress_security_groups` - A list of security group IDs to allow on the Kafka broker ports of the VPC connection (`14001`-`14100`). Defaults to `[]`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    description = optional(string, "Managed by Terraform.")
    ingress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      []
    )
    egress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      []
    )
    broker_ingress_ipv4_cidrs      = optional(list(string), [])
    broker_ingress_ipv6_cidrs      = optional(list(string), [])
    broker_ingress_prefix_lists    = optional(list(string), [])
    broker_ingress_security_groups = optional(list(string), [])
  })
  default  = {}
  nullable = false
}

variable "security_groups" {
  description = "(Optional) A list of security group IDs to associate with the endpoints of the VPC connection, in addition to the default security group."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module information."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group" {
  description = <<EOF
  (Optional) A configuration of Resource Group for this module. `resource_group` as defined below.
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
