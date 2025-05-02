output "ec2_security_group_id" {
  value = aws_security_group.EC2.id
  description = "The ID of the EC2 security group"
}
output "alb_security_group_id" {
  value = aws_security_group.alb.id
  description = "The ID of the ALB security group"
  
}