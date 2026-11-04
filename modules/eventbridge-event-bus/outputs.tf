output "region" {
  description = "The AWS region this module resources resides in."
  value       = local.event_bus.region
}

output "id" {
  description = "The unique identifier for the event bus."
  value       = local.event_bus.id
}

output "arn" {
  description = "The Amazon Resource Name (ARN) of the event bus."
  value       = local.event_bus.arn
}

output "name" {
  description = "The name of the event bus."
  value       = local.event_bus.name
}

output "description" {
  description = "The description of the event bus."
  value       = local.event_bus.description
}

output "encryption_at_rest" {
  description = "The configuration to encrypt events at rest in the event bus."
  value = {
    kms_key = local.event_bus.kms_key_identifier
  }
}

output "dead_letter_queue" {
  description = "The configuration for the dead-letter queue of the event bus."
  value = {
    enabled   = try(local.event_bus.dead_letter_config[0].arn, null) != null
    sqs_queue = try(local.event_bus.dead_letter_config[0].arn, null)
  }
}

output "logging" {
  description = "The configuration for logging of the event bus."
  value = {
    level                  = try(local.event_bus.log_config[0].level, "OFF")
    include_detail_enabled = try(local.event_bus.log_config[0].include_detail, "NONE") == "FULL"
  }
}

output "archives" {
  description = "A list of archives for the event bus."
  value = [
    for archive in aws_cloudwatch_event_archive.this : {
      id                = archive.id
      arn               = archive.arn
      name              = archive.name
      description       = archive.description
      retention_in_days = archive.retention_days
      event_pattern     = archive.event_pattern
      kms_key           = archive.kms_key_identifier
    }
  ]
}

output "schema_discovery" {
  description = "The configuration for schema discovery of the event bus."
  value = {
    enabled = var.schema_discovery.enabled
    discoverer = (var.schema_discovery.enabled
      ? {
        id          = one(aws_schemas_discoverer.this[*].id)
        arn         = one(aws_schemas_discoverer.this[*].arn)
        description = one(aws_schemas_discoverer.this[*].description)
      }
      : null
    )
  }
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
