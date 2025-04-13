output "alb_dns_name" {
  description = "Application Load Balancer DNS Name"
  value       = aws_lb.web.dns_name
}

output "asg_instance_ids" {
  description = "IDs of ASG instances (VM1 & VM3)"
  value       = aws_autoscaling_group.web.id
}

output "target_group_arn" {
  description = "Target Group ARN for ALB"
  value       = aws_lb_target_group.web.arn
}

output "launch_template_id" {
  description = "Launch Template ID used by ASG"
  value       = aws_launch_template.web.id
}