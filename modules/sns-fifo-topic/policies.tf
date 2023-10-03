###################################################
# Policy for SNS Topic
###################################################

data "aws_iam_policy_document" "this" {
  source_policy_documents = concat(
    []
  )
  override_policy_documents = var.policy != null ? [var.policy] : null
}

resource "aws_sns_topic_policy" "this" {
  count = var.policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json
}
