resource "aws_db_instance" "database" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro"
  identifier             = "${var.project}-db-instance"
  db_name                = "blogs"  # Sử dụng db_name thay vì name
  username               = "admin"
  password               = "admin1237&&da"
  db_subnet_group_name   = var.vpc.database_subnet_group
  vpc_security_group_ids = [var.sg.db]
  skip_final_snapshot    = true
  publicly_accessible  = true
}

