variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
variable "custom_ami_id" {
  description = "Custom AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "volume_size" {
  description = "Root volume size"
  type        = number
}

variable "volume_type" {
  description = "Root volume type"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
}

variable "http_port" {
  description = "HTTP port"
  type        = number
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
}

variable "app_port" {
  description = "Application port"
  type        = number
}
variable "db_username" {
  description = "Database master username"
  type        = string
}

# variable "db_password" {
#   description = "Database master password"
#   type        = string
#   sensitive   = true
# }

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_engine" {
  description = "Database engine"
  type        = string
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "domain_name" {
  description = "Domain name for Route53"
  type        = string
}


variable "route53_zone_ids" {
  description = "Map of environment to Route53 zone IDs"
  type        = map(string)
}

variable "ssl_certificate_id" {
  description = "ID of the SSL certificate"
  type        = string
}