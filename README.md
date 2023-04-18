# wordpress-on-aws

Task details:
1) Use Terraform to create:
a) an ec2 instance (t2.micro) in us-east-2 region along with public IP, key, etc. Use only the
default vpc, associated security groups, etc.
b) Create an s3 bucket to store Wordpress files and database backup
c) Create an AWS RDS MySQL Instance (Freetier) for backup of Wordpress db periodically.

2) Write an ansible playbook to install Wordpress with LAMP on Ubuntu 20.04 LTS.

3) Write a simple bash script to backup the Wordpress files to the s3 bucket & its database to the MySQL
in AWS RDS every day at 8 PM IST. No need to setup any MySQL Master slave replicaƟon.
