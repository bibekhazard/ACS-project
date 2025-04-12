output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "web_server_public_ips" {
  value = aws_instance.web_server[*].public_ip
}

output "db_server_private_ips" {
  value = aws_instance.db_server[*].private_ip
}

output "web_server_instance_ids" {
  value = aws_instance.web_server[*].id
}