provider "aws" {
  region = "us-east-1"
}

locals {
  # The MSK cluster in another account or VPC, with multi-VPC private connectivity turned on for SASL/IAM.
  cluster_arn = "arn:aws:kafka:us-east-1:123456789012:cluster/example/a1b2c3d4-5678-90ab-cdef-11111EXAMPLE-1"

  # The subnets in the client VPC, in the same Availability Zone IDs as the broker subnets of the cluster.
  client_subnets = [
    "subnet-0123456789abcdef0",
    "subnet-0123456789abcdef1",
    "subnet-0123456789abcdef2",
  ]
}


###################################################
# MSK VPC Connection
###################################################

module "vpc_connection" {
  source = "../../modules/msk-vpc-connection"
  # source  = "tedilabs/messaging/aws//modules/msk-vpc-connection"
  # version = "~> 0.9.0"

  name = "example-iam"

  cluster        = local.cluster_arn
  authentication = "SASL_IAM"
  subnets        = local.client_subnets

  default_security_group = {
    enabled = true
    broker_ingress_ipv4_cidrs = [
      "10.0.0.0/16",
    ]
  }

  tags = {
    "project" = "terraform-aws-messaging-examples"
  }
}
