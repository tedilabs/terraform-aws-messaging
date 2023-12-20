# eventbridge-rule

This module creates following resources.

- `aws_cloudwatch_event_rule`
- `aws_cloudwatch_event_target` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) A name of the rule for the event bus. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the rule. | `string` | `"Managed by Terraform."` | no |
| <a name="input_event_bus"></a> [event\_bus](#input\_event\_bus) | (Optional) The name or ARN of the event bus to associate with this rule. If you omit this, the `default` event bus is used. | `string` | `"default"` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_state"></a> [state](#input\_state) | (Optional) The state of the rule. Valid values are `DISABLED`, `ENABLED`, and `ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS`. Defaults to `ENABLED`.<br>    `DISABLED` - The rule is disabled. EventBridge does not match any events against the rule.<br>    `ENABLED` - The rule is enabled. EventBridge matches events against the rule, except for Amazon Web Services management events delivered through CloudTrail.<br>    `ENABLED_WITH_ALL_CLOUDTRAIL_MANAGEMENT_EVENTS` - The rule is enabled for all events, including Amazon Web Services management events delivered through CloudTrail. Management events provide visibility into management operations that are performed on resources in your Amazon Web Services account. These are also known as control plane operations. This value is only valid for rules on the default event bus or custom event buses. It does not apply to partner event buses. | `string` | `"ENABLED"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_trigger"></a> [trigger](#input\_trigger) | (Required) The configuration for the rule trigger. At least one of `schedule_expression` or `event_pattern` is required. `trigger` as defined below.<br>    (Optional) `event_pattern` - The event pattern to trigger when an event matching the pattern occurs. This is described in a JSON object. The `event_pattern` size is 2048 by default but it is adjustable up to 4096 characters by submitting a service quota increase request.<br>    (Optional) `schedule_expression` - The scheduling expression. For example, `cron(0 20 * * ? *)` or `rate(5 minutes)`. Can only be used on the default event bus. | <pre>object({<br>    event_pattern       = optional(string)<br>    schedule_expression = optional(string)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the rule. |
| <a name="output_description"></a> [description](#output\_description) | The description of the rule. |
| <a name="output_event_bus"></a> [event\_bus](#output\_event\_bus) | The name of the event bus. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier for the rule. |
| <a name="output_name"></a> [name](#output\_name) | The name of the rule. |
| <a name="output_state"></a> [state](#output\_state) | The state of the rule. |
| <a name="output_targets"></a> [targets](#output\_targets) | A list of archives for the event bus. |
| <a name="output_trigger"></a> [trigger](#output\_trigger) | The configuration for the rule trriger. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
