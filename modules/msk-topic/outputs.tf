output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_msk_topic.this.region
}

output "arn" {
  description = "The ARN of the Kafka topic."
  value       = aws_msk_topic.this.arn
}

output "name" {
  description = "The name of the Kafka topic."
  value       = aws_msk_topic.this.name
}

output "cluster" {
  description = "The ARN of the MSK cluster which the topic belongs to."
  value       = aws_msk_topic.this.cluster_arn
}

output "partition_count" {
  description = "The number of partitions for the topic."
  value       = aws_msk_topic.this.partition_count
}

output "replication_factor" {
  description = "The number of replicas for each partition of the topic."
  value       = aws_msk_topic.this.replication_factor
}

output "configs" {
  description = "A map of the topic-level Kafka configurations which are explicitly set by this module."
  value       = var.configs
}

output "effective_configs" {
  description = "A map of all topic-level Kafka configurations of the topic, including the ones from the cluster defaults and the ones set outside Terraform."
  value       = try(jsondecode(aws_msk_topic.this.configs_actual), {})
}
