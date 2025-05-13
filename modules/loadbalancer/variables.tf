variable "alb_name" {
  description = "Name of the load balancer"
  type        = string
}
variable "alb_security_group" {
  description = "Security groups for the load balancer"
  type        = list(string)
}
variable "alb_subnets" {
  description = "Subnets for the load balancer"
  type        = list(string)
}

variable "certificate_arn" {
  description = "Certificate ARN for the load balancer"
  type        = string
}

variable "alb_target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = "ec2-target-group"
}

# variable "alb_target_group_name_6666" {
#   description = "Name of the target group"
#   type        = string
#   default     = "ec2-target-group-6666"
  
# }

variable "vpc_id" {
  description = "VPC ID for the load balancer"
  type        = string
}