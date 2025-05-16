locals {
  dkim_verification_enabled = local.identity_type == "DOMAIN" && var.dkim.type == "EASY_DKIM" && var.dkim.verification.enabled
  tokens = (local.dkim_verification_enabled
    ? aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens
    : []
  )
}


###################################################
# DKIM Verification
###################################################

resource "aws_route53_record" "dkim" {
  count = local.dkim_verification_enabled ? 3 : 0

  zone_id = var.dkim.verification.zone_id
  name    = "${local.tokens[count.index]}._domainkey.${aws_sesv2_email_identity.this.email_identity}"
  type    = "CNAME"
  records = ["${local.tokens[count.index]}.dkim.amazonses.com"]

  ttl             = "600"
  allow_overwrite = true
}

