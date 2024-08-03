################################################################################
# Regional Application KMS Key
################################################################################
resource "aws_kms_key" "application_kms" {
  description         = "Application Key"
  enable_key_rotation = true
  is_enabled          = true
  key_usage           = "ENCRYPT_DECRYPT"
  policy              = data.aws_iam_policy_document.application_kms_policy.json
}

data "aws_iam_policy_document" "application_kms_policy" {
  policy_id = "${local.name_prefix}-AppKey"
  version   = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Enable SNS Topic Encryption"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "sns:Publish",
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }

  statement {
    sid    = "Enable User Permissions for Svc Account"
    effect = "Allow"

    actions = ["kms:Decrypt", "kms:GenerateDataKey"]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/ses-email-service-account"]
    }
  }

  statement {
    sid    = "Allow administration of the key"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = ["*"]

  }

  statement {
    sid    = "Allow NLB access logs"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Describe*",
      "kms:ReEncrypt*",
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }

  dynamic "statement" {
    for_each = var.roles["replica_source_account_role"] != "" ? [1] : []

    content {
      sid    = "Enable Permissions for S3 Replication Role"
      effect = "Allow"

      actions   = ["kms:Encrypt"]
      resources = ["*"]

      principals {
        type        = "AWS"
        identifiers = [var.roles["replica_source_account_role"]]
      }
    }
  }
}

################################################################################
# Database KMS Key
################################################################################
resource "aws_kms_key" "database_kms" {
  description         = "Database Key"
  enable_key_rotation = true
  is_enabled          = true
  key_usage           = "ENCRYPT_DECRYPT"
  policy              = data.aws_iam_policy_document.database_kms_policy.json
}

data "aws_iam_policy_document" "database_kms_policy" {
  policy_id = "${local.name_prefix}-DBKey"
  version   = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow administration of the key"
    effect = "Allow"

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]

    resources = ["*"]

  }
}