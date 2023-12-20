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

output "archives" {
  description = "A list of archives for the event bus."
  value = [
    for archive in aws_cloudwatch_event_archive.this : {
      id                = archive.id
      arn               = archive.arn
      name              = archive.name
      description       = archive.description
      retention_in_days = archive.retention_days
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
