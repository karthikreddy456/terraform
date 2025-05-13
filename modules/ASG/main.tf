# data "aws_ami" "ubuntu_24_04" {
#   most_recent = true
#   owners      = ["099720109477"]  # Canonical’s AWS account

#   # Filter on the official Ubuntu 24.04 LTS description
#   filter {
#     name   = "description"
#     values = ["Ubuntu Server 24.04 LTS (HVM), EBS General Purpose (SSD) Volume Type*"]
#   }
# }

#  locals {
#   user_data_content = file("user_data.sh")
#   user_data_hash    = sha256(local.user_data_content)
#   }
resource "aws_launch_template" "asg" {
  name_prefix     = "asg-"
  image_id        = "ami-0e35ddab05955cf57"
  instance_type   = "t2.micro"
 #user_data = base64encode(local.user_data_content)
  user_data = filebase64("user-data.sh")
  network_interfaces {
    # for a single ENI, you can pass your SG list here:
    security_groups = var.asg_securuity_group
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                 = "asg"
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  launch_template {
    id      = aws_launch_template.asg.id
    version = aws_launch_template.asg.latest_version
  }             
  
  vpc_zone_identifier  = var.vpc_zone_identifier
  health_check_type    = "ELB"

  tag {
    key                 = "Name"
    value               = "asg-instance"
    propagate_at_launch = true
  }
}

# resource "aws_lb" "asg" {
#   name               = "learn-asg-terramino-lb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.terramino_lb.id]
#   subnets            = module.vpc.public_subnets
# }

# resource "aws_lb_listener" "terramino" {
#   load_balancer_arn = aws_lb.terramino.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.terramino.arn
#   }
# }

# resource "aws_lb_target_group" "terramino" {
#   name     = "learn-asg-terramino"
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = module.vpc.vpc_id
# }


resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn   =  var.lb_target_group_arn
 
}

# resource "aws_security_group" "terramino_instance" {
#   name = "learn-asg-terramino-instance"
#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [aws_security_group.terramino_lb.id]
#   }

#   egress {
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }

#   vpc_id = module.vpc.vpc_id
# }

# resource "aws_security_group" "terramino_lb" {
#   name = "learn-asg-terramino-lb"
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   vpc_id = module.vpc.vpc_id
# }