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
# SNS Topic
###################################################

resource "aws_sns_topic" "this" {
  name              = var.name

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Policy for SNS Topic
###################################################

resource "aws_sns_topic_policy" "this" {
  count = var.policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.policy
}


###################################################
# Data Protection Policy for SNS Topic
###################################################

resource "aws_sns_topic_data_protection_policy" "this" {
  count = var.data_protection_policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.data_protection_policy
}
