locals {
  aws_service_types = {
    "BATCH_JOB" = {
      support_execution_role = true
    }
    "CLOUDWATCH_LOG_GROUP" = {
      support_execution_role = false
    }
    "ECS_TASK" = {
      support_execution_role = true
    }
    "FIREHOSE_DELIVERY_STREAM" = {
      support_execution_role = true
    }
    "KINESIS_STREAM" = {
      support_execution_role = true
    }
    "LAMBDA_FUNCTION" = {
      support_execution_role = false
    }
    "REDSHIFT_CLUSTER" = {
      support_execution_role = true
    }
    "SAGEMAKER_PIPELINE" = {
      support_execution_role = true
    }
    "SFN_STATE_MACHINE" = {
      support_execution_role = true
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
  aws_service_targets_by_type = {
    for type in keys(local.aws_service_types) :
    type => [
      for target in var.aws_service_targets :
      target
      if target.type == type
    ]
  }
  aws_service_target_arns = {
    for target in var.aws_service_targets :
    target.id => {
      "BATCH_JOB"                = try(target.batch_job.job_queue, null)
      "CLOUDWATCH_LOG_GROUP"     = try(target.cloudwatch_log_group.arn, null)
      "ECS_TASK"                 = try(target.ecs_task.cluster, null)
      "FIREHOSE_DELIVERY_STREAM" = try(target.firehose_delivery_stream.arn, null)
      "KINESIS_STREAM"           = try(target.kinesis_stream.arn, null)
      "LAMBDA_FUNCTION"          = try(target.lambda_function.arn, null)
      "REDSHIFT_CLUSTER"         = try(target.redshift_cluster.arn, null)
      "SAGEMAKER_PIPELINE"       = try(target.sagemaker_pipeline.arn, null)
      "SFN_STATE_MACHINE"        = try(target.sfn_state_machine.arn, null)
      "SNS_TOPIC"                = try(target.sns_topic.arn, null)
      "SQS_QUEUE"                = try(target.sqs_queue.arn, null)
      "SSM_RUN_COMMAND"          = try(target.ssm_run_command.document, null)
    }[target.type]
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

  region = var.region

  event_bus_name = var.event_bus
  rule           = aws_cloudwatch_event_rule.this.name

  force_destroy = var.force_destroy

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
  retry_policy {
    maximum_event_age_in_seconds = each.value.retry_policy.maximum_event_age
    maximum_retry_attempts       = each.value.retry_policy.maximum_retry_attempts
  }
}


###################################################
# Rule Targets (API Destination)
###################################################

resource "aws_cloudwatch_event_target" "api_destination" {
  for_each = {
    for target in var.api_destination_targets :
    target.id => target
  }

  region = var.region

  event_bus_name = var.event_bus
  rule           = aws_cloudwatch_event_rule.this.name

  force_destroy = var.force_destroy

  target_id = each.key
  arn       = each.value.api_destination

  dynamic "http_target" {
    for_each = anytrue([
      length(each.value.http.headers) > 0,
      length(each.value.http.path_parameters) > 0,
      length(each.value.http.query_parameters) > 0,
    ]) ? [each.value.http] : []
    iterator = http

    content {
      header_parameters       = http.value.headers
      path_parameter_values   = http.value.path_parameters
      query_string_parameters = http.value.query_parameters
    }
  }


  ## Target Input
  input      = each.value.input.type == "CONSTANT" ? each.value.input.value : null
  input_path = each.value.input.type == "JSON_PATH" ? each.value.input.value : null

  dynamic "input_transformer" {
    for_each = each.value.input.type == "TRANSFORMER" ? [each.value.input] : []
    iterator = input

    content {
      input_paths    = input.value.reference_variables
      input_template = input.value.value
    }
  }


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

# TODO: Support `http_target`, `appsync_target`

resource "aws_cloudwatch_event_target" "aws_service" {
  for_each = {
    for target in var.aws_service_targets :
    target.id => target
  }

  region = var.region

  event_bus_name = var.event_bus
  rule           = aws_cloudwatch_event_rule.this.name

  force_destroy = var.force_destroy


  ## Target
  target_id = each.key
  arn       = local.aws_service_target_arns[each.key]

  dynamic "batch_target" {
    for_each = each.value.type == "BATCH_JOB" ? [each.value.batch_job] : []
    iterator = target

    content {
      job_definition = target.value.job_definition
      job_name       = target.value.job_name
      array_size     = target.value.array_size
      job_attempts   = target.value.job_attempts
    }
  }
  dynamic "ecs_target" {
    for_each = each.value.type == "ECS_TASK" ? [each.value.ecs_task] : []
    iterator = target

    content {
      task_definition_arn = target.value.task_definition
      task_count          = target.value.task_count
      launch_type         = target.value.launch_type
      platform_version    = target.value.platform_version
      group               = target.value.group

      dynamic "network_configuration" {
        for_each = target.value.network != null ? [target.value.network] : []
        iterator = network

        content {
          subnets          = network.value.subnets
          security_groups  = network.value.security_groups
          assign_public_ip = network.value.public_ip_enabled
        }
      }
      dynamic "capacity_provider_strategy" {
        for_each = target.value.capacity_provider_strategies
        iterator = strategy

        content {
          capacity_provider = strategy.value.capacity_provider
          weight            = strategy.value.weight
          base              = strategy.value.base
        }
      }
      dynamic "placement_constraint" {
        for_each = target.value.placement_constraints
        iterator = constraint

        content {
          type       = constraint.value.type
          expression = constraint.value.expression
        }
      }
      dynamic "ordered_placement_strategy" {
        for_each = target.value.placement_strategies
        iterator = strategy

        content {
          type  = strategy.value.type
          field = strategy.value.field
        }
      }

      propagate_tags          = target.value.propagate_tags_enabled ? "TASK_DEFINITION" : null
      enable_ecs_managed_tags = target.value.ecs_managed_tags_enabled
      enable_execute_command  = target.value.execute_command_enabled
      tags                    = target.value.tags
    }
  }
  dynamic "kinesis_target" {
    for_each = each.value.type == "KINESIS_STREAM" ? [each.value.kinesis_stream] : []
    iterator = target

    content {
      partition_key_path = target.value.partition_key_path
    }
  }
  dynamic "redshift_target" {
    for_each = each.value.type == "REDSHIFT_CLUSTER" ? [each.value.redshift_cluster] : []
    iterator = target

    content {
      database            = target.value.database
      db_user             = target.value.db_user
      secrets_manager_arn = target.value.secret
      sql                 = target.value.sql
      statement_name      = target.value.statement_name
      with_event          = target.value.with_event_enabled
    }
  }
  dynamic "sagemaker_pipeline_target" {
    for_each = each.value.type == "SAGEMAKER_PIPELINE" ? [each.value.sagemaker_pipeline] : []
    iterator = target

    content {
      dynamic "pipeline_parameter_list" {
        for_each = target.value.parameters
        iterator = parameter

        content {
          name  = parameter.key
          value = parameter.value
        }
      }
    }
  }
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


  ## Target Input
  input      = each.value.input.type == "CONSTANT" ? each.value.input.value : null
  input_path = each.value.input.type == "JSON_PATH" ? each.value.input.value : null

  dynamic "input_transformer" {
    for_each = each.value.input.type == "TRANSFORMER" ? [each.value.input] : []
    iterator = input

    content {
      input_paths    = input.value.reference_variables
      input_template = input.value.value
    }
  }

  dynamic "input_transformer" {
    for_each = (each.value.input.type == "CHATBOT_CUSTOM_NOTIFICATION"
      ? [{
        reference_variables = each.value.input.reference_variables
        value               = jsondecode(each.value.input.value)
      }]
      : []
    )
    iterator = input

    content {
      input_paths = input.value.reference_variables
      input_template = replace(replace(jsonencode({
        "version" = "1.0"
        "source"  = "custom"
        "id"      = try(input.value.value.id, null)
        "content" = {
          "textType"    = "client-markdown"
          "title"       = try(input.value.value.title, null)
          "description" = input.value.value.text
          "nextSteps"   = try(input.value.value.next_steps, [])
          "keywords"    = try(input.value.value.keywords, [])
        }
        "metadata" = {
          "additionalContext" = merge(
            {
              for k, v in input.value.reference_variables :
              k => "<${k}>"
            },
            try(input.value.value.additional_context, {}),
          )
        }
      }), "\\u003e", ">"), "\\u003c", "<")
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
