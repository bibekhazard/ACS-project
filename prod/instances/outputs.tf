output "prod_vm_private_ips" {
  value = aws_instance.prod_vm[*].private_ip
}

output "prod_vm_instance_ids" {
  value = aws_instance.prod_vm[*].id
}