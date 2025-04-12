terraform {
  backend "s3" {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/prod/network/terraform.tfstate" # Unique key for prod/network state
    region         = "us-east-1" # Or your desired region
    encrypt        = true
  }
}

module "network" {
  source = "../../modules/network"

  prefix              = var.prefix
  env                 = var.environment
  vpc_cidr            = var.vpc_cidr
  public_cidr_blocks  = var.public_cidr_blocks
  private_cidr_blocks = var.private_cidr_blocks
  default_tags        = var.default_tags
  enable_nat_gateway  = false # No NAT Gateway in prod environment
}