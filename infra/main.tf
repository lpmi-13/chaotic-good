# this backend is in terraform cloud, just for storing state
terraform {
  backend "remote" {
    organization = "chaotic-good"

    workspaces {
      name = "terraform-cli"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}


