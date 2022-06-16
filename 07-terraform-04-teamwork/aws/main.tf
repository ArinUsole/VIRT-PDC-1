provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

locals {
#  account_id = data.aws_caller_identity.current.account_id

  app_instance_type_map = {
    stage = "t1.micro"
    prod  = "t2.micro"
  }
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.app_instance_type_map[terraform.workspace]
  tags = {
    Name = terraform.workspace
  }
}
