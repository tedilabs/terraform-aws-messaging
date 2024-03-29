# INFO: Not support cross-account subscriptions

locals {
  filter_policy_scopes = {
    "ATTRIBUTES" = "MessageAttributes"
    "BODY"       = "MessageBody"
  }
}


###################################################
# Email Subscriptions
###################################################

# INFO: Not supported attributes
# - `confirmation_timeout_in_minutes`
# - `delivery_policy`
# - `endpoint_auto_confirms`
# - `raw_message_delivery `
# - `subscription_role_arn`
resource "aws_sns_topic_subscription" "email" {
  for_each = {
    for subscription in var.subscriptions_by_email :
    subscription.email => subscription
  }

  topic_arn = aws_sns_topic.this.arn

  protocol = "email"
  endpoint = each.key

  filter_policy_scope = (each.value.filter_policy.enabled
    ? local.filter_policy_scopes[each.value.filter_policy.scope]
    : null
  )
  filter_policy = (each.value.filter_policy.enabled
    ? each.value.filter_policy.policy
    : null
  )

  redrive_policy = (each.value.redrive_policy.dead_letter_sqs_queue != null
    ? jsonencode({
      "deadLetterTargetArn" = each.value.redrive_policy.dead_letter_sqs_queue
    })
    : null
  )
}


###################################################
# Email JSON Subscriptions
###################################################

# INFO: Not supported attributes
# - `confirmation_timeout_in_minutes`
# - `delivery_policy`
# - `endpoint_auto_confirms`
# - `raw_message_delivery `
# - `subscription_role_arn`
resource "aws_sns_topic_subscription" "email_json" {
  for_each = {
    for subscription in var.subscriptions_by_email_json :
    subscription.email => subscription
  }

  topic_arn = aws_sns_topic.this.arn

  protocol = "email-json"
  endpoint = each.key

  filter_policy_scope = (each.value.filter_policy.enabled
    ? local.filter_policy_scopes[each.value.filter_policy.scope]
    : null
  )
  filter_policy = (each.value.filter_policy.enabled
    ? each.value.filter_policy.policy
    : null
  )

  redrive_policy = (each.value.redrive_policy.dead_letter_sqs_queue != null
    ? jsonencode({
      "deadLetterTargetArn" = each.value.redrive_policy.dead_letter_sqs_queue
    })
    : null
  )
}


###################################################
# Lambda Function Subscriptions
###################################################

# INFO: Not supported attributes
# - `confirmation_timeout_in_minutes`
# - `delivery_policy`
# - `endpoint_auto_confirms`
# - `raw_message_delivery `
# - `subscription_role_arn`
resource "aws_sns_topic_subscription" "lambda" {
  for_each = {
    for subscription in var.subscriptions_by_lambda :
    subscription.name => subscription
  }

  topic_arn = aws_sns_topic.this.arn

  protocol = "lambda"
  endpoint = each.value.function

  filter_policy_scope = (each.value.filter_policy.enabled
    ? local.filter_policy_scopes[each.value.filter_policy.scope]
    : null
  )
  filter_policy = (each.value.filter_policy.enabled
    ? each.value.filter_policy.policy
    : null
  )

  redrive_policy = (each.value.redrive_policy.dead_letter_sqs_queue != null
    ? jsonencode({
      "deadLetterTargetArn" = each.value.redrive_policy.dead_letter_sqs_queue
    })
    : null
  )
}


###################################################
# SQS Queue Subscriptions
###################################################

# INFO: Not supported attributes
# - `confirmation_timeout_in_minutes`
# - `delivery_policy`
# - `endpoint_auto_confirms`
# - `subscription_role_arn`
resource "aws_sns_topic_subscription" "sqs" {
  for_each = {
    for subscription in var.subscriptions_by_sqs :
    subscription.name => subscription
  }

  topic_arn = aws_sns_topic.this.arn

  protocol = "sqs"
  endpoint = each.value.queue

  raw_message_delivery = each.value.raw_message_delivery_enabled

  filter_policy_scope = (each.value.filter_policy.enabled
    ? local.filter_policy_scopes[each.value.filter_policy.scope]
    : null
  )
  filter_policy = (each.value.filter_policy.enabled
    ? each.value.filter_policy.policy
    : null
  )

  redrive_policy = (each.value.redrive_policy.dead_letter_sqs_queue != null
    ? jsonencode({
      "deadLetterTargetArn" = each.value.redrive_policy.dead_letter_sqs_queue
    })
    : null
  )
}
