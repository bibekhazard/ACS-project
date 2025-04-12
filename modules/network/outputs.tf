output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "nat_gateway_id" {
  value     = var.enable_nat_gateway ? aws_nat_gateway.nat_gw[0].id : null # Conditional output
  sensitive = false
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "private_route_table_ids" {
  value = aws_route_table.private_subnets[*].id
}

output "public_route_table_ids" {
  value = aws_route_table.public_subnets[*].id
}
