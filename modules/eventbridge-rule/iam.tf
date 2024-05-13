data "aws_partition" "this" {}
data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

locals {
  partition  = data.aws_partition.this.partition
  account_id = data.aws_caller_identity.this.account_id
  region     = data.aws_region.this.name
}


###################################################
# IAM Role for Event Bus Rule
###################################################

module "role" {
  count = var.default_execution_role.enabled ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.30.0"

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
    var.default_execution_role.inline_policies
  )

  force_detach_policies  = true
  resource_group_enabled = false
  module_tags_enabled    = false

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
