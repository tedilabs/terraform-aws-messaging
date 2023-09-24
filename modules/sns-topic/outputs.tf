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

output "z" {
  description = "The list of log streams for the log group."
  value = {
    for k, v in aws_sns_topic.this :
    k => v
    if !contains(["id", "arn", "name", "name_prefix", "owner", "tags", "tags_all"], k)
  }
}

output "zz" {
  description = "The list of log streams for the log group."
  value = {
    policy = aws_sns_topic_policy.this
    data_policy = aws_sns_topic_data_protection_policy.this
  }
}
