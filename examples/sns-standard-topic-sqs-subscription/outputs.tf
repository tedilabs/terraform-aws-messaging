output "queues" {
  description = "The SQS queue."
  value = {
    "example" = resource.aws_sqs_queue.example.arn
    "dlq"     = resource.aws_sqs_queue.dlq.arn
  }
}

output "topic" {
  description = "The SNS topic."
  value       = module.topic
}
