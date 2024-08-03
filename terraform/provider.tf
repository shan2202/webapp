provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]
  assume_role {
    role_arn    = var.workspace_iam_roles[terraform.workspace]
    external_id = var.EXTERNAL_ID
  }
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  }
}
