resource "aws_launch_template" "webapp_lt" {
  name          = "webapp-launch-template"
  image_id      = var.custom_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_profile.name
  }

  network_interfaces {
    security_groups             = [aws_security_group.app_sg.id]
    associate_public_ip_address = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = var.volume_size
      volume_type           = var.volume_type
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Add environment variables to /etc/environment
              echo "DB_USERNAME=${var.db_username}" >> /etc/environment
              echo "DB_PASSWORD=${var.db_password}" >> /etc/environment
              echo "DB_HOST=${aws_db_instance.main.address}" >> /etc/environment
              echo "DB_NAME=${var.db_name}" >> /etc/environment
              echo "S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.id}" >> /etc/environment
              echo "CLOUDWATCH_LOG_GROUP=webapp-logs" >> /etc/environment
              echo "CLOUDWATCH_LOG_STREAM=$(hostname)-application" >> /etc/environment
              
              # Configure and start CloudWatch agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
              
              # Restart the application service to pick up new environment variables
              systemctl restart csye6225
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-instance"
    }
  }
}