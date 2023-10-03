output "arn" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.this.arn
}

output "id" {
  description = "The ID of the SNS topic."
  value       = aws_sns_topic.this.id
}

output "owner" {
  description = "The AWS Account ID of the SNS topic owner."
  value       = aws_sns_topic.this.owner
}

output "name" {
  description = "The name for the SNS topic."
  value       = aws_sns_topic.this.name
}

output "display_name" {
  description = "The display name for a topic with SMS subscriptions."
  value       = aws_sns_topic.this.display_name
}

output "type" {
  description = "The type of the SNS topic."
  value       = "STANDARD"
}

output "subscriptions" {
  description = <<EOF
  The configurations for subscriptions to the SNS topic.
    `EMAIL` -
  EOF
  value = {
    "EMAIL" = {
      for email, subscription in aws_sns_topic_subscription.email :
      email => {
        arn       = subscription.arn
        owner     = subscription.owner_id
        email     = subscription.endpoint
        is_active = !subscription.pending_confirmation

        filter_policy = try({
          enabled = subscription.filter_policy != null && subscription.filter_policy != ""
          scope = try(
            {
              for k, v in local.filter_policy_scopes :
              v => k
            }[subscription.filter_policy_scope],
            null
          )
          policy = try(jsondecode(subscription.filter_policy), null)
        }, null)
        redrive_policy = try({
          dead_letter_sqs_queue = jsondecode(subscription.redrive_policy)["deadLetterTargetArn"]
        }, null)
      }
    }
    "EMAIL_JSON" = {
      for email, subscription in aws_sns_topic_subscription.email_json :
      email => {
        arn       = subscription.arn
        owner     = subscription.owner_id
        email     = subscription.endpoint
        is_active = !subscription.pending_confirmation

        filter_policy = try({
          enabled = subscription.filter_policy != null && subscription.filter_policy != ""
          scope = try(
            {
              for k, v in local.filter_policy_scopes :
              v => k
            }[subscription.filter_policy_scope],
            null
          )
          policy = try(jsondecode(subscription.filter_policy), null)
        }, null)
        redrive_policy = try({
          dead_letter_sqs_queue = jsondecode(subscription.redrive_policy)["deadLetterTargetArn"]
        }, null)
      }
    }
  }
}

output "xray_tracing_enabled" {
  description = "Whether to activate AWS X-Ray Active Tracing mode for the SNS topic."
  value       = aws_sns_topic.this.tracing_config == "Active"
}

output "signature_version" {
  description = "The signature version corresponds to the hashing algorithm used while creating the signature of the notifications, subscription confirmations, or unsubscribe confirmation messages sent by Amazon SNS."
  value       = aws_sns_topic.this.signature_version
}

output "encryption_at_rest" {
  description = "A configuration to encrypt at rest in the SNS topic."
  value = {
    enabled = var.encryption_at_rest.enabled
    kms_key = aws_sns_topic.this.kms_master_key_id
  }
}

output "z" {
  description = "The list of log streams for the log group."
  value = {
    for k, v in aws_sns_topic.this :
    k => v
    if !contains(["id", "arn", "name", "name_prefix", "display_name", "owner", "tags", "tags_all", "signature_version", "kms_master_key_id", "tracing_config", "content_based_deduplication", "fifo_topic"], k)
  }
}

output "zz" {
  description = "The list of log streams for the log group."
  value = {
    policy      = aws_sns_topic_policy.this
    data_policy = aws_sns_topic_data_protection_policy.this
    email = {
      for email, subscription in aws_sns_topic_subscription.email :
      email => {
        for k, v in subscription :
        k => v
        if !contains(["arn", "endpoint", "topic_arn", "protocol", "subscription_role_arn", "id", "owner_id", "pending_confirmation", "confirmation_timeout_in_minutes", "delivery_policy", "endpoint_auto_confirms", "redrive_policy"], k)
      }
    }
  }
}
