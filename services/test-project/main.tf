# Use Profile
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.53.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 0.14"

  backend "remote" {
    organization = "sakura-inc"

    workspaces {
      name = "test-project"
    }
  }
}

provider "aws" {
  profile = lookup(var.aws_profile, "profile_name")
  region  = lookup(var.aws_profile, "region")
  default_tags {
    tags = {
      Env = "${lookup(var.aws_profile, "enviroment")}"
    }
  }
}

# Attach Modules
module "sakura" {
  source                  = "../../modules/sakura"
  env                     = "test-project"
  aws_profile             = var.aws_profile
  vpc_public_subnet_cidr  = var.vpc_public_subnet_cidr
  vpc_private_subnet_cidr = var.vpc_private_subnet_cidr
  vpc_infomation          = var.vpc_infomation
}
