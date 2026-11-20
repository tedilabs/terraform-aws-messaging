output "topic" {
  description = "The MSK topic."
  value       = module.topic
}

output "compacted_topic" {
  description = "The compacted MSK topic."
  value       = module.compacted_topic
}
