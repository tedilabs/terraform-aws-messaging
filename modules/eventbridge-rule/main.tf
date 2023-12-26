locals {
  metadata = {
    package = "terraform-aws-messaging"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}


###################################################
# Rule of Event Bus on EventBridge
###################################################

# INFO: Not supported attributes
# - `is_enabled`
# - `name_prefix`
resource "aws_cloudwatch_event_rule" "this" {
  event_bus_name = var.event_bus

  name        = var.name
  description = var.description
  state       = var.state


  ## Permissions
  role_arn = (var.default_execution_role.enabled
    ? module.role[0].arn
    : var.execution_role
  )


  ## Triggers
  event_pattern       = var.trigger.event_pattern
  schedule_expression = var.trigger.schedule_expression


  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    precondition {
      condition = (length(var.event_bus_targets)
        + length(var.api_destination_targets)
        + length(var.aws_service_targets)
      ) <= 5
      error_message = "A maximum of 5 targets are allowed."
    }
  }
}
