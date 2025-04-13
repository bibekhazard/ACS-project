output "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  value       = aws_security_group.bastion.id
}

output "database_security_group_id" {
  description = "Database Security Group ID"
  value       = aws_security_group.database.id
}

output "public_web_instance_ids" {
  description = "List of Public Web Server Instance IDs"
  value       = aws_instance.public_web[*].id  # Changed from web to public_web
}

output "bastion_public_ip" {
  description = "Bastion Host Public IP Address"
  value       = aws_instance.bastion.public_ip
}

output "database_private_ip" {
  description = "Database Server Private IP Address"
  value       = aws_instance.database.private_ip
}

output "public_web_sg_id" {
  description = "Public Web Servers Security Group ID"
  value       = aws_security_group.public_web.id
}

output "private_web_sg_id" {
  description = "Private Web Server Security Group ID"
  value       = aws_security_group.private_web.id
}

output "public_web_ips" {
  description = "Public Web Servers Public IP Addresses"
  value       = aws_instance.public_web[*].public_ip
}

# Add these new outputs if needed
output "private_web_instance_id" {
  description = "Private Web Server Instance ID"
  value       = aws_instance.private_web.id
}

output "private_web_private_ip" {
  description = "Private Web Server Private IP Address"
  value       = aws_instance.private_web.private_ip
}