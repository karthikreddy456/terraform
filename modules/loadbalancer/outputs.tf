output "alb_target_group_arn" {
  value = aws_lb_target_group.alb_example.arn
}
output "alb_dns_name" {
  value = aws_lb.back_end.dns_name
  description = "The DNS name of the load balancer."
}
