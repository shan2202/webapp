################################################################################
# VPC
################################################################################
locals {
  private_route_table_ids = join(", ", module.vpc.private_route_table_ids)
}

module "vpc" {
  source = "./modules/terraform-aws-vpc/"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs             = var.vpc_azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_nat_gateway = true

  # VPC Flow Logs
  enable_flow_log                      = true
  flow_log_traffic_type                = "REJECT"
  flow_log_destination_type            = "s3"
  flow_log_destination_arn             = module.log_bucket.s3_bucket_arn
  flow_log_log_format                  = "$${version} $${vpc-id} $${subnet-id} $${instance-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr}"
  flow_log_max_aggregation_interval    = 60
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  vpc_flow_log_tags = {
    Name    = "FlowLogForVPC"
    Purpose = "RejectTraffic"
    Stage   = "${var.environment}"
  }

  vpc_tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

################################################################################
# VPC Endpoints
################################################################################

module "vpc_endpoints" {
  source = "./modules/terraform-aws-vpc/modules/vpc-endpoints/"

  vpc_id = module.vpc.vpc_id

  create_security_group      = true
  security_group_name        = "${local.name_prefix}-vpc-endpoints-sg"
  security_group_description = "${local.name_prefix}-vpce-securitygroup"
  security_group_rules = {
    ingress_https = {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [module.vpc.vpc_cidr_block]
    },
    egress_all = {
      protocol    = "-1"
      from_port   = -1
      to_port     = -1
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      policy          = data.aws_iam_policy_document.s3_endpoint_policy.json
      route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
    },
    ec2 = {
      service             = "ec2"
      policy              = data.aws_iam_policy_document.ec2_endpoint_policy.json
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ssm = {
      service             = "ssm"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
  }
}

data "aws_iam_policy_document" "s3_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "ec2_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
