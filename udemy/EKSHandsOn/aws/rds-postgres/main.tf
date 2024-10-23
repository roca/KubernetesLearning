# https://www.devopshint.com/create-postgresql-rds-in-aws-using-terraform/
# https://msameeduddin.medium.com/using-terraform-deploying-postgresql-instance-with-read-replica-in-aws-49e75012c0b3

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

#create a RDS Database Instance
resource "aws_db_instance" "postgres" {
  engine               = "Postgres"
  identifier           = "postgres"
  allocated_storage    =  20
  engine_version       = "15.4"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "admin123"
  skip_final_snapshot  = true
  publicly_accessible =  true

  multi_az  = false

  depends_on = [aws_db_subnet_group.postgres]

  vpc_security_group_ids = [aws_security_group.postgres.id]
  db_subnet_group_name = aws_db_subnet_group.postgres.id
}

resource "aws_db_subnet_group" "postgres" {
  name       = "splitev"
  subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets
}

resource "aws_security_group" "postgres" {
  name        = "allow_all_postgres"
  description = "Allow RDS inbound traffic on 5432"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description      = "RDS from anywhere"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = [ "0.0.0.0/0" ]
  }
}