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

  name         = "standard-test-lambda"
  display_name = "Standard Test Lambda"

  subscriptions_by_lambda = [
    {
      name     = "helloworld"
      function = module.lambda_function.lambda_function_arn
    },
    # {
    #   name     = "helloworld-redrive"
    #   function = module.lambda_function.lambda_function_arn
    #   redrive_policy = {
    #     dead_letter_sqs_queue = "arn:aws:sqs:us-east-1:123456789123:test"
    #   }
    # },
    {
      name     = "helloworld-filter"
      function = module.lambda_function.lambda_function_arn
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
