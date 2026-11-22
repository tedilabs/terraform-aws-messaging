output "topic" {
  description = "The SNS topic."
  value       = module.topic
}

output "lambda_function" {
  description = "The Lambda function subscribed to the SNS topic."
  value       = module.lambda_function
}
