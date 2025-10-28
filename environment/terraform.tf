terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.18.0"
    }
  }
  backend "s3" {
    bucket = "silver-buddy-terraform-state"
    region = "us-east-1"
    key = "state"
  }

  required_version = ">= 1.13.4"
}
