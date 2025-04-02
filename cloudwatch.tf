# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "webapp_logs" {
  name              = "webapp-logs"
  retention_in_days = 7

  tags = {
    Name        = "webapp-logs"
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "system-logs"
  retention_in_days = 7

  tags = {
    Name        = "system-logs"
    Environment = "production"
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name          = "webapp-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors for high CPU utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_actions = []
}

resource "aws_cloudwatch_metric_alarm" "high_memory_utilization" {
  alarm_name          = "webapp-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "WebApp"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors for high memory utilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }

  alarm_actions = []
}

# CloudWatch Alarms for Auto Scaling Policies
resource "aws_cloudwatch_metric_alarm" "high_cpu_scale_up" {
  alarm_name          = "high-cpu-scale-up"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 8
  alarm_description   = "Scale up when CPU exceeds 8%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_scale_down" {
  alarm_name          = "low-cpu-scale-down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 7
  alarm_description   = "Scale down when CPU is below 7%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}