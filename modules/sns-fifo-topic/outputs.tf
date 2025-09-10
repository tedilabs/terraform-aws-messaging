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
    policy = aws_sns_topic_policy.this
  }
}

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
