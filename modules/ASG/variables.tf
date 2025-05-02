variable "asg_securuity_group" {
  description = "Security group for the ASG instances"
  type        = list(string)
}
variable "vpc_zone_identifier" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
  default     = []
}
variable "lb_target_group_arn" {
  type        = string
}