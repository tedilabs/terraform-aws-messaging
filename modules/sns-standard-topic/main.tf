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
  delivery_status_logging = {
    for type, config in var.delivery_status_logging :
    type => {
      success_feedback_role        = config.enabled ? config.success_feedback_role : null
      success_feedback_sample_rate = config.enabled ? config.success_feedback_sample_rate : null
      failure_feedback_role        = config.enabled ? config.failure_feedback_role : null
    }
  }
}


###################################################
# SNS Topic
###################################################

# INFO: Not supported attributes
# - `name_prefix`
# - `content_based_deduplication`
resource "aws_sns_topic" "this" {
  region = var.region

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

  ## Delivery Status Logging
  application_success_feedback_role_arn    = local.delivery_status_logging.application.success_feedback_role
  application_success_feedback_sample_rate = local.delivery_status_logging.application.success_feedback_sample_rate
  application_failure_feedback_role_arn    = local.delivery_status_logging.application.failure_feedback_role

  firehose_success_feedback_role_arn    = local.delivery_status_logging.firehose.success_feedback_role
  firehose_success_feedback_sample_rate = local.delivery_status_logging.firehose.success_feedback_sample_rate
  firehose_failure_feedback_role_arn    = local.delivery_status_logging.firehose.failure_feedback_role

  http_success_feedback_role_arn    = local.delivery_status_logging.http.success_feedback_role
  http_success_feedback_sample_rate = local.delivery_status_logging.http.success_feedback_sample_rate
  http_failure_feedback_role_arn    = local.delivery_status_logging.http.failure_feedback_role

  lambda_success_feedback_role_arn    = local.delivery_status_logging.lambda.success_feedback_role
  lambda_success_feedback_sample_rate = local.delivery_status_logging.lambda.success_feedback_sample_rate
  lambda_failure_feedback_role_arn    = local.delivery_status_logging.lambda.failure_feedback_role

  sqs_success_feedback_role_arn    = local.delivery_status_logging.sqs.success_feedback_role
  sqs_success_feedback_sample_rate = local.delivery_status_logging.sqs.success_feedback_sample_rate
  sqs_failure_feedback_role_arn    = local.delivery_status_logging.sqs.failure_feedback_role


  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
