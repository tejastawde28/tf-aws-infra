resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr1
  enable_dns_support   = true
  enable_dns_hostnames = true
}