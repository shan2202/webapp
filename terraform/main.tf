# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Terraform configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.20.1"
    }
  }

  backend "s3" {
    encrypt        = true
    dynamodb_table = "tfstate-table"
  }

}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}