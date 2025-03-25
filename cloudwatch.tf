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

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "webapp_dashboard" {
  dashboard_name = "WebApp-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["WebApp", "api.upload_file.count", { "stat" = "Sum", "period" = 300 }],
            ["WebApp", "api.get_file.count", { "stat" = "Sum", "period" = 300 }],
            ["WebApp", "api.delete_file.count", { "stat" = "Sum", "period" = 300 }],
            ["WebApp", "api.health_check.count", { "stat" = "Sum", "period" = 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "API Request Count"
          region  = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["WebApp", "api.upload_file.time", { "stat" = "Average", "period" = 300 }],
            ["WebApp", "api.get_file.time", { "stat" = "Average", "period" = 300 }],
            ["WebApp", "api.delete_file.time", { "stat" = "Average", "period" = 300 }],
            ["WebApp", "api.health_check.time", { "stat" = "Average", "period" = 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "API Response Time (ms)"
          region  = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["WebApp", "db.*.time", { "stat" = "Average", "period" = 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "Database Operation Time (ms)"
          region  = var.aws_region
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["WebApp", "s3.*.time", { "stat" = "Average", "period" = 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          title   = "S3 Operation Time (ms)"
          region  = var.aws_region
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE 'webapp-logs' | fields @timestamp, @message | sort @timestamp desc | limit 100"
          region = var.aws_region
          title  = "Application Logs"
          view   = "table"
        }
      }
    ]
  })
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