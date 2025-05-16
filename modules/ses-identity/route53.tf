###################################################
# DKIM Verification
###################################################

resource "aws_route53_record" "dkim" {
  for_each = (aws_sesv2_email_identity.this.identity_type == "DOMAIN" && var.dkim.type == "EASY_DKIM" && var.dkim.verification.enabled
    ? toset(aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens)
    : []
  )

  zone_id = var.dkim.verification.zone_id
  name    = "${each.key}._domainkey.${aws_sesv2_email_identity.this.email_identity}"
  type    = "CNAME"
  records = ["${each.key}.dkim.amazonses.com"]

  ttl             = "600"
  allow_overwrite = true
}