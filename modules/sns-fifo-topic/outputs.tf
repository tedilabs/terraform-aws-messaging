output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_sns_topic.this.region
}

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
  value       = "FIFO"
}

output "content_based_deduplication" {
  description = "Whether to enable default message deduplication based on message content."
  value       = aws_sns_topic.this.content_based_deduplication
}

output "throughput_scope" {
  description = "The throughput scope of the FIFO topic."
  value = {
    for k, v in local.throughput_scopes :
    v => k
  }[aws_sns_topic.this.fifo_throughput_scope]
}

output "message_archiving" {
  description = <<EOF
  The configuration for message archiving of the FIFO topic.
    `enabled` - Whether message archiving is enabled.
    `retention_in_days` - The number of days to retain messages in the archive.
    `beginning_archive_time` - The oldest timestamp at which a FIFO topic subscriber can start a replay.
  EOF
  value = {
    enabled = var.message_archiving.enabled
    retention_in_days = (var.message_archiving.enabled
      ? tonumber(jsondecode(aws_sns_topic.this.archive_policy)["MessageRetentionPeriod"])
      : null
    )
    beginning_archive_time = aws_sns_topic.this.beginning_archive_time
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

output "delivery_status_logging" {
  description = "The configuration for the delivery status logging of the SNS topic, keyed by endpoint type."
  value = {
    for type, config in var.delivery_status_logging :
    type => {
      enabled                      = config.enabled
      success_feedback_role        = aws_sns_topic.this["${type}_success_feedback_role_arn"]
      success_feedback_sample_rate = aws_sns_topic.this["${type}_success_feedback_sample_rate"]
      failure_feedback_role        = aws_sns_topic.this["${type}_failure_feedback_role_arn"]
    }
  }
}

# output "z" {
#   description = "The list of log streams for the log group."
#   value = {
#     for k, v in aws_sns_topic.this :
#     k => v
#     if !contains(["id", "arn", "name", "name_prefix", "display_name", "owner", "tags", "tags_all", "signature_version", "kms_master_key_id", "tracing_config", "content_based_deduplication", "fifo_topic"], k)
#   }
# }

# output "zz" {
#   description = "The list of log streams for the log group."
#   value = {
#     policy = aws_sns_topic_policy.this
#   }
# }

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}
