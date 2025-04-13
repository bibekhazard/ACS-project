output "alb_dns_name" {
  description = "Application Load Balancer DNS Name"
  value       = module.alb_asg.alb_dns_name
}

output "asg_instances" {
  description = "ALB/ASG Web Server Instance IDs (VM1 & VM3)"
  value       = module.alb_asg.asg_instance_ids
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP Address (VM2)"
  value       = module.compute.bastion_public_ip
}

output "standalone_web_instance" {
  description = "Standalone Web Server Details (VM4)"
  value = {
    id         = module.compute.public_web_instance_ids[0]
    public_ip  = module.compute.public_web_ips[0]
  }
}

output "private_web_instance" {
  description = "Private Web Server Details (VM5)"
  value = {
    id          = module.compute.private_web_instance_id
    private_ip  = module.compute.private_web_private_ip
  }
}

output "database_private_ip" {
  description = "Database Server Private IP Address (VM6)"
  value       = module.compute.database_private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_web_sg_id" {
  description = "Public Web Servers Security Group ID"
  value       = module.compute.public_web_sg_id
}