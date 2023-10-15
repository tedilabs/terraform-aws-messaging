provider "aws" {
  region = "us-east-1"
}


###################################################
# Setup
###################################################

run "setup_variables" {
  module {
    source = "./tests/setup-variables"
  }
}

run "setup_kms" {
  variables {
    name = run.setup_variables.name
  }

  module {
    source = "./tests/setup-kms"
  }
}


###################################################
# Tests
###################################################

run "test_encryption_at_rest_defaults" {
  command = apply

  variables {
    name = run.setup_variables.name

    encryption_at_rest = {}
  }

  assert {
    condition     = !output.encryption_at_rest.enabled
    error_message = "At-rest encryption of the SNS topic should be disabled by default."
  }

  assert {
    condition     = length(compact([
      output.encryption_at_rest.kms_key,
      aws_sns_topic.this.kms_master_key_id,
    ])) == 0
    error_message = "The KMS key ID for at-rest encryption of the SNS topic should be empty by default."
  }
}


run "test_encryption_at_rest_enabled" {
  command = apply

  variables {
    name = run.setup_variables.name

    encryption_at_rest = {
      enabled = true
      kms_key = run.setup_kms.key.id
    }
  }

  assert {
    condition     = output.encryption_at_rest.enabled
    error_message = "At-rest encryption of the SNS topic should be enabled."
  }

  assert {
    condition     = alltrue([
      output.encryption_at_rest.kms_key == var.encryption_at_rest.kms_key,
      aws_sns_topic.this.kms_master_key_id == var.encryption_at_rest.kms_key,
    ])
    error_message = "The KMS key ID for at-rest encryption of the SNS topic should be configured with given key."
  }
}

run "test_encryption_at_rest_disabled" {
  command = apply

  variables {
    name = run.setup_variables.name

    encryption_at_rest = {
      enabled = false
      kms_key = "foobar"
    }
  }

  assert {
    condition     = !output.encryption_at_rest.enabled
    error_message = "At-rest encryption of the SNS topic should be disabled."
  }

  assert {
    condition     = length(compact([
      output.encryption_at_rest.kms_key,
      aws_sns_topic.this.kms_master_key_id,
    ])) == 0
    error_message = "The KMS key ID for at-rest encryption of the SNS topic should be empty."
  }
}
