resource "aws_security_group" "app_lb" {
  for_each    = { for k, v in var.load_balancer.services : k => v }
  name        = "${local.name_prefix}-app-lb-sg-${each.key}"
  description = "Security group for app load balancer ${each.key}"
  vpc_id      = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = each.key != "app" ? [1] : []
    content {
      from_port   = each.value.public_port
      to_port     = each.value.public_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = each.key == "app" ? [1] : []
    content {
      from_port   = each.value.public_port
      to_port     = each.value.public_port
      protocol    = "tcp"
      cidr_blocks = ["${var.vpc_cidr}"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-app-lb-sg-${each.key}"
  }
}

resource "aws_security_group" "app" {
  for_each    = { for k, v in var.load_balancer.services : k => v }
  name        = "${local.name_prefix}-app-sg-${each.key}"
  description = "Security group for ${each.key} instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = each.value.port
    to_port         = each.value.port
    protocol        = "tcp"
    security_groups = [aws_security_group.app_lb[each.key].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-app-security-group-${each.key}"
  }
}

resource "aws_security_group" "mysql_database_sg" {
  for_each    = { for k, v in var.load_balancer.services : k => v if k != "web" }

  name            = "${local.name_prefix}-mysql-database-sg"
  description     = "${local.name_prefix}-mysql-database-sg"
  vpc_id          = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app[each.key].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.name_prefix}-db-security-group-${each.key}"
  }

}