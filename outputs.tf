output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

output "instance_ids" {
  description = "Instance IDs in the ASG (may be empty until instances launch)"
  value       = module.asg.instance_ids
}

output "attach_to_alb" {
  description = "Whether the ASG is attached to ALB"
  value       = var.attach_to_alb
}
