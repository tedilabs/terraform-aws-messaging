###################################################
# Authorization Policies
###################################################

resource "aws_sesv2_email_identity_policy" "this" {
  for_each = var.policies

  email_identity = aws_sesv2_email_identity.this.email_identity

  policy_name = each.key
  policy      = each.value
}