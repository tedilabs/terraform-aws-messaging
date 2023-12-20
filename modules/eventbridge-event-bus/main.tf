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

locals {
  is_default = var.name == "default"
  event_bus = (local.is_default
    ? data.aws_cloudwatch_event_bus.default[0]
    : aws_cloudwatch_event_bus.this[0]
  )
}


###################################################
# Event Bus on EventBridge
###################################################

data "aws_cloudwatch_event_bus" "default" {
  count = local.is_default ? 1 : 0

  name = "default"
}

resource "aws_cloudwatch_event_bus" "this" {
  count = local.is_default ? 0 : 1

  name              = var.name
  event_source_name = startswith(var.name, "aws.partner/") ? var.name : null

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Event Bus Policy
###################################################

resource "aws_cloudwatch_event_bus_policy" "this" {
  count = var.policy != null ? 1 : 0

  event_bus_name = local.event_bus.name
  policy         = var.policy
}


###################################################
# Event Bus Archives
###################################################

resource "aws_cloudwatch_event_archive" "this" {
  for_each = {
    for archive in var.archives :
    archive.name => archive
  }

  event_source_arn = local.event_bus.arn

  name           = each.key
  description    = each.value.description
  retention_days = each.value.retention_in_days

  event_pattern = each.value.event_pattern
}


###################################################
# Schema Discovery of Event Bus
###################################################

resource "aws_schemas_discoverer" "this" {
  count = var.schema_discovery.enabled ? 1 : 0

  source_arn  = local.event_bus.arn
  description = var.schema_discovery.description

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
