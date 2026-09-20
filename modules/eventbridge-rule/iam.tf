data "aws_partition" "this" {}
data "aws_caller_identity" "this" {}
data "aws_region" "this" {
  region = var.region
}

locals {
  partition  = data.aws_partition.this.partition
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.region
}


###################################################
# IAM Role for Event Bus Rule
###################################################

module "role" {
  count = var.default_execution_role.enabled ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.33.0"

  name = coalesce(
    var.default_execution_role.name,
    "aws-eventbridge-${var.event_bus}-rule-${var.name}"
  )
  path        = var.default_execution_role.path
  description = var.default_execution_role.description

  trusted_service_policies = [
    {
      services = ["events.amazonaws.com"]
      conditions = [{
        key       = "aws:SourceAccount"
        condition = "StringEquals"
        values    = [local.account_id]
      }]
    }
  ]

  policies = var.default_execution_role.policies
  inline_policies = merge(
    (one(data.aws_iam_policy_document.event_bus) != null
      ? {
        "event-bus-targets" = one(data.aws_iam_policy_document.event_bus).json
      }
      : {}
    ),
    (one(data.aws_iam_policy_document.ssm_run_commands) != null
      ? {
        "ssm-run-command-targets" = one(data.aws_iam_policy_document.ssm_run_commands).json
      }
      : {}
    ),
    (one(data.aws_iam_policy_document.batch_jobs) != null
      ? {
        "batch-job-targets" = one(data.aws_iam_policy_document.batch_jobs).json
      }
      : {}
    ),
    (one(data.aws_iam_policy_document.ecs_tasks) != null
      ? {
        "ecs-task-targets" = one(data.aws_iam_policy_document.ecs_tasks).json
      }
      : {}
    ),
    (one(data.aws_iam_policy_document.firehose_delivery_streams) != null
      ? {
        "firehose-delivery-stream-targets" = one(data.aws_iam_policy_document.firehose_delivery_streams).json
      }
      : {}
    ),
    (one(data.aws_iam_policy_document.kinesis_streams) != null
      ? {
        "kinesis-stream-targets" = one(data.aws_iam_policy_document.kinesis_streams).json
      }
      : {}
    ),
    (one(data.aws_iam_policy_document.redshift_clusters) != null
      ? {
        "redshift-cluster-targets" = one(data.aws_iam_policy_document.redshift_clusters).json
      }
      : {}
    ),
    (one(data.aws_iam_policy_document.sagemaker_pipelines) != null
      ? {
        "sagemaker-pipeline-targets" = one(data.aws_iam_policy_document.sagemaker_pipelines).json
      }
      : {}
    ),
    (one(data.aws_iam_policy_document.sfn_state_machines) != null
      ? {
        "sfn-state-machine-targets" = one(data.aws_iam_policy_document.sfn_state_machines).json
      }
      : {}
    ),
    var.default_execution_role.inline_policies
  )

  permissions_boundary = var.default_execution_role.permissions_boundary

  force_detach_policies = true

  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}


###################################################
# Resource Policy for Event Bus Rule
###################################################

data "aws_iam_policy_document" "event_bus" {
  count = (var.default_execution_role.enabled && length(var.event_bus_targets) > 0) ? 1 : 0

  statement {
    sid = "AllowEventBusTargets"

    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = var.event_bus_targets[*].event_bus
  }
}

data "aws_iam_policy_document" "ssm_run_commands" {
  count = length(keys(data.aws_iam_policy_document.ssm_run_command)) > 0 ? 1 : 0

  source_policy_documents = values(data.aws_iam_policy_document.ssm_run_command)[*].json
}

data "aws_iam_policy_document" "ssm_run_command" {
  for_each = {
    for target in var.aws_service_targets :
    target.id => target
    if var.default_execution_role.enabled && target.type == "SSM_RUN_COMMAND"
  }

  statement {
    effect    = "Allow"
    actions   = ["ssm:SendCommand"]
    resources = ["arn:${local.partition}:ssm:${local.region}:*:document/${regex("/([0-9A-Za-z_-]+)$", each.value.ssm_run_command.document)[0]}"]
  }

  dynamic "statement" {
    for_each = {
      for k, v in each.value.ssm_run_command.target_selector :
      k => v
      if k == "InstanceIds"
    }

    content {
      effect  = "Allow"
      actions = ["ssm:SendCommand"]
      resources = [
        for instance_id in statement.value :
        "arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/${instance_id}"
      ]
    }
  }
  dynamic "statement" {
    for_each = length([
      for k in keys(each.value.ssm_run_command.target_selector) :
      k
      if startswith(k, "tag:")
    ]) > 0 ? ["go"] : []

    content {
      effect    = "Allow"
      actions   = ["ssm:SendCommand"]
      resources = ["arn:${local.partition}:ec2:${local.region}:${local.account_id}:instance/*"]

      dynamic "condition" {
        for_each = {
          for k, v in each.value.ssm_run_command.target_selector :
          k => v
          if startswith(k, "tag:")
        }

        content {
          variable = condition.key
          test     = "StringEquals"
          values   = condition.value
        }
      }
    }
  }
}


locals {
  batch_job_definition_arns = distinct([
    for target in local.aws_service_targets_by_type["BATCH_JOB"] :
    (strcontains(target.batch_job.job_definition, ":job-definition/")
      ? target.batch_job.job_definition
      : "arn:${local.partition}:batch:${local.region}:${local.account_id}:job-definition/${target.batch_job.job_definition}"
    )
  ])
}

data "aws_iam_policy_document" "batch_jobs" {
  count = (var.default_execution_role.enabled && length(local.aws_service_targets_by_type["BATCH_JOB"]) > 0) ? 1 : 0

  statement {
    sid = "AllowBatchJobTargets"

    effect  = "Allow"
    actions = ["batch:SubmitJob"]
    resources = distinct(concat(
      local.aws_service_targets_by_type["BATCH_JOB"][*].batch_job.job_queue,
      local.batch_job_definition_arns,
      [
        for arn in local.batch_job_definition_arns :
        "${replace(arn, "/:[0-9]+$/", "")}:*"
      ],
    ))
  }
}

data "aws_iam_policy_document" "ecs_tasks" {
  count = (var.default_execution_role.enabled && length(local.aws_service_targets_by_type["ECS_TASK"]) > 0) ? 1 : 0

  statement {
    sid = "AllowEcsTaskTargets"

    effect  = "Allow"
    actions = ["ecs:RunTask"]
    resources = distinct([
      for target in local.aws_service_targets_by_type["ECS_TASK"] :
      "${replace(target.ecs_task.task_definition, "/:[0-9]+$/", "")}:*"
    ])

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = distinct(local.aws_service_targets_by_type["ECS_TASK"][*].ecs_task.cluster)
    }
  }

  statement {
    sid = "AllowEcsTaskTagging"

    effect    = "Allow"
    actions   = ["ecs:TagResource"]
    resources = ["arn:${local.partition}:ecs:${local.region}:${local.account_id}:task/*"]

    condition {
      test     = "StringEquals"
      variable = "ecs:CreateAction"
      values   = ["RunTask"]
    }
  }

  statement {
    sid = "AllowPassRoleToEcsTasks"

    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose_delivery_streams" {
  count = (var.default_execution_role.enabled && length(local.aws_service_targets_by_type["FIREHOSE_DELIVERY_STREAM"]) > 0) ? 1 : 0

  statement {
    sid = "AllowFirehoseDeliveryStreamTargets"

    effect = "Allow"
    actions = [
      "firehose:PutRecord",
      "firehose:PutRecordBatch",
    ]
    resources = local.aws_service_targets_by_type["FIREHOSE_DELIVERY_STREAM"][*].firehose_delivery_stream.arn
  }
}

data "aws_iam_policy_document" "kinesis_streams" {
  count = (var.default_execution_role.enabled && length(local.aws_service_targets_by_type["KINESIS_STREAM"]) > 0) ? 1 : 0

  statement {
    sid = "AllowKinesisStreamTargets"

    effect = "Allow"
    actions = [
      "kinesis:PutRecord",
      "kinesis:PutRecords",
    ]
    resources = local.aws_service_targets_by_type["KINESIS_STREAM"][*].kinesis_stream.arn
  }
}

locals {
  redshift_cluster_targets_with_db_user = [
    for target in local.aws_service_targets_by_type["REDSHIFT_CLUSTER"] :
    target
    if target.redshift_cluster.db_user != null
  ]
  redshift_cluster_targets_with_secret = [
    for target in local.aws_service_targets_by_type["REDSHIFT_CLUSTER"] :
    target
    if target.redshift_cluster.secret != null
  ]
}

data "aws_iam_policy_document" "redshift_clusters" {
  count = (var.default_execution_role.enabled && length(local.aws_service_targets_by_type["REDSHIFT_CLUSTER"]) > 0) ? 1 : 0

  statement {
    sid = "AllowRedshiftClusterTargets"

    effect = "Allow"
    actions = [
      "redshift-data:ExecuteStatement",
      "redshift-data:BatchExecuteStatement",
    ]
    resources = distinct(local.aws_service_targets_by_type["REDSHIFT_CLUSTER"][*].redshift_cluster.arn)
  }

  dynamic "statement" {
    for_each = length(local.redshift_cluster_targets_with_db_user) > 0 ? ["go"] : []

    content {
      sid = "AllowRedshiftClusterCredentials"

      effect  = "Allow"
      actions = ["redshift:GetClusterCredentials"]
      resources = distinct(flatten([
        for target in local.redshift_cluster_targets_with_db_user : [
          "arn:${local.partition}:redshift:${local.region}:${local.account_id}:dbuser:${regex(":cluster:(.+)$", target.redshift_cluster.arn)[0]}/${target.redshift_cluster.db_user}",
          "arn:${local.partition}:redshift:${local.region}:${local.account_id}:dbname:${regex(":cluster:(.+)$", target.redshift_cluster.arn)[0]}/${target.redshift_cluster.database}",
        ]
      ]))
    }
  }

  dynamic "statement" {
    for_each = length(local.redshift_cluster_targets_with_secret) > 0 ? ["go"] : []

    content {
      sid = "AllowRedshiftClusterSecrets"

      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = distinct(local.redshift_cluster_targets_with_secret[*].redshift_cluster.secret)
    }
  }
}

data "aws_iam_policy_document" "sagemaker_pipelines" {
  count = (var.default_execution_role.enabled && length(local.aws_service_targets_by_type["SAGEMAKER_PIPELINE"]) > 0) ? 1 : 0

  statement {
    sid = "AllowSagemakerPipelineTargets"

    effect    = "Allow"
    actions   = ["sagemaker:StartPipelineExecution"]
    resources = distinct(local.aws_service_targets_by_type["SAGEMAKER_PIPELINE"][*].sagemaker_pipeline.arn)
  }
}

data "aws_iam_policy_document" "sfn_state_machines" {
  count = (var.default_execution_role.enabled && length(local.aws_service_targets_by_type["SFN_STATE_MACHINE"]) > 0) ? 1 : 0

  statement {
    sid = "AllowSfnStateMachineTargets"

    effect    = "Allow"
    actions   = ["states:StartExecution"]
    resources = local.aws_service_targets_by_type["SFN_STATE_MACHINE"][*].sfn_state_machine.arn
  }
}
