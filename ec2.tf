resource "aws_instance" "webapp" {
  ami           = var.custom_ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
  ]
  key_name             = var.key_name
  subnet_id            = aws_subnet.public[0].id
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_profile.name

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              # Add environment variables to /etc/environment
              echo "DB_USERNAME=${var.db_username}" >> /etc/environment
              echo "DB_PASSWORD=${var.db_password}" >> /etc/environment
              echo "DB_HOST=${aws_db_instance.main.address}" >> /etc/environment
              echo "DB_NAME=${var.db_name}" >> /etc/environment
              echo "S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.id}" >> /etc/environment
              echo "CLOUDWATCH_LOG_GROUP=webapp-logs" >> /etc/environment
              echo "CLOUDWATCH_LOG_STREAM=${aws_instance.webapp.id}-application" >> /etc/environment
              
              # Configure and start CloudWatch agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
              
              # Restart the application service to pick up new environment variables
              systemctl restart csye6225
              EOF

  disable_api_termination = false

  tags = {
    Name = "webapp-instance"
  }

  depends_on = [aws_db_instance.main]
}