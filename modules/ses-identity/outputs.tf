output "arn" {
  description = "The ARN of the SES identity."
  value       = aws_sesv2_email_identity.this.arn
}

output "id" {
  description = "The ID of the SES identity."
  value       = aws_sesv2_email_identity.this.id
}

output "status" {
  description = "The status of the SES identity."
  value       = aws_sesv2_email_identity.this.verified_for_sending_status ? "VERIFIED" : "PENDING"
}

output "name" {
  description = "The domain name for the SES identity."
  value       = aws_sesv2_email_identity.this.email_identity
}

output "type" {
  description = "The type of the SES identity."
  value       = aws_sesv2_email_identity.this.identity_type
}

output "configuration_set" {
  description = "The configuration set to use by default when sending from this identity."
  value       = aws_sesv2_email_identity.this.configuration_set_name
}

output "dkim" {
  description = "The configuration for the DKIM."
  value = {
    type                     = var.dkim.type
    status                   = one(aws_sesv2_email_identity.this.dkim_signing_attributes[*].status)
    current_signing_key_type = local.signing_key_type_reverse[one(aws_sesv2_email_identity.this.dkim_signing_attributes[*].current_signing_key_length)]
    signing_key_type         = local.signing_key_type_reverse[one(aws_sesv2_email_identity.this.dkim_signing_attributes[*].next_signing_key_length)]
    selector_name            = one(aws_sesv2_email_identity.this.dkim_signing_attributes[*].domain_signing_selector)
    origin                   = one(aws_sesv2_email_identity.this.dkim_signing_attributes[*].signing_attributes_origin)
    last_key_generated_at    = one(aws_sesv2_email_identity.this.dkim_signing_attributes[*].last_key_generation_timestamp)

    verification = {
      enabled = var.dkim.verification.enabled
      zone = {
        id = var.dkim.verification.zone_id
      }
      records = [
        for record in aws_route53_record.dkim : {
          name  = record.name
          value = record.records
          type  = record.type
          ttl   = record.ttl
        }
      ]
    }
  }
}

# output "debug" {
#   value = {
#     for k, v in aws_sesv2_email_identity.this :
#     k => v
#     if !contains(["arn", "id", "email_identity", "identity_type", "tags", "tags_all", "dkim_signing_attributes", "verified_for_sending_status", "configuration_set_name"], k)
#   }
# }