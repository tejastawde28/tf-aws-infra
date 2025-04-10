resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "ec2-s3-role"
  }
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "s3-access-policy"
  description = "Policy to allow EC2 instance to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.app_bucket.arn}",
          "${aws_s3_bucket.app_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Add policy for Secret Manager access
resource "aws_iam_policy" "secrets_access_policy" {
  name        = "secrets-access-policy"
  description = "Policy to allow EC2 instance to access specific secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.db_password.arn,
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          aws_kms_key.secrets_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "secrets_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.secrets_access_policy.arn
}

resource "aws_iam_policy" "kms_access_policy" {
  name        = "kms-access-policy"
  description = "Policy to allow EC2 instance to use KMS keys for encryption"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = [
          aws_kms_key.ec2_key.arn,
          aws_kms_key.s3_key.arn,
          aws_kms_key.rds_key.arn,
          aws_kms_key.secrets_key.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.kms_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_s3_role.name
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "cloudwatch-agent-policy"
  description = "Allows EC2 instances to send logs and metrics to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

# Add policy for Instance Refresh operations
resource "aws_iam_policy" "autoscaling_policy" {
  name        = "autoscaling-policy"
  description = "Policy to allow instance refresh operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:StartInstanceRefresh",
          "autoscaling:DescribeInstanceRefreshes",
          "autoscaling:CancelInstanceRefresh",
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeLaunchTemplates",
          "autoscaling:DescribeLaunchTemplateVersions",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ModifyLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "autoscaling_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.autoscaling_policy.arn
}