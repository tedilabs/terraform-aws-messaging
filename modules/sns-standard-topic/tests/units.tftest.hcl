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


###################################################
# Tests
###################################################

run "test_computed_properties" {
  command = plan

  variables {
    name = run.setup_variables.name
    display_name = "Test Topic"
  }

  assert {
    condition     = aws_sns_topic.this.name == var.name
    error_message = "Invalid name for the SNS topic."
  }

  assert {
    condition     = aws_sns_topic.this.display_name == var.display_name
    error_message = "Invalid display name for the SNS topic."
  }

  assert {
    condition     = !aws_sns_topic.this.fifo_topic
    error_message = "Invalid type of the SNS topic."
  }
}

run "test_invalid_name" {
  command = plan

  variables {
    name = "my-name-is.fifo"
  }

  expect_failures = [
    var.name,
  ]
}
