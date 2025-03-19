provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "random_uuid" "bucket_name" {}