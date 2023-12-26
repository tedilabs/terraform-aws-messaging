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

output "execution_role" {
  description = "The ARN (Amazon Resource Name) of the IAM role associated with the rule that is used for target invocation."
  value       = aws_cloudwatch_event_rule.this.role_arn
}

output "trigger" {
  description = "The configuration for the rule trriger."
  value = {
    event_pattern       = aws_cloudwatch_event_rule.this.event_pattern
    schedule_expression = aws_cloudwatch_event_rule.this.schedule_expression
  }
}

output "event_bus_targets" {
  description = "The configuration for EventBridge event bus targets of the rule."
  value = {
    for id, target in aws_cloudwatch_event_target.event_bus :
    id => {
      id             = target.id
      event_bus      = target.arn
      execution_role = target.role_arn

      dead_letter_queue = {
        enabled = one(target.dead_letter_config) != null
        sqs_queue = (one(target.dead_letter_config) != null
          ? one(target.dead_letter_config).arn
          : null
        )
      }
    }
  }
}

# TODO: Support EventBridge API Destination targets
output "api_destination_targets" {
  description = "The configuration for EventBridge API destination targets of the rule."
  value = {
    for id, target in aws_cloudwatch_event_target.api_destination :
    id => {
      id              = target.id
      api_destination = target.arn
      execution_role  = target.role_arn

      dead_letter_queue = {
        enabled = one(target.dead_letter_config) != null
        sqs_queue = (one(target.dead_letter_config) != null
          ? one(target.dead_letter_config).arn
          : null
        )
      }
      retry_policy = {
        maximum_event_age      = target.retry_policy[0].maximum_event_age_in_seconds
        maximum_retry_attempts = target.retry_policy[0].maximum_retry_attempts
      }
    }
  }
}

output "aws_service_targets" {
  description = "The configuration for AWS service targets of the rule."
  value = {
    for id, target in aws_cloudwatch_event_target.aws_service :
    id => {
      id             = target.id
      target         = target.arn
      execution_role = target.role_arn

      dead_letter_queue = {
        enabled = one(target.dead_letter_config) != null
        sqs_queue = (one(target.dead_letter_config) != null
          ? one(target.dead_letter_config).arn
          : null
        )
      }
      retry_policy = {
        maximum_event_age      = target.retry_policy[0].maximum_event_age_in_seconds
        maximum_retry_attempts = target.retry_policy[0].maximum_retry_attempts
      }
      z = {
        for k, v in target :
        k => v
        if !contains(["id", "arn", "role_arn", "dead_letter_config"], k)
      }
    }
  }
}
