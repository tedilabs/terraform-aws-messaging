output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_msk_vpc_connection.this.region
}

output "arn" {
  description = "The ARN of the VPC connection."
  value       = aws_msk_vpc_connection.this.arn
}

output "id" {
  description = "The ID of the VPC connection."
  value       = aws_msk_vpc_connection.this.id
}

output "name" {
  description = "The name to identify the VPC connection."
  value       = local.metadata.name
}

output "cluster" {
  description = "The ARN of the MSK cluster which the VPC connection connects to."
  value       = aws_msk_vpc_connection.this.target_cluster_arn
}

output "authentication" {
  description = "The authentication type of the clients which connect through the VPC connection."
  value       = aws_msk_vpc_connection.this.authentication
}

output "vpc_id" {
  description = "The ID of the client VPC of the VPC connection."
  value       = aws_msk_vpc_connection.this.vpc_id
}

output "subnets" {
  description = "A list of subnet IDs in the client VPC where the endpoints of the VPC connection are placed."
  value       = aws_msk_vpc_connection.this.client_subnets
}

output "security_groups" {
  description = "A list of security group IDs which are associated with the endpoints of the VPC connection."
  value       = aws_msk_vpc_connection.this.security_groups
}

output "default_security_group" {
  description = "The default security group of the VPC connection. `null` if `default_security_group.enabled` is `false`."
  value = (var.default_security_group.enabled
    ? {
      id   = module.security_group[0].id
      arn  = module.security_group[0].arn
      name = module.security_group[0].name
    }
    : null
  )
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}
