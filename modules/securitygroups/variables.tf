variable "vpc_id" {
  description = "The VPC in which to create these SGs"
  type        = string
}

variable "alb_sg_name" {
  type    = string
  default = "alb-sg"
}
variable "alb_sg_description" {
  type    = string
  default = "Allow HTTP/HTTPS to ALB"
}
variable "alb_cidr_ipv4" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ec2_cidr_ipv4" {
  type    = string
  default =  "0.0.0.0/0"
  
}


variable "ec2_sg_name" {
  type    = string
  default = "ec2-sg"
}
variable "ec2_sg_description" {
  type    = string
  default = "Ec2 security group"
}
