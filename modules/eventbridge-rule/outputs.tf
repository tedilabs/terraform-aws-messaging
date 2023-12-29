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

locals {
  output_api_destination_targets = {
    for target in var.api_destination_targets :
    target.id => merge(target, {
      instance = aws_cloudwatch_event_target.api_destination[target.id]
    })
  }
  output_aws_service_targets = {
    for target in var.aws_service_targets :
    target.id => merge(target, {
      instance = aws_cloudwatch_event_target.aws_service[target.id]
    })
  }
}

output "event_bus_targets" {
  description = "The configuration for EventBridge event bus targets of the rule."
  value = {
    for id, target in aws_cloudwatch_event_target.event_bus :
    id => {
      id             = target.target_id
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
    for id, target in local.output_api_destination_targets :
    id => {
      id              = target.id
      api_destination = target.instance.arn
      execution_role  = target.instance.role_arn

      input = target.input

      dead_letter_queue = {
        enabled = one(target.instance.dead_letter_config) != null
        sqs_queue = (one(target.instance.dead_letter_config) != null
          ? one(target.instance.dead_letter_config).arn
          : null
        )
      }
      retry_policy = target.retry_policy
    }
  }
}

output "aws_service_targets" {
  description = "The configuration for AWS service targets of the rule."
  value = {
    for id, target in local.output_aws_service_targets :
    id => {
      id             = target.id
      type           = target.type
      target         = target.instance.arn
      execution_role = target.instance.role_arn

      input = target.input

      dead_letter_queue = {
        enabled = one(target.instance.dead_letter_config) != null
        sqs_queue = (one(target.instance.dead_letter_config) != null
          ? one(target.instance.dead_letter_config).arn
          : null
        )
      }
      retry_policy = target.retry_policy
    }
  }
}
