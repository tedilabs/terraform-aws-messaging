terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.12"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6"
    }
  }
}
