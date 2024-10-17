data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"
  
  name    = "${var.project}-vpc"
  cidr    = var.vpc_cidr
  azs     = data.aws_availability_zones.available.names

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion"
  description = "Security group for my VPC"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description      = "Allow traffic from me"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "loadbalancer"
  description = "Security group for my VPC"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description      = "Allow traffic from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "web_sg" {
  name        = "web"
  description = "Security group for my VPC"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description      = "Allow traffic from lb_sg"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
   # cidr_blocks = ["0.0.0.0/0"]
   security_groups  = [aws_security_group.lb_sg.id]  # Thay thế với ID của Security Group 1
  }
  ingress {
    description      = "Allow traffic from bastion_sg"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion_sg.id]  # Thay thế với ID của Security Group 1
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "db_sg" {
  name        = "database"
  description = "Security group for my VPC"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description      = "Allow traffic from web_sg and bastion_sg"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.web_sg.id,aws_security_group.bastion_sg.id]  # Thay thế với ID của Security Group 1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}