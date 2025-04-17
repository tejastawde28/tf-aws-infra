# Generate random DB password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$*()-_=+[]:"
}

# Store DB password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "db-password-secret"
  description             = "Database password for the web application"
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.secrets_key.arn

  tags = {
    Name = "db-password-secret"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = var.db_engine
    host     = aws_db_instance.main.address
    port     = var.db_port
    dbname   = var.db_name
  })
}