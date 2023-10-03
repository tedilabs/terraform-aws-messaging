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


###################################################
# SNS Topic
###################################################

# INFO: Not supported attributes
# - `name_prefix`
# - `content_based_deduplication`
resource "aws_sns_topic" "this" {
  name         = var.name
  display_name = var.display_name
  fifo_topic   = false

  delivery_policy = var.delivery_policy


  ## Observability
  tracing_config = (var.xray_tracing_enabled
    ? "Active"
    : "PassThrough"
  )


  ## Encryption
  signature_version = var.signature_version
  kms_master_key_id = (var.encryption_at_rest.enabled
    ? var.encryption_at_rest.kms_key
    : null
  )

  # application_success_feedback_role_arn - (Optional) The IAM role permitted to receive success feedback for this topic
  # application_success_feedback_sample_rate - (Optional) Percentage of success to sample
  # application_failure_feedback_role_arn - (Optional) IAM role for failure feedback

  # http_success_feedback_role_arn - (Optional) The IAM role permitted to receive success feedback for this topic
  # http_success_feedback_sample_rate - (Optional) Percentage of success to sample
  # http_failure_feedback_role_arn - (Optional) IAM role for failure feedback

  # lambda_success_feedback_role_arn - (Optional) The IAM role permitted to receive success feedback for this topic
  # lambda_success_feedback_sample_rate - (Optional) Percentage of success to sample
  # lambda_failure_feedback_role_arn - (Optional) IAM role for failure feedback

  # sqs_success_feedback_role_arn - (Optional) The IAM role permitted to receive success feedback for this topic
  # sqs_success_feedback_sample_rate - (Optional) Percentage of success to sample
  # sqs_failure_feedback_role_arn - (Optional) IAM role for failure feedback

  # firehose_success_feedback_role_arn - (Optional) The IAM role permitted to receive success feedback for this topic
  # firehose_success_feedback_sample_rate - (Optional) Percentage of success to sample
  # firehose_failure_feedback_role_arn

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
