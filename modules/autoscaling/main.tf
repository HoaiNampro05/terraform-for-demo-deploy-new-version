
resource "aws_launch_template" "webv1" {
  name_prefix   = "web1-"
  image_id      = "ami-0c653ba233fb5b919"
  instance_type = "t2.micro"
  vpc_security_group_ids = [var.sg.web]
  
  key_name = "samsungtest1Keypair"
  user_data = base64encode(templatefile("${path.module}/run.sh", {
    db_host     = var.db_config.hostname
    db_user     = var.db_config.user
    db_password = var.db_config.password
  }))
  # network_interfaces {
  #   associate_public_ip_address = true
  #   security_groups             = [var.sg.web]
  # }
}

resource "aws_launch_template" "webv2" {
  name_prefix   = "web2-"
  image_id      = "ami-0c653ba233fb5b919"
  instance_type = "t2.micro"
  key_name = "samsungtest1Keypair"
  vpc_security_group_ids = [var.sg.web]

  user_data = base64encode(templatefile("${path.module}/runv2.sh", {
    db_host     = var.db_config.hostname
    db_user     = var.db_config.user
    db_password = var.db_config.password
  }))
  # network_interfaces {
  #   associate_public_ip_address = true
  #    security_groups             = [var.sg.web]
  # }
}




module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 6.0"
  name               = var.project
  load_balancer_type = "application"
  vpc_id             = var.vpc.vpc_id
  subnets            = var.vpc.public_subnets
  security_groups    = [var.sg.lb]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action = {
        type = "forward"
        target_group_tuple = [
          {
            target_group_index = 0
            weight             = 3  # Tỷ lệ 75%
          },
          {
            target_group_index = 1
            weight             = 1  # Tỷ lệ 25%
          }
        ]
      }
    }
  ]
  target_groups = [
    {
      name_prefix      = "ver1",
      backend_protocol = "HTTP",
      backend_port     = 8000
      target_type      = "instance"
    },
    {
      name_prefix      = "ver2",
      backend_protocol = "HTTP",
      backend_port     = 8000
      target_type      = "instance"
    }
  ]
}

resource "aws_autoscaling_group" "webv1" {
  name                = "${var.project}-webv1-asg"
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.vpc.private_subnets
  target_group_arns   = module.alb.target_group_arns
  launch_template {
    id      = aws_launch_template.webv1.id
    version = aws_launch_template.webv1.latest_version
  }
}

resource "aws_autoscaling_group" "webv2" {
  name                = "${var.project}-webv2-asg"
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.vpc.private_subnets
  target_group_arns   = module.alb.target_group_arns
  launch_template {
    id      = aws_launch_template.webv2.id
    version = aws_launch_template.webv2.latest_version
  }
}
