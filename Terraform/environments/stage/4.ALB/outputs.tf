output "ALB_TG" {
  value       = module.stage_alb.ALB_TG
  description = "Load Balancer Target Group ARN"
}

output "ALB_DNS" {
  value       = module.stage_alb.ALB_DNS
  description = "Load Balancer Domain Name"
}
