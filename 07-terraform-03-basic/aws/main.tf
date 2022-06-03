provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

locals {
  web_instance_type_map = {
    stage = "t1.micro"
    prod  = "t2.micro"
  }
  web_instance_count_map = {
    stage = 1
    prod  = 2
  }
  instances = {
    stage = {
      "t1.micro" = data.aws_ami.amazon_linux.id
    }
    prod = {
      "t3.micro" = data.aws_ami.amazon_linux.id
      "t4.micro" = data.aws_ami.amazon_linux.id
    }
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.web_instance_type_map[terraform.workspace]
  count         = local.web_instance_count_map[terraform.workspace]
  tags = {
    Name = terraform.workspace
  }
}

resource "aws_instance" "web2" {
  for_each      = local.instances[terraform.workspace]
  ami           = each.value
  instance_type = each.key
  tags = {
    Name = terraform.workspace
  }
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = ["tags"]
  }
}
