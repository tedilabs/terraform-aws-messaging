# sns-fifo-topic

This module creates following resources.

- `aws_sns_topic`
- `aws_sns_topic_policy` (optional)
- `aws_sns_topic_subscription` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.19.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the SNS topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the `.fifo` suffix. | `string` | n/a | yes |
| <a name="input_content_based_deduplication"></a> [content\_based\_deduplication](#input\_content\_based\_deduplication) | (Optional) Whether to enable default message deduplication based on message content. If set to `false`, a deduplication ID must be provided for every publish request. | `bool` | `false` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Optional) The display name to use for a topic with SMS subscriptions. | `string` | `""` | no |
| <a name="input_encryption_at_rest"></a> [encryption\_at\_rest](#input\_encryption\_at\_rest) | (Optional) A configuration to encrypt at rest in the SNS topic. Amazon SNS provides in-transit encryption by default. Enabling server-side encryption adds at-rest encryption to your topic. Amazon SNS encrypts your message as soon as it is received. The message is decrypted immediately prior to delivery. `encryption_at_rest` as defined below.<br>    (Optional) `enabled` - Whether to enable encryption at rest. Defaults to `false`.<br>    (Optional) `kms_key` - The ID of AWS KMS CMK (Customer Master Key) used for the encryption. | <pre>object({<br>    enabled = optional(bool, false)<br>    kms_key = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid policy JSON document. The resource-based policy defines who can publish or subscribe to the SNS topic. | `string` | `null` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_signature_version"></a> [signature\_version](#input\_signature\_version) | (Optional) The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS. Defaults to `1`. | `number` | `1` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#input\_xray\_tracing\_enabled) | (Optional) Whether to activate AWS X-Ray Active Tracing mode for the SNS topic. If set to Active, Amazon SNS will vend X-Ray segment data to topic owner account if the sampled flag in the tracing header is true. Defaults to `false`, and the topic passes through the tracing header it receives from an Amazon SNS publisher to its subscriptions. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the SNS topic. |
| <a name="output_content_based_deduplication"></a> [content\_based\_deduplication](#output\_content\_based\_deduplication) | Whether to enable default message deduplication based on message content. |
| <a name="output_display_name"></a> [display\_name](#output\_display\_name) | The display name for a topic with SMS subscriptions. |
| <a name="output_encryption_at_rest"></a> [encryption\_at\_rest](#output\_encryption\_at\_rest) | A configuration to encrypt at rest in the SNS topic. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the SNS topic. |
| <a name="output_name"></a> [name](#output\_name) | The name for the SNS topic. |
| <a name="output_owner"></a> [owner](#output\_owner) | The AWS Account ID of the SNS topic owner. |
| <a name="output_signature_version"></a> [signature\_version](#output\_signature\_version) | The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS. |
| <a name="output_type"></a> [type](#output\_type) | The type of the SNS topic. |
| <a name="output_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#output\_xray\_tracing\_enabled) | Whether to activate AWS X-Ray Active Tracing mode for the SNS topic. |
| <a name="output_z"></a> [z](#output\_z) | The list of log streams for the log group. |
| <a name="output_zz"></a> [zz](#output\_zz) | The list of log streams for the log group. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
