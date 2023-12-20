# terraform-aws-messaging

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-messaging?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-messaging?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates messaging related resources on AWS.

- [eventbridge-event-bus](./modules/eventbridge-event-bus)
- [eventbridge-rule](./modules/eventbridge-rule)
- [msk-cluster](./modules/msk-cluster)
- [sns-fifo-topic](./modules/sns-fifo-topic)
- [sns-standard-topic](./modules/sns-standard-topic)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-messaging) were written to manage the following AWS Services with Terraform.

- **AWS EventBridge (Formerly known as CloudWatch Events)**
  - Event Bus
  - Rule
- **AWS MSK (Managed Streaming for Apache Kafka)**
  - Cluster
- **AWS SNS (Simple Notification Service)**
  - FIFO Topic
  - Standard Topic
- **AWS SQS (Simple Queue Service)**
  - Comming Soon!


## Examples

### SNS (Simple Notification Service)

- [sns-standard-topic-email-subscription](./examples/sns-standard-topic-email-subscription)
- [sns-standard-topic-lambda-subscription](./examples/sns-standard-topic-lambda-subscription)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-messaging). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2023, [Byungjin Park](https://www.posquit0.com).
