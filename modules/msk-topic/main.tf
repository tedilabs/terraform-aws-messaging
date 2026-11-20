locals {
  metadata = {
    package = "terraform-aws-messaging"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
}


###################################################
# MSK Topic
###################################################

resource "aws_msk_topic" "this" {
  region = var.region

  cluster_arn = var.cluster
  name        = var.name

  partition_count    = var.partition_count
  replication_factor = var.replication_factor

  configs = length(var.configs) > 0 ? jsonencode(var.configs) : null

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }
}
