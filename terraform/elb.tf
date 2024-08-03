############################
#    Load Balancer        #
############################

resource "aws_lb" "app_lb" {
  for_each                         = { for k, v in var.load_balancer.services : k => v }
  name                             = "${var.project_name}-elb-${each.key}"
  load_balancer_type               = each.value.elb_type
  enable_cross_zone_load_balancing = "true"
  internal                         = each.value.is_internal
  subnets                          = each.value.is_internal == "true" ? module.vpc.private_subnets : module.vpc.public_subnets
  security_groups                  = [aws_security_group.app_lb[each.key].id]
  enable_deletion_protection       = true
  access_logs {
    bucket  = module.log_bucket.s3_bucket_id
    prefix  = "lb-access-logs"
    enabled = true
  }
  tags = {
    Name = each.key
  }
}


resource "aws_lb_target_group" "app_target_group" {
  for_each = { for k, v in var.load_balancer.services : k => v }
  name     = "${var.project_name}-tg-${each.key}"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = module.vpc.vpc_id
  tags = {
    Name = each.key
  }
}

resource "aws_lb_listener" "app_listener" {

  for_each          = { for k, v in var.load_balancer.services : k => v }
  load_balancer_arn = aws_lb.app_lb[each.key].arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group[each.key].arn
  }
}

resource "aws_autoscaling_attachment" "app_target_group_attachment" {
  for_each               = { for k, v in var.load_balancer.services : k => v }
  autoscaling_group_name = aws_autoscaling_group.app[each.key].id
  lb_target_group_arn    = aws_lb_target_group.app_target_group[each.key].arn
}