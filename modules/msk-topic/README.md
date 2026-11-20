# msk-topic

This module creates following resources.

- `aws_msk_topic`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.38 |
| <a name="requirement_telemetry"></a> [telemetry](#requirement\_telemetry) | >= 0.2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.38 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_msk_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | (Required) The ARN of the MSK cluster to create the topic in. The cluster must be an MSK Provisioned cluster in the `ACTIVE` state, running Apache Kafka 3.6.0 or later. Changing this value replaces the topic. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the Kafka topic. A topic name can have a maximum of 249 characters, including letters, numbers, dots, underscores, and hyphens. Changing this value replaces the topic. | `string` | n/a | yes |
| <a name="input_partition_count"></a> [partition\_count](#input\_partition\_count) | (Required) The number of partitions for the topic. Kafka can only increase the number of partitions of a topic; decreasing it fails. Increasing it changes the partition of keyed messages, which breaks the ordering of messages with the same key. | `number` | n/a | yes |
| <a name="input_replication_factor"></a> [replication\_factor](#input\_replication\_factor) | (Required) The number of replicas for each partition of the topic. It cannot be greater than the number of brokers in the cluster. Changing this value replaces the topic, which deletes all messages in the topic. | `number` | n/a | yes |
| <a name="input_configs"></a> [configs](#input\_configs) | (Optional) A map of the topic-level Kafka configurations which override the cluster defaults. Each key is the name of the configuration, such as `retention.ms`, `cleanup.policy` and `min.insync.replicas`. Each value is the value of the configuration as a string. Removing a key from this map does not reset the configuration on the topic. Defaults to `{}`. | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_telemetry"></a> [telemetry](#input\_telemetry) | (Optional) A configuration to collect telemetry data for the module. This is used to improve the module and its features. To send pseudonyms instead of identifying values such as the hostname and the Git remote, set `pseudonymization_enabled` to `true`. Pseudonyms are not anonymous; to keep data from being sent, disable its collector. The default configuration enables telemetry collection for machine, network, git, github, github actions, HCP Terraform, terraform, and toolchain. You can disable telemetry collection by setting `enabled` to `false`. `telemetry` block as defined below.<br/>    (Optional) `enabled` - Whether to enable telemetry collection. Default is `true`.<br/>    (Optional) `capture_machine` - Whether to capture machine information. Default is `true`.<br/>    (Optional) `capture_network` - Whether to capture network information. Default is `true`.<br/>    (Optional) `capture_git` - Whether to capture git information. Default is `true`.<br/>    (Optional) `capture_github` - Whether to capture GitHub information. Default is `true`.<br/>    (Optional) `capture_github_actions` - Whether to capture GitHub Actions information. Default is `true`.<br/>    (Optional) `capture_hcp_terraform` - Whether to capture HCP Terraform information. Default is `true`.<br/>    (Optional) `capture_terraform` - Whether to capture Terraform information. Default is `true`.<br/>    (Optional) `capture_toolchain` - Whether to capture toolchain information. Default is `true`.<br/>    (Optional) `pseudonymization_enabled` - Whether to enable pseudonymization of the captured data. Default is `false`. | <pre>object({<br/>    enabled = optional(bool, true)<br/><br/>    capture_machine        = optional(bool, true)<br/>    capture_network        = optional(bool, true)<br/>    capture_git            = optional(bool, true)<br/>    capture_github         = optional(bool, true)<br/>    capture_github_actions = optional(bool, true)<br/>    capture_hcp_terraform  = optional(bool, true)<br/>    capture_terraform      = optional(bool, true)<br/>    capture_toolchain      = optional(bool, true)<br/><br/>    pseudonymization_enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | (Optional) How long to wait for the topic to be created, updated or deleted. `timeouts` as defined below.<br/>    (Optional) `create` - Timeout for creating the topic. Defaults to `30m`.<br/>    (Optional) `update` - Timeout for updating the topic. Defaults to `30m`.<br/>    (Optional) `delete` - Timeout for deleting the topic. Defaults to `30m`. | <pre>object({<br/>    create = optional(string, "30m")<br/>    update = optional(string, "30m")<br/>    delete = optional(string, "30m")<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the Kafka topic. |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | The ARN of the MSK cluster which the topic belongs to. |
| <a name="output_configs"></a> [configs](#output\_configs) | A map of the topic-level Kafka configurations which are explicitly set by this module. |
| <a name="output_effective_configs"></a> [effective\_configs](#output\_effective\_configs) | A map of all topic-level Kafka configurations of the topic, including the ones from the cluster defaults and the ones set outside Terraform. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Kafka topic. |
| <a name="output_partition_count"></a> [partition\_count](#output\_partition\_count) | The number of partitions for the topic. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_replication_factor"></a> [replication\_factor](#output\_replication\_factor) | The number of replicas for each partition of the topic. |
<!-- END_TF_DOCS -->
