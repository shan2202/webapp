resource "aws_iam_role" "ec2_app_access_role" {
  name = "${local.name_prefix}-ec2-app-access-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "ec2-app-policy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "ssm:*",
            "ec2:*",
            "s3:*",
            "kms:*",
            "secretsmanager:*",
            "logs:PutRetentionPolicy",
            "route53:ChangeResourceRecordSets"
          ],
          Effect   = "Allow",
          Resource = "*"
        }
      ]
    })
  }

  path = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

resource "aws_iam_instance_profile" "ec2_app_instance_profile" {
  name = "${local.name_prefix}-ec2-app-instance-profile"
  role = aws_iam_role.ec2_app_access_role.name
}
# ##############
# # app #
# ##############


resource "aws_launch_template" "app" {
  for_each               = { for k, v in var.autoscaling_group.services : k => v }
  name                   = "${local.name_prefix}-app-template-${each.key}"
  image_id               = each.value.app_base_ami
  instance_type          = each.value.instance_type
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_app_instance_profile.arn
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name_prefix}-app-${each.key}"
    }
  }

  network_interfaces {
    security_groups = [aws_security_group.app[each.key].id]
  }

  monitoring {
    enabled = "false"
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = each.value.volume_size
      volume_type = "gp3"
    }
  }

  lifecycle {
    ignore_changes = [image_id]
  }
  user_data = each.key != "app" ? base64encode(templatefile("${path.module}/app-userdata.sh",{APP_BUCKET_NAME=module.app_bucket.s3_bucket_id})) : base64encode(templatefile("${path.module}/web-userdata.sh",{WEB_BUCKET_NAME=module.web_bucket.s3_bucket_id, APP_LB_DNS=aws_lb.app_lb["app"].dns_name}))
}