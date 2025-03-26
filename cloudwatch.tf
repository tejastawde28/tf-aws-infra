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
    InstanceId = aws_instance.webapp.id
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
    InstanceId = aws_instance.webapp.id
  }

  alarm_actions = []
}