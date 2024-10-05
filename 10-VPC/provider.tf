terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }

  backend "s3" {
    bucket = "pvgs-remote-state"
    key    = "expense-vpc"
    region = "us-east-1"
    dynamodb_table = "pvgs-locking"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}