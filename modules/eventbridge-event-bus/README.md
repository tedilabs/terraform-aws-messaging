# eventbridge-event-bus

This module creates following resources.

- `aws_cloudwatch_event_bus` (optional)
- `aws_cloudwatch_event_bus_policy` (optional)
- `aws_cloudwatch_event_archive` (optional)
- `aws_schemas_discoverer` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.12 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.12 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_event_archive.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_archive) | resource |
| [aws_cloudwatch_event_bus.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_bus_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus_policy) | resource |
| [aws_schemas_discoverer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/schemas_discoverer) | resource |
| [aws_cloudwatch_event_bus.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_event_bus) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_archives"></a> [archives](#input\_archives) | (Optional) The configuration to create archives for the event bus. Events are continuously saved in archives, and individual events will be deleted after the retention period. An archive will persist until you manually delete it. Each block of `archives` as defined below.<br/>    (Required) `name` - The name of the new event archive. Maximum of 48 characters consisting of numbers, lower/upper case letters, `.`, `-`, `_`. You can't change the name of the archive after it is created.<br/>    (Optional) `description` - The description of the new event archive.<br/>    (Optional) `retention_in_days` - The maximum number of days to retain events in the new event archive. `0` is equivalent to Indefinite. The maximum is 2 billion days. Defaults to `0`.<br/>    (Optional) `event_pattern` - An event pattern to use to filter events sent to the archive. All events from the source will be archived when `event_pattern` is not provided.<br/>    (Optional) `kms_key` - The identifier of the customer managed KMS key to encrypt the archived events at rest. Valid values are the key ID, key ARN, alias name or alias ARN. If not provided, an AWS owned key is used. | <pre>list(object({<br/>    name              = string<br/>    description       = optional(string, "Managed by Terraform.")<br/>    retention_in_days = optional(number, 0)<br/>    event_pattern     = optional(string)<br/>    kms_key           = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_dead_letter_queue"></a> [dead\_letter\_queue](#input\_dead\_letter\_queue) | (Optional) A configuration for the dead-letter queue of the event bus. Events that could not be delivered are sent to the dead-letter queue. `dead_letter_queue` as defined below. Only applied to a custom event bus.<br/>    (Optional) `enabled` - Whether to enable the dead-letter queue. Defaults to `false`.<br/>    (Optional) `sqs_queue` - The ARN of the SQS queue specified as the target for the dead-letter queue. Required if `enabled` is `true`. | <pre>object({<br/>    enabled   = optional(bool, false)<br/>    sqs_queue = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the event bus. Only applied to a custom event bus. | `string` | `"Managed by Terraform."` | no |
| <a name="input_encryption_at_rest"></a> [encryption\_at\_rest](#input\_encryption\_at\_rest) | (Optional) A configuration to encrypt events at rest in the event bus. EventBridge encrypts events at rest with an AWS owned key by default. `encryption_at_rest` as defined below. Only applied to a custom event bus.<br/>    (Optional) `kms_key` - The identifier of the customer managed KMS key to encrypt events at rest. Valid values are the key ID, key ARN, alias name or alias ARN. If not provided, an AWS owned key is used. | <pre>object({<br/>    kms_key = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | (Optional) A configuration for logging of the event bus. EventBridge generates a log record for each event lifecycle step and delivers it to CloudWatch Logs, S3 or Amazon Data Firehose through the CloudWatch Logs delivery configured separately. `logging` as defined below. Only applied to a custom event bus.<br/>    (Optional) `level` - The level of logging detail to include. Valid values are `OFF`, `ERROR`, `INFO` and `TRACE`. Defaults to `OFF`.<br/>      `OFF` - Logging is disabled.<br/>      `ERROR` - Log only the errors that occur during event processing.<br/>      `INFO` - Log the errors and the key steps of event processing.<br/>      `TRACE` - Log the errors and every step of event processing, including the details of the calls to the targets.<br/>    (Optional) `include_detail_enabled` - Whether to include the event detail (the event payloads, the input transformer outputs, the target responses) in the log records. Defaults to `false`. | <pre>object({<br/>    level                  = optional(string, "OFF")<br/>    include_detail_enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional) The name of the new event bus. The name of custom event bus can't contain the `/` character, but you can use the `/` character in partner event bus names. You can't use the name `default` for a custom event bus, as this name is already used for your account's default event bus. If the value is `default`, it will load the `default` event bus that already exists instead of creating a new one. Defaults to `default`. | `string` | `"default"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid policy JSON document. The resource-based policy defines who can access your event bus. By default, only the event bus owner can send events to the event bus. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_schema_discovery"></a> [schema\_discovery](#input\_schema\_discovery) | (Optional) The configuration for schema discovery of the event bus. Enabling event discovery on an event bus will generate EventBridge Schemas for events on that bus. This may incur a cost (the first five million ingested events in each month is free). `schema_discovery` as defined below.<br/>    (Optional) `enabled` - Whether to enable schema discovery. Defaults to `false`.<br/>    (Optional) `description` - The description of the schema discoverer. Maximum of 256 characters. | <pre>object({<br/>    enabled     = optional(bool, false)<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_archives"></a> [archives](#output\_archives) | A list of archives for the event bus. |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the event bus. |
| <a name="output_dead_letter_queue"></a> [dead\_letter\_queue](#output\_dead\_letter\_queue) | The configuration for the dead-letter queue of the event bus. |
| <a name="output_description"></a> [description](#output\_description) | The description of the event bus. |
| <a name="output_encryption_at_rest"></a> [encryption\_at\_rest](#output\_encryption\_at\_rest) | The configuration to encrypt events at rest in the event bus. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier for the event bus. |
| <a name="output_logging"></a> [logging](#output\_logging) | The configuration for logging of the event bus. |
| <a name="output_name"></a> [name](#output\_name) | The name of the event bus. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_schema_discovery"></a> [schema\_discovery](#output\_schema\_discovery) | The configuration for schema discovery of the event bus. |
<!-- END_TF_DOCS -->
