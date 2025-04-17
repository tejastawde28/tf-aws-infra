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
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_key.arn
    }
  }

  user_data = base64encode(<<-EOF
  #!/bin/bash
  set -e

  # Log to a file for debugging
  exec > /tmp/user-data-log.txt 2>&1
  echo "Starting user data script execution at $(date)"

  # Make sure AWS CLI is installed
  if ! command -v aws &> /dev/null; then
      apt-get update
      apt-get install -y unzip
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip > /dev/null 2>&1
      sudo ./aws/install
      rm -rf awscliv2.zip
      echo "awscli installed successfully" >> /tmp/user-data-log.txt
  else
      echo "AWS CLI already installed" >> /tmp/user-data-log.txt
  fi

  # Make sure jq is installed
  if ! command -v jq &> /dev/null; then
      echo "jq not found, installing..."
      apt-get update
      apt-get install -y jq
  else
      echo "jq already installed" >> /tmp/user-data-log.txt
  fi

  # Set AWS region
  AWS_REGION="${var.aws_region}"
  export AWS_REGION
  echo "AWS region set to $AWS_REGION" >> /tmp/user-data-log.txt

  # Backup the original /etc/environment file
  cp /etc/environment /etc/environment.bak

  # Extract the PATH from the original environment file
  PATH_VALUE=$(grep "^PATH=" /etc/environment.bak | head -1 || echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin")

  # Create a new environment file with just the PATH
  echo "$PATH_VALUE" > /etc/environment

  # Retry to fetch secret from Secrets Manager
  MAX_ATTEMPTS=10
  for i in $(seq 1 $MAX_ATTEMPTS); do
      DB_SECRET=$(aws secretsmanager get-secret-value \
        --region $AWS_REGION \
        --secret-id ${aws_secretsmanager_secret.db_password.id} \
        --query SecretString \
        --output text 2>&1)
      
      if [ $? -eq 0 ] && [ -n "$DB_SECRET" ]; then
          break
      else
          if [ $i -eq $MAX_ATTEMPTS ]; then
              # Fallback to using the values from Terraform variables
              echo "DB_USERNAME=${var.db_username}" >> /etc/environment
              echo "DB_PASSWORD=${random_password.db_password.result}" >> /etc/environment
              echo "DB_HOST=${aws_db_instance.main.address}" >> /etc/environment
              echo "DB_NAME=${var.db_name}" >> /etc/environment
              echo "S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.id}" >> /etc/environment
              echo "CLOUDWATCH_LOG_GROUP=webapp-logs" >> /etc/environment
              echo "CLOUDWATCH_LOG_STREAM=$(hostname)-application" >> /etc/environment
              echo "fetching secret failed after $MAX_ATTEMPTS attempts, using fallback values" >> /tmp/user-data-log.txt
          else
              sleep 10
          fi
      fi
  done

  # Only try to parse the secret if we actually got it
  if [ -n "$DB_SECRET" ]; then
      # Try to extract values with error handling
      DB_USERNAME=$(echo "$DB_SECRET" | jq -r '.username // "'"${var.db_username}"'"')
      DB_PASSWORD=$(echo "$DB_SECRET" | jq -r '.password // "'"${random_password.db_password.result}"'"')
      DB_HOST=$(echo "$DB_SECRET" | jq -r '.host // "'"${aws_db_instance.main.address}"'"')
      DB_NAME=$(echo "$DB_SECRET" | jq -r '.dbname // "'"${var.db_name}"'"')
      DB_PORT=$(echo "$DB_SECRET" | jq -r '.port // "${var.db_port}"')
      
      # Write values to the environment file
      echo "DB_USERNAME=$DB_USERNAME" >> /etc/environment
      echo "DB_PASSWORD=$DB_PASSWORD" >> /etc/environment
      echo "DB_HOST=$DB_HOST" >> /etc/environment
      echo "DB_NAME=$DB_NAME" >> /etc/environment
      echo "DB_PORT=$DB_PORT" >> /etc/environment
      echo "Writing DB credentials to /etc/environment" >> /tmp/user-data-log.txt
  fi

  # Add S3 and CloudWatch info to the environment file
  echo "S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.id}" >> /etc/environment
  echo "CLOUDWATCH_LOG_GROUP=webapp-logs" >> /etc/environment
  echo "CLOUDWATCH_LOG_STREAM=$(hostname)-application" >> /etc/environment

  # Set proper permissions for /etc/environment
  chmod 644 /etc/environment
  chown root:root /etc/environment

  # Source the environment variables
  set -a
  source /etc/environment
  set +a

  # Configure CloudWatch agent
  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json


  # Restart the application service with better error handling
  echo "Attempting to restart application service..."
  if ! systemctl restart csye6225; then
      echo "First restart attempt failed, waiting 30 seconds and trying again..." >> /tmp/user-data-log.txt
      sleep 30
      if ! systemctl restart csye6225; then
          echo "Second restart attempt failed, checking service status..." >> /tmp/user-data-log.txt
          systemctl status csye6225 > /tmp/service-status.log
          echo "Service logs saved to /tmp/service-status.log" >> /tmp/user-data-log.txt
          echo "WARNING: Service failed to start properly" >> /tmp/user-data-log.txt
      else
          echo "Service successfully restarted on second attempt" >> /tmp/user-data-log.txt
      fi
  else
      echo "Service successfully restarted on first attempt" >> /tmp/user-data-log.txt
  fi

  if systemctl is-active --quiet csye6225; then
      echo "Service is running properly" >> /tmp/user-data-log.txt
  else
      journalctl -u csye6225 --no-pager -n 50 > /tmp/service-logs.log
  fi

  echo "User data script completed at $(date)" >> /tmp/user-data-log.txt
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-instance"
    }
  }
  depends_on = [
    aws_secretsmanager_secret_version.db_password,
    aws_kms_key.ec2_key,
    aws_iam_role_policy_attachment.s3_policy_attachment,
    aws_iam_role_policy_attachment.secrets_policy_attachment,
    aws_iam_role_policy_attachment.kms_policy_attachment,
    aws_iam_role_policy_attachment.cloudwatch_policy_attachment,
  ]
}