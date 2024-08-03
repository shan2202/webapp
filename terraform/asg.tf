##############
# app #
##############
resource "aws_autoscaling_group" "app" {
  for_each = { for k, v in var.autoscaling_group.services : k => v }

  name                      = "${local.name_prefix}-app-asg-${each.key}"
  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_grace_period = 60
  desired_capacity          = each.value.app_desired_capacity
  max_size                  = each.value.app_max_size
  min_size                  = each.value.app_min_size

  launch_template {
    id      = aws_launch_template.app[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = each.key
    propagate_at_launch = true
  }
}