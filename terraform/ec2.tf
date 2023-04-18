provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}
resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "aws_key_pair" "example" {
  key_name   = "techtvm-project-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "example" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/techtvm-project-key.pem"
}
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "dsasi-ubuntu"

  ami                    = "ami-06c4532923d4ba1ec"
  instance_type          = "t2.micro"
  key_name               = "techtvm-project-key"
  vpc_security_group_ids = [data.aws_security_group.default.id]
  subnet_id              = tolist(data.aws_subnet_ids.default.ids)[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

