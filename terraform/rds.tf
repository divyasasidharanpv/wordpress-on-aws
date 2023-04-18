
resource "aws_db_subnet_group" "group" {
  name       = "dsasi-db-subnet-group"
  subnet_ids = data.aws_subnet_ids.default.ids
  }
  
  module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "wordpress-backup"
  family = "mysql8.0"

  engine         = "mysql"
  engine_version = "8.0"
  major_engine_version = "8.0"
  instance_class = "db.t2.micro"
  allocated_storage = 20

  name     = "wordpress"
  username = "admin"
  password = "password"
  

  db_subnet_group_name   = aws_db_subnet_group.group.name
  subnet_ids             = data.aws_subnet_ids.default.ids
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}