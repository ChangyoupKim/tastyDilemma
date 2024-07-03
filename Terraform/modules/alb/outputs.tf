output "ALB_TG" {
  value       = aws_lb_target_group.aws_alb_tg.arn
  description = "Load Balancer Target Group ARN"
}

output "ALB_DNS" {
  value       = aws_lb.aws_alb.dns_name
  description = "Load Balancer Domain Name"
}
