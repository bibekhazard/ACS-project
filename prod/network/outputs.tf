output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "private_route_table_ids" {
  value = module.network.private_route_table_ids
}