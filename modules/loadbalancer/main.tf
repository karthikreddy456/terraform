resource "aws_lb" "back_end" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_group
  subnets            = var.alb_subnets

  enable_deletion_protection = true


  tags = {
    Environment = "dev"
  }
}

#For aws listner https
resource "aws_lb_listener" "back_end" {
  load_balancer_arn = aws_lb.back_end.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_example.arn
  }
}
#For aws listner http
resource "aws_lb_listener" "back_end1" {
  load_balancer_arn = aws_lb.back_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "alb_example" {
  name        = var.alb_target_group_name
  target_type = "instance"   
  port        = 7777
  protocol    = "HTTP"      
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
  }
  
}

