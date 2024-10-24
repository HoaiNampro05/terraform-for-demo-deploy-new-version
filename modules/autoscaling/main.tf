# Tạo Application Load Balancer
resource "aws_lb" "alb" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg.lb]
  subnets            = var.vpc.public_subnets
}

# Tạo target group cho webv1
resource "aws_lb_target_group" "webv1" {
  name        = "ver1"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc.vpc_id
  target_type = "instance"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # Cookie tồn tại trong 1 ngày
  }
}

# Tạo target group cho webv2
resource "aws_lb_target_group" "webv2" {
  name        = "ver2"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc.vpc_id
  target_type = "instance"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400  # Cookie tồn tại trong 1 ngày
  }
}

# Tạo listener cho ALB với sticky session và cân bằng tải giữa webv1 và webv2
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.webv1.arn
        weight = 1  # Tỷ lệ cho webv1
      }

      target_group {
        arn    = aws_lb_target_group.webv2.arn
        weight = 1  # Tỷ lệ cho webv2
      }

      # Bật stickiness cho listener action (group stickiness)
      stickiness {
        enabled  = true
        duration = 86400  # Cookie tồn tại trong 1 ngày
      }
    }
  }
}

# Cấu hình Launch Template cho webv1
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
}

# Cấu hình Launch Template cho webv2
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
}

# Cấu hình Auto Scaling Group cho webv1
resource "aws_autoscaling_group" "webv1" {
  name                = "${var.project}-webv1-asg"
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.webv1.arn]
  
  launch_template {
    id      = aws_launch_template.webv1.id
    version = aws_launch_template.webv1.latest_version
  }
}

# Cấu hình Auto Scaling Group cho webv2
resource "aws_autoscaling_group" "webv2" {
  name                = "${var.project}-webv2-asg"
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.vpc.private_subnets
  target_group_arns   = [aws_lb_target_group.webv2.arn]
  
  launch_template {
    id      = aws_launch_template.webv2.id
    version = aws_launch_template.webv2.latest_version
  }
}


