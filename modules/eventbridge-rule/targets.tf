locals {
  aws_service_types = {
    "CLOUDWATCH_LOG_GROUP" = {
      support_execution_role = false
    }
    "SNS_TOPIC" = {
      support_execution_role = false
    }
    "SQS_QUEUE" = {
      support_execution_role = false
    }
    "SSM_RUN_COMMAND" = {
      support_execution_role = true
    }
  }
}


###################################################
# Rule Targets (Event Bus)
###################################################

resource "aws_cloudwatch_event_target" "event_bus" {
  for_each = {
    for target in var.event_bus_targets :
    target.id => target
  }

  event_bus_name = var.event_bus
  rule           = aws_cloudwatch_event_rule.this.name

  target_id = each.key
  arn       = each.value.event_bus


  ## Permissions
  role_arn = (each.value.execution_role != null
    ? each.value.execution_role
    : (var.default_execution_role.enabled ? module.role[0].arn : null)
  )


  ## Config
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_queue.enabled ? [each.value.dead_letter_queue] : []
    iterator = config

    content {
      arn = config.value.sqs_queue
    }
  }
}


###################################################
# Rule Targets (API Destination)
###################################################

# TODO: Support EventBridge API Destination targets
resource "aws_cloudwatch_event_target" "api_destination" {
  for_each = {
    for target in var.api_destination_targets :
    target.id => target
  }

  event_bus_name = var.event_bus
  rule           = aws_cloudwatch_event_rule.this.name

  target_id = each.key
  arn       = each.value.api_destination


  ## Permissions
  role_arn = (each.value.execution_role != null
    ? each.value.execution_role
    : (var.default_execution_role.enabled ? module.role[0].arn : null)
  )


  ## Config
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_queue.enabled ? [each.value.dead_letter_queue] : []
    iterator = config

    content {
      arn = config.value.sqs_queue
    }
  }
  retry_policy {
    maximum_event_age_in_seconds = each.value.retry_policy.maximum_event_age
    maximum_retry_attempts       = each.value.retry_policy.maximum_retry_attempts
  }
}


###################################################
# Rule Targets (AWS Services)
###################################################

# batch_target - (Optional) Parameters used when you are using the rule to invoke an Amazon Batch Job. Documented below. A maximum of 1 are allowed.
# ecs_target - (Optional) Parameters used when you are using the rule to invoke Amazon ECS Task. Documented below. A maximum of 1 are allowed.
# http_target - (Optional) Parameters used when you are using the rule to invoke an API Gateway REST endpoint. Documented below. A maximum of 1 is allowed.
# kinesis_target - (Optional) Parameters used when you are using the rule to invoke an Amazon Kinesis Stream. Documented below. A maximum of 1 are allowed.
# redshift_target - (Optional) Parameters used when you are using the rule to invoke an Amazon Redshift Statement. Documented below. A maximum of 1 are allowed.
# sagemaker_pipeline_target - (Optional) Parameters used when you are using the rule to invoke an Amazon SageMaker Pipeline. Documented below. A maximum of 1 are allowed.

# NOTE:
# Input , InputPath , and InputTransformer are not available with
# PutTarget if the target is an event bus of a different Amazon Web
# Services account.
# input - (Optional) Valid JSON text passed to the target. Conflicts with input_path and input_transformer.
# input_path - (Optional) The value of the JSONPath that is used for extracting part of the matched event when passing it to the target. Conflicts with input and input_transformer.
# input_transformer - (Optional) Parameters used when you are providing a custom input to a target based on certain event data. Conflicts with input and input_path.
resource "aws_cloudwatch_event_target" "aws_service" {
  for_each = {
    for target in var.aws_service_targets :
    target.id => target
  }

  event_bus_name = var.event_bus
  rule           = aws_cloudwatch_event_rule.this.name


  ## Target
  target_id = each.key
  arn = (
    each.value.type == "CLOUDWATCH_LOG_GROUP"
    ? each.value.cloudwatch_log_group.arn
    : each.value.type == "SNS_TOPIC"
    ? each.value.sns_topic.arn
    : each.value.type == "SQS_QUEUE"
    ? each.value.sqs_queue.arn
    : each.value.type == "SSM_RUN_COMMAND"
    ? each.value.ssm_run_command.document
    : null
  )

  dynamic "sqs_target" {
    for_each = each.value.type == "SQS_QUEUE" ? [each.value.sqs_queue] : []
    iterator = target

    content {
      message_group_id = target.value.message_group_id
    }
  }
  dynamic "run_command_targets" {
    for_each = each.value.type == "SSM_RUN_COMMAND" ? each.value.ssm_run_command.target_selector : {}
    iterator = target

    content {
      key    = target.key
      values = target.value
    }
  }


  ## Permissions
  role_arn = (local.aws_service_types[each.value.type].support_execution_role
    ? (each.value.execution_role != null
      ? each.value.execution_role
      : (var.default_execution_role.enabled ? module.role[0].arn : null)
    )
    : null
  )


  ## Config
  dynamic "dead_letter_config" {
    for_each = each.value.dead_letter_queue.enabled ? [each.value.dead_letter_queue] : []
    iterator = config

    content {
      arn = config.value.sqs_queue
    }
  }
  retry_policy {
    maximum_event_age_in_seconds = each.value.retry_policy.maximum_event_age
    maximum_retry_attempts       = each.value.retry_policy.maximum_retry_attempts
  }
}
