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

data "aws_subnet" "this" {
  region = var.region

  id = var.subnets[0]
}

locals {
  vpc_id = data.aws_subnet.this.vpc_id

  security_groups = concat(module.security_group[*].id, var.security_groups)
}


###################################################
# MSK VPC Connection
###################################################

resource "aws_msk_vpc_connection" "this" {
  region = var.region

  target_cluster_arn = var.cluster
  authentication     = var.authentication

  vpc_id          = local.vpc_id
  client_subnets  = var.subnets
  security_groups = local.security_groups

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )

  lifecycle {
    precondition {
      condition     = length(local.security_groups) > 0
      error_message = "At least one security group is required. Enable `default_security_group` or provide `security_groups`."
    }
  }
}
