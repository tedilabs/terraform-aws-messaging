# ses-identity

This module creates following resources.

- `aws_sesv2_email_identity`
- `aws_route53_record` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.84 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_sesv2_email_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sesv2_email_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The domain name of the SES domain identity. | `string` | n/a | yes |
| <a name="input_configuration_set"></a> [configuration\_set](#input\_configuration\_set) | (Optional) The configuration set to use by default when sending from this identity. Note that any configuration set defined in the email sending request takes precedence. | `string` | `null` | no |
| <a name="input_dkim"></a> [dkim](#input\_dkim) | (Optional) The configuration for the DKIM (DomainKeys Identified Mail). `dkim` as defined below.<br/>    (Optional) `type` - Whether to use either Easy DKIM (`EASY_DKIM`) or Bring Your Own DKIM (`BYODKIM`), and depending on your choice, you'll have to configure the signing key length of the private key. Valid values are `EASY_DKIM` and `BYODKIM`. Defaults to `EASY_DKIM`.<br/>    (Optional) `signing_key_type` - The key type of the future DKIM key pair to be generated. This can be changed at most once per day. The signing key length of the private key. Valid values are `RSA_1024` and `RSA_2048`. Defaults to `RSA_2048`. Only required if `type` is `EASY_DKIM`.<br/>    (Optional) `private_key` - A private key that's used to generate a DKIM signature. The private key must use 1024 or 2048-bit RSA encryption, and must be encoded using base64 encoding. Only required if `type` is `BYODKIM`.<br/>    (Optional) `selector_name` - A string that's used to identify a public key in the DNS configuration for a domain. Only required if `type` is `BYODKIM`.<br/>    (Optional) `verification` - A configuration for the DKIM verification. `verification` as defined below.<br/>      (Optional) `enabled` - Whether to process DKIM verification by creating the necessary domain records in the module. Defaults to `false`.<br/>      (Optional) `zone_id` - The ID of Hosted Zone to automatically manage the records for DKIM verification. | <pre>object({<br/>    type             = optional(string, "EASY_DKIM")<br/>    signing_key_type = optional(string, "RSA_2048")<br/>    private_key      = optional(string)<br/>    selector_name    = optional(string)<br/>    verification = optional(object({<br/>      enabled = optional(bool, false)<br/>      zone_id = optional(string)<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the SES identity. |
| <a name="output_configuration_set"></a> [configuration\_set](#output\_configuration\_set) | The configuration set to use by default when sending from this identity. |
| <a name="output_dkim"></a> [dkim](#output\_dkim) | The configuration for the DKIM. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the SES identity. |
| <a name="output_name"></a> [name](#output\_name) | The domain name for the SES identity. |
| <a name="output_status"></a> [status](#output\_status) | The status of the SES identity. |
| <a name="output_type"></a> [type](#output\_type) | The type of the SES identity. |
<!-- END_TF_DOCS -->
