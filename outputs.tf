output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

# Remove the EC2 instance outputs since we're now using an ASG
# output "ec2_instance_id" {
#   value = aws_instance.webapp.id
# }
# 
# output "ec2_instance_public_ip" {
#   value = aws_instance.webapp.public_ip
# }

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.id
}

output "cloudwatch_log_group" {
  description = "The name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.webapp_logs.name
}

output "iam_role_name" {
  description = "The name of the IAM role used by the EC2 instance"
  value       = aws_iam_role.ec2_s3_role.name
}

# Add new outputs for the load balancer and auto scaling group
output "load_balancer_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.webapp_lb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.webapp_tg.arn
}

output "auto_scaling_group_name" {
  description = "The name of the auto scaling group"
  value       = aws_autoscaling_group.webapp_asg.name
}

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = aws_launch_template.webapp_lt.id
}

output "application_url" {
  description = "The URL of the application"
  value       = "http://${aws_route53_record.webapp_dns.name}"
}