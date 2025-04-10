resource "aws_autoscaling_group" "webapp_asg" {
  name                = "webapp-asg"
  min_size            = 3
  max_size            = 5
  desired_capacity    = 3
  default_cooldown    = 60
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.webapp_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.webapp_tg.arn]

  tag {
    key                 = "Name"
    value               = "webapp-asg-instance"
    propagate_at_launch = true
  }

  depends_on = [
    aws_launch_template.webapp_lt,
    aws_secretsmanager_secret.db_password,
    aws_db_instance.main,
    aws_iam_role.ec2_s3_role,
    aws_iam_policy.kms_access_policy,
  ]
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}
