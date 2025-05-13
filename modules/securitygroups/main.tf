resource "aws_security_group" "alb" {
  name        = var.alb_sg_name
  description = var.alb_sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.alb_sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ipv4" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = var.alb_cidr_ipv4
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "alb_ipv4_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = var.alb_cidr_ipv4
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_alb" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = "80"
  to_port = "80"
  referenced_security_group_id = aws_security_group.EC2.id
}



# Create a security group for EC2 instances

resource "aws_security_group" "EC2" {
  name        = var.ec2_sg_name
  description = var.ec2_sg_description
  vpc_id      = var.vpc_id

  tags = {
    Name = var.ec2_sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ipv4" {
  security_group_id = aws_security_group.EC2.id
  from_port         = "80"
  to_port = "80"
  ip_protocol       = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
 
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_ec2" {
  security_group_id = aws_security_group.EC2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
