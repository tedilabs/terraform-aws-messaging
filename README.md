# terraform-aws-messaging

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-messaging?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-messaging?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates messaging related resources on AWS.

- [eventbridge-event-bus](./modules/eventbridge-event-bus)
- [eventbridge-rule](./modules/eventbridge-rule)
- [sns-fifo-topic](./modules/sns-fifo-topic)
- [sns-standard-topic](./modules/sns-standard-topic)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-messaging) were written to manage the following AWS Services with Terraform.

- **AWS EventBridge (Formerly known as CloudWatch Events)**
  - Event Bus
  - Rule
- **AWS SNS (Simple Notification Service)**
  - FIFO Topic
  - Standard Topic
- **AWS SQS (Simple Queue Service)**
  - Coming Soon!


## Examples

### EventBridge

- [eventbridge](./examples/eventbridge)

### SNS (Simple Notification Service)

- [sns-standard-topic-email-subscription](./examples/sns-standard-topic-email-subscription)
- [sns-standard-topic-lambda-subscription](./examples/sns-standard-topic-lambda-subscription)
- [sns-standard-topic-sqs-subscription](./examples/sns-standard-topic-sqs-subscription)


## MSK Module Migration

The MSK modules and their examples have moved to [terraform-aws-msk](https://github.com/tedilabs/terraform-aws-msk). They are no longer included in this package. Existing messaging release tags remain available for pinned consumers.

| Previous module source | New module source |
| --- | --- |
| `tedilabs/messaging/aws//modules/msk-cluster` | `tedilabs/msk/aws//modules/cluster` |
| `tedilabs/messaging/aws//modules/msk-topic` | `tedilabs/msk/aws//modules/topic` |
| `tedilabs/messaging/aws//modules/msk-vpc-connection` | `tedilabs/msk/aws//modules/vpc-connection` |

After the new package is released and published to the Terraform Registry, update each module's `source` and select a published version from the new package (its initial version is `0.1.0`; messaging versions do not carry over). For Git sources, change the repository to `terraform-aws-msk`, remove `msk-` from the module subdirectory, and select a release tag from the new repository.

Keep your existing module block labels, inputs, and provider configuration, then run `terraform init` and review `terraform plan`. Internal Terraform resource addresses are unchanged, so changing the source alone does not require a state move. Module metadata tags and telemetry identify the new package and module names. The default resource group names for `cluster` and `vpc-connection` also change; set `resource_group.name` to the existing name before migrating if you want to preserve it.

The examples are now available as [topic](https://github.com/tedilabs/terraform-aws-msk/tree/main/examples/topic) and [vpc-connection](https://github.com/tedilabs/terraform-aws-msk/tree/main/examples/vpc-connection).


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-messaging). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2023-2026, [Byungjin Park](https://www.posquit0.com).
