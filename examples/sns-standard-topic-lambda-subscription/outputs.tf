output "topic" {
  description = "The SNS topic."
  value       = module.topic
}

output "lambda_function" {
  description = "The Lambda function for VPC Lattice."
  value       = module.lambda_function
}
