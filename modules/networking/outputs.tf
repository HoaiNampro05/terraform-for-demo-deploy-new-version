output "vpc" {
  value = module.vpc
}

output "sg" {
  value = {
    lb = aws_security_group.lb_sg.id
    web = aws_security_group.web_sg.id
    db = aws_security_group.db_sg.id
    bastion = aws_security_group.bastion_sg.id
  }
}
