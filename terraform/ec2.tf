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
  key_name   = "project-key"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "example" {
  content  = tls_private_key.example.private_key_pem
  filename = "${path.module}/project-key.pem"
}

# This resource block creates a new IAM role named "s3-full-access".
resource "aws_iam_role" "s3_full_access" {
  name = "s3-full-access"

  # The assume_role_policy defines the trust policy for the role, which specifies who can assume the role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# This resource block attaches the "AmazonS3FullAccess" managed policy to the "s3-full-access" role.
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.s3_full_access.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# This resource block creates a new instance profile named "s3-full-access" and associates it with the "s3-full-access" role.
resource "aws_iam_instance_profile" "s3_full_access" {
  name = "s3-full-access"
  role = aws_iam_role.s3_full_access.name
}
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "wp-ubuntu"

  ami                    = "ami-06c4532923d4ba1ec"
  instance_type          = "t2.micro"
  key_name               = "project-key"
  vpc_security_group_ids = [data.aws_security_group.default.id]
  subnet_id              = tolist(data.aws_subnet_ids.default.ids)[0]
  iam_instance_profile = aws_iam_instance_profile.s3_full_access.name
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

