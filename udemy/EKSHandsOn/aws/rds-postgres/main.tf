# https://www.devopshint.com/create-postgresql-rds-in-aws-using-terraform/

#main.tf
#defining the provider as aws
provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}



#create a RDS Database Instance
resource "aws_db_instance" "myrds" {
  engine               = "Postgres"
  identifier           = "myrds"
  allocated_storage    =  20
  engine_version       = "15.4"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "admin123"
  skip_final_snapshot  = true
  publicly_accessible =  true
}