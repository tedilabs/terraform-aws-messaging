data "aws_caller_identity" "this" {}

###################################################
# IAM Role for Event Bus Rule
###################################################

module "role" {
  count = var.default_execution_role.enabled ? 1 : 0

  source  = "tedilabs/account/aws//modules/iam-role"
  version = "~> 0.28.0"

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
        values    = [data.aws_caller_identity.this.account_id]
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

