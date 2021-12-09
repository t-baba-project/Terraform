# Test Account
variable "aws_profile" {
  type = map(string)
  default = {
    profile_name = "sakura"
    region       = "ap-northeast-1"
    enviroment   = "test-project"
    account_id   = "709625827629"
  }
  description = "Profile Infomation"
}

variable "vpc_infomation" {
  type = map(string)
  default = {
    cidr             = "192.168.0.0/16"
    instance_tenancy = "default"
    dns_support      = "true"
    dns_hostnames    = "true"
    tags             = "main-vpc"
  }
  description = "VPC Infomation"
}

variable "vpc_public_subnet_cidr" {
  type = map(map(string))
  default = {
    param1 = {
      name = "public-1a"
      cidr = "192.168.10.0/24"
      zone = "ap-northeast-1a"
    }
    param2 = {
      name = "public-1c"
      cidr = "192.168.20.0/24"
      zone = "ap-northeast-1c"
    }
  }
  description = "VPC Public Subnet Infomation"
}

variable "vpc_private_subnet_cidr" {
  type = map(map(string))
  default = {
    param1 = {
      name = "private-1a"
      cidr = "192.168.127.0/24"
      zone = "ap-northeast-1a"
    }
    param2 = {
      name = "private-1c"
      cidr = "192.168.128.0/24"
      zone = "ap-northeast-1c"
    }
  }
  description = "VPC Private Subnet Infomation"
}