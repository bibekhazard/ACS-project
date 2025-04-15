module "network" {
  source       = "../../modules/network"
  environment  = var.environment
  group_name   = var.group_name
  vpc_cidr     = var.vpc_cidr
  tags         = local.tags
}

module "compute" {
  source          = "../../modules/compute"
  environment     = var.environment
  group_name      = var.group_name
  vpc_id          = module.network.vpc_id
  public_subnet_ids = [
    module.network.public_subnet_ids[1],  # Subnet 2 (VM2 - Bastion)
    module.network.public_subnet_ids[3]   # Subnet 4 (VM4)
  ]
  private_subnet_ids = module.network.private_subnet_ids
  instance_type   = var.web_instance_type
  db_instance_type = var.db_instance_type
  key_name        = var.key_name
  ssh_access_cidr = var.ssh_access_cidr
  alb_security_group_id = module.network.alb_security_group_id
  tags            = local.tags
}

module "alb_asg" {
  source        = "../../modules/alb-asg"
  environment   = var.environment
  group_name    = var.group_name
  vpc_id        = module.network.vpc_id
  public_subnet_ids = [
    module.network.public_subnet_ids[0],  # Subnet 1 (VM1)
    module.network.public_subnet_ids[2]   # Subnet 3 (VM3)
  ]
  web_security_group_id = module.compute.public_web_sg_id
  alb_security_group_id = module.network.alb_security_group_id
  instance_type = var.web_instance_type
  key_name      = var.key_name
  tags          = local.tags
}

locals {
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })
}