terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

resource "random_pet" "name" {
  length = 4
}

output "name" {
  value = random_pet.name.id
}
