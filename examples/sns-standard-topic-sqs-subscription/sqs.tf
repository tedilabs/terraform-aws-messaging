resource "aws_sqs_queue" "example" {
  name = "sqs-queue-for-sns-topic"
}

resource "aws_sqs_queue_policy" "example" {
  queue_url = aws_sqs_queue.example.id
  policy    = data.aws_iam_policy_document.sqs_example.json
}

resource "aws_sqs_queue" "dlq" {
  name = "sqs-dead-letter-queue-for-sns-topic"
}

resource "aws_sqs_queue_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id
  policy    = data.aws_iam_policy_document.sqs_dlq.json
}

data "aws_iam_policy_document" "sqs_example" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = [
      aws_sqs_queue.example.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        module.topic.arn,
      ]
    }
  }
}

data "aws_iam_policy_document" "sqs_dlq" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = [
      aws_sqs_queue.dlq.arn,
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        module.topic.arn,
      ]
    }
  }
}
