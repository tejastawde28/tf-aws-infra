resource "aws_db_subnet_group" "main" {
  name       = "webapp-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "webapp-db-subnet-group"
  }
}

resource "aws_db_parameter_group" "main" {
  name   = "webapp-db-parameter-group"
  family = "${var.db_engine}${var.db_engine_version}"

  tags = {
    Name = "webapp-db-parameter-group"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "csye6225"
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = random_password.db_password.result
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds_key.arn

  # Enable automated backups
  backup_retention_period = 7
  backup_window           = "03:00-05:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  tags = {
    Name = "webapp-db-instance"
  }
}