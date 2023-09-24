# sns-topic

This module creates following resources.

- `aws_sns_topic`
- `aws_sns_topic_data_protection_policy` (optional)
- `aws_sns_topic_policy` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.58 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.59.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_archive.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_archive) | resource |
| [aws_cloudwatch_event_bus.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_bus_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus_policy) | resource |
| [aws_schemas_discoverer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/schemas_discoverer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the new event bus. The name of custom event bus can't contain the `/` character, but you can use the `/` character in partner event bus names. You can't use the name `default` for a custom event bus, as this name is already used for your account's default event bus. | `string` | n/a | yes |
| <a name="input_archives"></a> [archives](#input\_archives) | (Required) The configuration to create archives for the event bus. Events are continuously saved in archives, and individual events will be deleted after the retention period. An archive will persist until you manually delete it. Each block of `archives` as defined below.<br>    (Required) `name` - The name of the new event archive. Maximum of 48 characters consisting of numbers, lower/upper case letters, `.`, `-`, `_`. You can't change the name of the archive after it is created.<br>    (Optional) `description` - The description of the new event archive.<br>    (Optional) `retention_in_days` - The maximum number of days to retain events in the new event archive. `0` is equivalent to Indefinite. The maximum is 2 billion days. Defaults to `0`.<br>    (Optional) `event_pattern` - An event pattern to use to filter events sent to the archive. | <pre>list(object({<br>    name              = string<br>    description       = optional(string, "Managed by Terraform.")<br>    retention_in_days = optional(number, 0)<br>    event_pattern     = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid policy JSON document. The resource-based policy defines who can access your event bus. By default, only the event bus owner can send events to the event bus. | `string` | `null` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_schema_discovery"></a> [schema\_discovery](#input\_schema\_discovery) | (Required) The configuration for schema discovery of the event bus. Enabling event discovery on an event bus will generate EventBridge Schemas for events on that bus. This may incur a cost (the first five million ingested events in each month is free). `schema_discovery` as defined below.<br>    (Optional) `enabled` - Whether to enable schema discovery. Defaults to `false`.<br>    (Optional) `description` - The description of the schema discoverer. Maximum of 256 characters. | <pre>object({<br>    enabled     = optional(bool, false)<br>    description = optional(string, "Managed by Terraform.")<br>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_archives"></a> [archives](#output\_archives) | A list of archives for the event bus. |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the event bus. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier for the event bus. |
| <a name="output_name"></a> [name](#output\_name) | The name of the event bus. |
| <a name="output_schema_discovery"></a> [schema\_discovery](#output\_schema\_discovery) | The configuration for schema discovery of the event bus. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
