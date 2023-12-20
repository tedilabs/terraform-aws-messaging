output "id" {
  description = "The unique identifier for the rule."
  value       = aws_cloudwatch_event_rule.this.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the rule."
  value       = aws_cloudwatch_event_rule.this.arn
}

output "name" {
  description = "The name of the rule."
  value       = aws_cloudwatch_event_rule.this.name
}

output "description" {
  description = "The description of the rule."
  value       = aws_cloudwatch_event_rule.this.description
}

output "event_bus" {
  description = "The name of the event bus."
  value       = aws_cloudwatch_event_rule.this.event_bus_name
}

output "state" {
  description = "The state of the rule."
  value       = aws_cloudwatch_event_rule.this.state
}

output "trigger" {
  description = "The configuration for the rule trriger."
  value = {
    event_pattern       = aws_cloudwatch_event_rule.this.event_pattern
    schedule_expression = aws_cloudwatch_event_rule.this.schedule_expression
  }
}

output "targets" {
  description = "A list of archives for the event bus."
  value = [
    # for target in aws_cloudwatch_event_target.this : {
    #   id                = archive.id
    #   arn               = archive.arn
    #   name              = archive.name
    #   description       = archive.description
    #   retention_in_days = archive.retention_days
    # }
  ]
}
