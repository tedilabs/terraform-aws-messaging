# msk-vpc-connection

This module creates following resources.

- `aws_msk_vpc_connection`
- `aws_security_group` (optional)
- `aws_security_group_rule` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.12 |
| <a name="requirement_telemetry"></a> [telemetry](#requirement\_telemetry) | >= 0.2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.12 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.13.0 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | tedilabs/network/aws//modules/security-group | ~> 1.4.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_msk_vpc_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_vpc_connection) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_authentication"></a> [authentication](#input\_authentication) | (Required) The authentication type of the clients which connect through the VPC connection. Valid values are `SASL_IAM`, `SASL_SCRAM` and `TLS`. Create one VPC connection for each authentication type that the clients use. Changing this value replaces the VPC connection. | `string` | n/a | yes |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | (Required) The ARN of the MSK cluster to connect to. The cluster must have multi-VPC private connectivity turned on for `authentication`, and a cluster policy which allows the account of the client VPC to create a VPC connection if the cluster is in another account. Changing this value replaces the VPC connection. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) A name to identify the VPC connection. Used for the `Name` tag of the VPC connection and the name of the default security group. It is not sent to Amazon MSK. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | (Required) A list of subnet IDs in the client VPC to place the endpoints of the VPC connection. Provide the same number of subnets as the broker subnets of the cluster, in the same Availability Zone IDs. The VPC of the first subnet is used as the client VPC. Changing this value replaces the VPC connection. | `list(string)` | n/a | yes |
| <a name="input_default_security_group"></a> [default\_security\_group](#input\_default\_security\_group) | (Optional) The configuration of the default security group for the VPC connection. `default_security_group` block as defined below.<br/>    (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.<br/>    (Optional) `name` - The name of the default security group. If not provided, `name` is used for the name of security group.<br/>    (Optional) `description` - The description of the default security group. Defaults to `Managed by Terraform.`.<br/>    (Optional) `ingress_rules` - A list of ingress rules in a security group. Defaults to `[]`. Each block of `ingress_rules` as defined below.<br/>      (Required) `id` - The ID of the ingress rule. This value is only used internally within Terraform code.<br/>      (Optional) `description` - The description of the rule. Defaults to `Managed by Terraform.`.<br/>      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.<br/>      (Required) `from_port` - The start of port range for the protocols.<br/>      (Required) `to_port` - The end of port range for the protocols.<br/>      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.<br/>      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.<br/>      (Optional) `prefix_lists` - The prefix list IDs to allow.<br/>      (Optional) `security_groups` - The source security group IDs to allow.<br/>      (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.<br/>    (Optional) `egress_rules` - A list of egress rules in a security group. Defaults to `[]`. Each block of `egress_rules` as defined below.<br/>      (Required) `id` - The ID of the egress rule. This value is only used internally within Terraform code.<br/>      (Optional) `description` - The description of the rule. Defaults to `Managed by Terraform.`.<br/>      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.<br/>      (Required) `from_port` - The start of port range for the protocols.<br/>      (Required) `to_port` - The end of port range for the protocols.<br/>      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.<br/>      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.<br/>      (Optional) `prefix_lists` - The prefix list IDs to allow.<br/>      (Optional) `security_groups` - The destination security group IDs to allow.<br/>      (Optional) `self` - Whether the security group itself will be added as a destination to this egress rule.<br/>    (Optional) `broker_ingress_ipv4_cidrs` - A list of IPv4 CIDR ranges to allow on the Kafka broker ports of the VPC connection (`14001`-`14100`). Defaults to `[]`.<br/>    (Optional) `broker_ingress_ipv6_cidrs` - A list of IPv6 CIDR ranges to allow on the Kafka broker ports of the VPC connection (`14001`-`14100`). Defaults to `[]`.<br/>    (Optional) `broker_ingress_prefix_lists` - A list of prefix list IDs to allow on the Kafka broker ports of the VPC connection (`14001`-`14100`). Defaults to `[]`.<br/>    (Optional) `broker_ingress_security_groups` - A list of security group IDs to allow on the Kafka broker ports of the VPC connection (`14001`-`14100`). Defaults to `[]`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string)<br/>    description = optional(string, "Managed by Terraform.")<br/>    ingress_rules = optional(<br/>      list(object({<br/>        id              = string<br/>        description     = optional(string, "Managed by Terraform.")<br/>        protocol        = string<br/>        from_port       = number<br/>        to_port         = number<br/>        ipv4_cidrs      = optional(list(string), [])<br/>        ipv6_cidrs      = optional(list(string), [])<br/>        prefix_lists    = optional(list(string), [])<br/>        security_groups = optional(list(string), [])<br/>        self            = optional(bool, false)<br/>      })),<br/>      []<br/>    )<br/>    egress_rules = optional(<br/>      list(object({<br/>        id              = string<br/>        description     = optional(string, "Managed by Terraform.")<br/>        protocol        = string<br/>        from_port       = number<br/>        to_port         = number<br/>        ipv4_cidrs      = optional(list(string), [])<br/>        ipv6_cidrs      = optional(list(string), [])<br/>        prefix_lists    = optional(list(string), [])<br/>        security_groups = optional(list(string), [])<br/>        self            = optional(bool, false)<br/>      })),<br/>      []<br/>    )<br/>    broker_ingress_ipv4_cidrs      = optional(list(string), [])<br/>    broker_ingress_ipv6_cidrs      = optional(list(string), [])<br/>    broker_ingress_prefix_lists    = optional(list(string), [])<br/>    broker_ingress_security_groups = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | (Optional) A list of security group IDs to associate with the endpoints of the VPC connection, in addition to the default security group. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_telemetry"></a> [telemetry](#input\_telemetry) | (Optional) A configuration to collect telemetry data for the module. This is used to improve the module and its features. To send pseudonyms instead of identifying values such as the hostname and the Git remote, set `pseudonymization_enabled` to `true`. Pseudonyms are not anonymous; to keep data from being sent, disable its collector. The default configuration enables telemetry collection for machine, network, git, github, github actions, HCP Terraform, terraform, and toolchain. You can disable telemetry collection by setting `enabled` to `false`. `telemetry` block as defined below.<br/>    (Optional) `enabled` - Whether to enable telemetry collection. Default is `true`.<br/>    (Optional) `capture_machine` - Whether to capture machine information. Default is `true`.<br/>    (Optional) `capture_network` - Whether to capture network information. Default is `true`.<br/>    (Optional) `capture_git` - Whether to capture git information. Default is `true`.<br/>    (Optional) `capture_github` - Whether to capture GitHub information. Default is `true`.<br/>    (Optional) `capture_github_actions` - Whether to capture GitHub Actions information. Default is `true`.<br/>    (Optional) `capture_hcp_terraform` - Whether to capture HCP Terraform information. Default is `true`.<br/>    (Optional) `capture_terraform` - Whether to capture Terraform information. Default is `true`.<br/>    (Optional) `capture_toolchain` - Whether to capture toolchain information. Default is `true`.<br/>    (Optional) `pseudonymization_enabled` - Whether to enable pseudonymization of the captured data. Default is `false`. | <pre>object({<br/>    enabled = optional(bool, true)<br/><br/>    capture_machine        = optional(bool, true)<br/>    capture_network        = optional(bool, true)<br/>    capture_git            = optional(bool, true)<br/>    capture_github         = optional(bool, true)<br/>    capture_github_actions = optional(bool, true)<br/>    capture_hcp_terraform  = optional(bool, true)<br/>    capture_terraform      = optional(bool, true)<br/>    capture_toolchain      = optional(bool, true)<br/><br/>    pseudonymization_enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the VPC connection. |
| <a name="output_authentication"></a> [authentication](#output\_authentication) | The authentication type of the clients which connect through the VPC connection. |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | The ARN of the MSK cluster which the VPC connection connects to. |
| <a name="output_default_security_group"></a> [default\_security\_group](#output\_default\_security\_group) | The default security group of the VPC connection. `null` if `default_security_group.enabled` is `false`. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the VPC connection. |
| <a name="output_name"></a> [name](#output\_name) | The name to identify the VPC connection. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | A list of security group IDs which are associated with the endpoints of the VPC connection. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | A list of subnet IDs in the client VPC where the endpoints of the VPC connection are placed. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the client VPC of the VPC connection. |
<!-- END_TF_DOCS -->
