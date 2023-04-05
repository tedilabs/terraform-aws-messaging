provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

locals {
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name
}


###################################################
# Event Bus on EventBridge
###################################################

module "event_bus" {
  source = "../../modules/eventbridge-event-bus"
  # source  = "tedilabs/messaging/aws//modules/eventbridge-event-bus"
  # version = "~> 0.2.0"

  name = "aws"
  policy = jsonencode(yamldecode(<<EOF
    Version: "2008-10-17"
    Statement:
    - Sid: "AllowAccountToPutEvents"
      Effect: "Allow"
      Principal:
        "AWS": "${local.account_id}"
      Action:
      - "events:PutEvents"
      Resource: "arn:aws:events:${local.region}:${local.account_id}:event-bus/aws"
  EOF
  ))

  archives = [
    {
      name        = "test"
      description = "Test Archive"
    }
  ]
  schema_discovery = {
    enabled = false
  }

  tags = {
    "project" = "terraform-aws-messaging-examples"
  }
}
