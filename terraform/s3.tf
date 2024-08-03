################################################################################
# Log Bucket
################################################################################

module "log_bucket" {
  source = "./modules/terraform-aws-s3-bucket/"

  bucket                  = "${local.name_prefix}-${var.s3_config["log_bucket_name"]}-${data.aws_caller_identity.current.account_id}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    status = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id      = "DeleteObjectsAfter6Months"
      enabled = true

      expiration = {
        days = 180
      }
      noncurrent_version_expiration = {
        days = 14
      }
    },
  ]
  force_destroy = var.s3_force_destroy
}

data "aws_iam_policy_document" "log_bucket_policy" {
  statement {
    sid       = "AllowSSLRequestsOnly"
    actions   = ["s3:*"]
    effect    = "Deny"
    resources = [module.log_bucket.s3_bucket_arn, "${module.log_bucket.s3_bucket_arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
  statement {
    sid       = "LoadBalancerAccessLogs"
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["${module.log_bucket.s3_bucket_arn}/lb-access-logs/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::114774131450:root"]
    }
  }
  statement {
    sid       = "AWSLogDeliveryWrite"
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["${module.log_bucket.s3_bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
  statement {
    sid       = "AWSLogDeliveryAclCheck"
    actions   = ["s3:GetBucketAcl"]
    effect    = "Allow"
    resources = [module.log_bucket.s3_bucket_arn]
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = module.log_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.log_bucket_policy.json
}

module "web_bucket" {
  source = "./modules/terraform-aws-s3-bucket/"

  bucket = "${local.name_prefix}-${var.s3_config["web_bucket_name"]}-${data.aws_caller_identity.current.account_id}"

  versioning = {
    status = true
  }

  logging = {
    target_bucket = module.log_bucket.s3_bucket_id
    target_prefix = "${local.name_prefix}-${var.s3_config["web_bucket_name"]}/${local.name_prefix}-${var.s3_config["web_bucket_name"]}-"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  force_destroy = var.s3_force_destroy

}

data "aws_iam_policy_document" "web_bucket_policy" {
  statement {
    sid       = "AllowSSLRequestsOnly"
    actions   = ["s3:*"]
    effect    = "Deny"
    resources = [module.web_bucket.s3_bucket_arn, "${module.web_bucket.s3_bucket_arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "web_bucket_policy" {
  bucket = module.web_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.web_bucket_policy.json
}

module "app_bucket" {
  source = "./modules/terraform-aws-s3-bucket/"

  bucket = "${local.name_prefix}-${var.s3_config["app_bucket_name"]}-${data.aws_caller_identity.current.account_id}"

  versioning = {
    status = true
  }

  logging = {
    target_bucket = module.log_bucket.s3_bucket_id
    target_prefix = "${local.name_prefix}-${var.s3_config["app_bucket_name"]}/${local.name_prefix}-${var.s3_config["app_bucket_name"]}-"
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  force_destroy = var.s3_force_destroy

}

data "aws_iam_policy_document" "app_bucket_policy" {
  statement {
    sid       = "AllowSSLRequestsOnly"
    actions   = ["s3:*"]
    effect    = "Deny"
    resources = [module.app_bucket.s3_bucket_arn, "${module.app_bucket.s3_bucket_arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "app_bucket_policy" {
  bucket = module.app_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.app_bucket_policy.json
}