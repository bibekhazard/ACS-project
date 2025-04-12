output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "nat_gateway_id" {
  value = module.network.nat_gateway_id
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "public_route_table_ids" {
  value = module.network.public_route_table_ids
}

output "public_subnet_cidrs" { 
  value = var.public_cidr_blocks
}
