provider "aws" {
  region = "us-east-1"
}


###################################################
# SNS Topic
###################################################

module "topic" {
  source = "../../modules/sns-standard-topic"
  # source  = "tedilabs/messaging/aws//modules/sns-standard-topic"
  # version = "~> 0.2.0"

  name         = "standard-test-email"
  display_name = "Standard Test Email"

  subscriptions_by_email = [
    {
      email = "admin@example.com"
    },
    {
      email = "admin+dlq@example.com"
      redrive_policy = {
        dead_letter_sqs_queue = "arn:aws:sqs:us-east-1:123456789123:test"
      }
    },
    {
      email = "admin+filter@example.com"
      filter_policy = {
        enabled = true
        scope   = "ATTRIBUTES"
        policy = jsonencode({
          "store" = ["example_corp"]
        })
      }
    },
  ]
  subscriptions_by_email_json = [
    {
      email = "admin@example.com"
    },
    {
      email = "admin+dlq@example.com"
      redrive_policy = {
        dead_letter_sqs_queue = "arn:aws:sqs:us-east-1:123456789123:test"
      }
    },
    {
      email = "admin+filter@example.com"
      filter_policy = {
        enabled = true
        scope   = "ATTRIBUTES"
        policy = jsonencode({
          "store" = ["example_corp"]
        })
      }
    },
  ]

  tags = {
    "project" = "terraform-aws-messaging-examples"
  }
}
