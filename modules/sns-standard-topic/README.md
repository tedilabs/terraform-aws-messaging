# sns-standard-topic

This module creates following resources.

- `aws_sns_topic`
- `aws_sns_topic_data_protection_policy` (optional)
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
| [aws_sns_topic_data_protection_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_data_protection_policy) | resource |
| [aws_sns_topic_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.email_json](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sns_topic_subscription.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the SNS topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. | `string` | n/a | yes |
| <a name="input_data_protection_policy"></a> [data\_protection\_policy](#input\_data\_protection\_policy) | (Optional) A valid policy JSON document. The data protection policy defines your own rules and policies to audit and control the content for data in motion, as opposed to data at rest. | `string` | `null` | no |
| <a name="input_delivery_policy"></a> [delivery\_policy](#input\_delivery\_policy) | (Optional) The SNS delivery policy. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | (Optional) The display name to use for a topic with SMS subscriptions. | `string` | `""` | no |
| <a name="input_encryption_at_rest"></a> [encryption\_at\_rest](#input\_encryption\_at\_rest) | (Optional) A configuration to encrypt at rest in the SNS topic. Amazon SNS provides in-transit encryption by default. Enabling server-side encryption adds at-rest encryption to your topic. Amazon SNS encrypts your message as soon as it is received. The message is decrypted immediately prior to delivery. `encryption_at_rest` as defined below.<br>    (Optional) `enabled` - Whether to enable encryption at rest. Defaults to `false`.<br>    (Optional) `kms_key` - The ID of AWS KMS CMK (Customer Master Key) used for the encryption. | <pre>object({<br>    enabled = optional(bool, false)<br>    kms_key = optional(string)<br>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A valid policy JSON document. The resource-based policy defines who can publish or subscribe to the SNS topic. | `string` | `null` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_signature_version"></a> [signature\_version](#input\_signature\_version) | (Optional) The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS. Defaults to `1`. | `number` | `1` | no |
| <a name="input_subscriptions_by_email"></a> [subscriptions\_by\_email](#input\_subscriptions\_by\_email) | (Optional) A configuration for email subscriptions to the SNS topic. Deliver messages to the subscriber via SMTP. Until the subscription is confirmed, AWS does not allow Terraform to delete / unsubscribe the subscription. If you destroy an unconfirmed subscription, Terraform will remove the subscription from its state but the subscription will still exist in AWS. Each block of `subscriptions_by_email` as defined below.<br>    (Required) `email` - An email address that can receive notifications from the SNS topic.<br>    (Optional) `filter_policy` - The configuration to filter the messages that a subscriber receives. Additions or changes to the filter policy require up to 15 minutes to fully take effect. `filter_policy` as defined below.<br>      (Optional) `enabled` - Whether to enable the filter policy. Defaults to `false`.<br>      (Optional) `scope` - Determine how the filter policy will be applied to the message.<br>  Valid values are `ATTRIBUTES` and `BODY`. Defaults to `ATTRIBUTES`.<br>        `ATTRIBUTES` - The filter policy will be applied to the message attributes.<br>        `BODY` - The filter policy will be applied to the message body.<br>    (Optional) `redrive_policy` - The configuration to send undeliverable messages to a dead-letter queue. `redrive_policy` as defined below.<br>      (Optional) `dead_letter_sqs_queue` - The ARN of the SQS queue to which Amazon SNS can send undeliverable messages. | <pre>list(object({<br>    email = string<br>    filter_policy = optional(object({<br>      enabled = optional(bool, false)<br>      scope   = optional(string, "ATTRIBUTES")<br>      policy  = optional(string)<br>    }), {})<br>    redrive_policy = optional(object({<br>      dead_letter_sqs_queue = optional(string)<br>    }), {})<br>  }))</pre> | `[]` | no |
| <a name="input_subscriptions_by_email_json"></a> [subscriptions\_by\_email\_json](#input\_subscriptions\_by\_email\_json) | (Optional) A configuration for JSON-encoded email subscriptions to the SNS topic. Deliver JSON-encoded messages to the subscriber via SMTP. Until the subscription is confirmed, AWS does not allow Terraform to delete / unsubscribe the subscription. If you destroy an unconfirmed subscription, Terraform will remove the subscription from its state but the subscription will still exist in AWS. Each block of `subscriptions_by_email_json` as defined below.<br>    (Required) `email` - An email address that can receive notifications from the SNS topic.<br>    (Optional) `filter_policy` - The configuration to filter the messages that a subscriber receives. Additions or changes to the filter policy require up to 15 minutes to fully take effect. `filter_policy` as defined below.<br>      (Optional) `enabled` - Whether to enable the filter policy. Defaults to `false`.<br>      (Optional) `scope` - Determine how the filter policy will be applied to the message.<br>  Valid values are `ATTRIBUTES` and `BODY`. Defaults to `ATTRIBUTES`.<br>        `ATTRIBUTES` - The filter policy will be applied to the message attributes.<br>        `BODY` - The filter policy will be applied to the message body.<br>    (Optional) `redrive_policy` - The configuration to send undeliverable messages to a dead-letter queue. `redrive_policy` as defined below.<br>      (Optional) `dead_letter_sqs_queue` - The ARN of the SQS queue to which Amazon SNS can send undeliverable messages. | <pre>list(object({<br>    email = string<br>    filter_policy = optional(object({<br>      enabled = optional(bool, false)<br>      scope   = optional(string, "ATTRIBUTES")<br>      policy  = optional(string)<br>    }), {})<br>    redrive_policy = optional(object({<br>      dead_letter_sqs_queue = optional(string)<br>    }), {})<br>  }))</pre> | `[]` | no |
| <a name="input_subscriptions_by_lambda"></a> [subscriptions\_by\_lambda](#input\_subscriptions\_by\_lambda) | (Optional) A configuration for Lambda Function subscriptions to the SNS topic. Deliver JSON-encoded messages to the Lambda function. Each block of `subscriptions_by_lambda` as defined below.<br>    (Required) `name` - The name of the subscription to the SNS topic. This value is only used internally within Terraform code.<br>    (Required) `function` - The ARN of the AWS Lambda function that can receive notifications from the SNS topic.<br>    (Optional) `filter_policy` - The configuration to filter the messages that a subscriber receives. Additions or changes to the filter policy require up to 15 minutes to fully take effect. `filter_policy` as defined below.<br>      (Optional) `enabled` - Whether to enable the filter policy. Defaults to `false`.<br>      (Optional) `scope` - Determine how the filter policy will be applied to the message.<br>  Valid values are `ATTRIBUTES` and `BODY`. Defaults to `ATTRIBUTES`.<br>        `ATTRIBUTES` - The filter policy will be applied to the message attributes.<br>        `BODY` - The filter policy will be applied to the message body.<br>    (Optional) `redrive_policy` - The configuration to send undeliverable messages to a dead-letter queue. `redrive_policy` as defined below.<br>      (Optional) `dead_letter_sqs_queue` - The ARN of the SQS queue to which Amazon SNS can send undeliverable messages. | <pre>list(object({<br>    name     = string<br>    function = string<br>    filter_policy = optional(object({<br>      enabled = optional(bool, false)<br>      scope   = optional(string, "ATTRIBUTES")<br>      policy  = optional(string)<br>    }), {})<br>    redrive_policy = optional(object({<br>      dead_letter_sqs_queue = optional(string)<br>    }), {})<br>  }))</pre> | `[]` | no |
| <a name="input_subscriptions_by_sqs"></a> [subscriptions\_by\_sqs](#input\_subscriptions\_by\_sqs) | (Optional) A configuration for SQS Queue subscriptions to the SNS topic. Deliver JSON-encoded messages to the SQS queue. Each block of `subscriptions_by_sqs` as defined below.<br>    (Required) `name` - The name of the subscription to the SNS topic. This value is only used internally within Terraform code.<br>    (Required) `queue` - The ARN of the AWS SQS queue that can receive notifications from the SNS topic.<br>    (Optional) `raw_message_delivery_enabled` - Whether to enable raw message delivery. Raw messages are free of JSON formatting. Defaults to `false`.<br>    (Optional) `filter_policy` - The configuration to filter the messages that a subscriber receives. Additions or changes to the filter policy require up to 15 minutes to fully take effect. `filter_policy` as defined below.<br>      (Optional) `enabled` - Whether to enable the filter policy. Defaults to `false`.<br>      (Optional) `scope` - Determine how the filter policy will be applied to the message.<br>  Valid values are `ATTRIBUTES` and `BODY`. Defaults to `ATTRIBUTES`.<br>        `ATTRIBUTES` - The filter policy will be applied to the message attributes.<br>        `BODY` - The filter policy will be applied to the message body.<br>    (Optional) `redrive_policy` - The configuration to send undeliverable messages to a dead-letter queue. `redrive_policy` as defined below.<br>      (Optional) `dead_letter_sqs_queue` - The ARN of the SQS queue to which Amazon SNS can send undeliverable messages. | <pre>list(object({<br>    name                         = string<br>    queue                        = string<br>    raw_message_delivery_enabled = optional(bool, false)<br>    filter_policy = optional(object({<br>      enabled = optional(bool, false)<br>      scope   = optional(string, "ATTRIBUTES")<br>      policy  = optional(string)<br>    }), {})<br>    redrive_policy = optional(object({<br>      dead_letter_sqs_queue = optional(string)<br>    }), {})<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#input\_xray\_tracing\_enabled) | (Optional) Whether to activate AWS X-Ray Active Tracing mode for the SNS topic. If set to Active, Amazon SNS will vend X-Ray segment data to topic owner account if the sampled flag in the tracing header is true. Defaults to `false`, and the topic passes through the tracing header it receives from an Amazon SNS publisher to its subscriptions. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the SNS topic. |
| <a name="output_display_name"></a> [display\_name](#output\_display\_name) | The display name for a topic with SMS subscriptions. |
| <a name="output_encryption_at_rest"></a> [encryption\_at\_rest](#output\_encryption\_at\_rest) | A configuration to encrypt at rest in the SNS topic. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the SNS topic. |
| <a name="output_name"></a> [name](#output\_name) | The name for the SNS topic. |
| <a name="output_owner"></a> [owner](#output\_owner) | The AWS Account ID of the SNS topic owner. |
| <a name="output_signature_version"></a> [signature\_version](#output\_signature\_version) | The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS. |
| <a name="output_subscriptions"></a> [subscriptions](#output\_subscriptions) | The configurations for subscriptions to the SNS topic.<br>    `EMAIL` - |
| <a name="output_type"></a> [type](#output\_type) | The type of the SNS topic. |
| <a name="output_xray_tracing_enabled"></a> [xray\_tracing\_enabled](#output\_xray\_tracing\_enabled) | Whether to activate AWS X-Ray Active Tracing mode for the SNS topic. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
