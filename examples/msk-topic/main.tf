provider "aws" {
  region = "us-east-1"
}

locals {
  cluster_arn = "arn:aws:kafka:us-east-1:123456789012:cluster/example/a1b2c3d4-5678-90ab-cdef-11111EXAMPLE-1"
}


###################################################
# MSK Topics
###################################################

module "topic" {
  source = "../../modules/msk-topic"
  # source  = "tedilabs/messaging/aws//modules/msk-topic"
  # version = "~> 0.9.0"

  cluster = local.cluster_arn
  name    = "orders"

  partition_count    = 6
  replication_factor = 3

  configs = {
    "cleanup.policy"      = "delete"
    "retention.ms"        = "604800000"
    "min.insync.replicas" = "2"
  }
}

module "compacted_topic" {
  source = "../../modules/msk-topic"
  # source  = "tedilabs/messaging/aws//modules/msk-topic"
  # version = "~> 0.9.0"

  cluster = local.cluster_arn
  name    = "orders-state"

  partition_count    = 3
  replication_factor = 3

  configs = {
    "cleanup.policy"      = "compact"
    "min.insync.replicas" = "2"
  }
}
