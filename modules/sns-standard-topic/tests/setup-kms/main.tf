terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "kms_key" {
  source  = "tedilabs/secret/aws//modules/kms-key"
  version = "~> 0.3.0"

  name = var.name

  usage = "ENCRYPT_DECRYPT"
  spec  = "SYMMETRIC_DEFAULT"

  deletion_window_in_days = 7
}

variable "name" {
  type = string
}

output "key" {
  value = module.kms_key
}
