locals {
  metadata = {
    package = "terraform-aws-messaging"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

locals {
  signing_key_type = {
    "RSA_1024" = "RSA_1024_BIT"
    "RSA_2048" = "RSA_2048_BIT"
  }
  signing_key_type_reverse = {
    for k, v in local.signing_key_type : v => k
  }
  identity_type = strcontains(var.name, "@") ? "EMAIL_ADDRESS" : "DOMAIN"
}


###################################################
# SES Domain Identity
###################################################

resource "aws_sesv2_email_identity" "this" {
  email_identity         = var.name
  configuration_set_name = var.configuration_set

  dynamic "dkim_signing_attributes" {
    for_each = local.identity_type == "DOMAIN" ? ["go"] : []

    content {
      # Easy DKIM
      next_signing_key_length = (var.dkim.type == "EASY_DKIM"
        ? local.signing_key_type[var.dkim.signing_key_type]
        : null
      )

      # BYODKIM
      domain_signing_private_key = (var.dkim.type == "BYODKIM"
        ? var.dkim.private_key
        : null
      )
      domain_signing_selector = (var.dkim.type == "BYODKIM"
        ? var.dkim.selector_name
        : null
      )
    }
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Email Feedback Forwarding
###################################################

resource "aws_sesv2_email_identity_feedback_attributes" "this" {
  email_identity           = aws_sesv2_email_identity.this.email_identity
  email_forwarding_enabled = var.email_feedback_forwarding.enabled
}


###################################################
# Custom Mail From
###################################################

resource "aws_sesv2_email_identity_mail_from_attributes" "this" {
  count = var.custom_mail_from.enabled ? 1 : 0

  email_identity = aws_sesv2_email_identity.this.email_identity

  mail_from_domain       = var.custom_mail_from.domain
  behavior_on_mx_failure = var.custom_mail_from.behavior_on_mx_failure
}