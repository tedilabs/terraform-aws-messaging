locals {
  dkim_verification_enabled = local.identity_type == "DOMAIN" && var.dkim.type == "EASY_DKIM" && var.dkim.verification.enabled
  tokens = (local.dkim_verification_enabled
    ? aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens
    : []
  )
  # INFO: https://docs.aws.amazon.com/general/latest/gr/ses.html#ses_dkim_domains
  # - Not all AWS Regions use the default SES DKIM domain, `dkim.amazonses.com`
  dkim_domains = {
    "default"        = "dkim.amazonses.com"
    "af-south-1"     = "dkim.af-south-1.amazonses.com"
    "ap-southeast-3" = "dkim.ap-southeast-3.amazonses.com"
    "ap-northeast-3" = "dkim.ap-northeast-3.amazonses.com"
    "eu-south-1"     = "dkim.eu-south-1.amazonses.com"
    "il-central-1"   = "dkim.il-central-1.amazonses.com"
    "us-gov-east-1"  = "dkim.us-gov-east-1.amazonses.com"
  }
  dkim_domain = lookup(local.dkim_domains, data.aws_region.current.name, local.dkim_domains["default"])
}

data "aws_region" "current" {}


###################################################
# DKIM Verification
###################################################

resource "aws_route53_record" "dkim" {
  count = local.dkim_verification_enabled ? 3 : 0

  zone_id = var.dkim.verification.zone_id
  name    = "${local.tokens[count.index]}._domainkey.${aws_sesv2_email_identity.this.email_identity}"
  type    = "CNAME"
  records = ["${local.tokens[count.index]}.${local.dkim_domain}"]

  ttl             = "600"
  allow_overwrite = true
}

