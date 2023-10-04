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

  name         = "standard-test-sqs"
  display_name = "Standard Test SQS"

  subscriptions_by_sqs = [
    {
      name  = "example-sqs"
      queue = aws_sqs_queue.example.arn

      raw_message_delivery_enabled = true
      redrive_policy = {
        dead_letter_sqs_queue = aws_sqs_queue.dlq.arn
      }
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
