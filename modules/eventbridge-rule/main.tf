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

# role_arn - (Optional) The Amazon Resource Name (ARN) associated with the role that is used for target invocation.
# INFO: Not supported attributes
# - `is_enabled`
# - `name_prefix`
resource "aws_cloudwatch_event_rule" "this" {
  event_bus_name = var.event_bus

  name        = var.name
  description = var.description
  state       = var.state


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
}


###################################################
# Rule Targets
###################################################

# resource "aws_cloudwatch_event_target" "this" {
#   count = var.policy != null ? 1 : 0
#
#   event_bus_name = aws_cloudwatch_event_bus.this.name
#   policy         = var.policy
# }
