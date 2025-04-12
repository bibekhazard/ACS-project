terraform {
  backend "s3" {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/peering/terraform.tfstate" # Unique key for peering state
    region         = "us-east-1" # Or your desired region
    encrypt        = true
  }
}

data "terraform_remote_state" "dev_network" {
  backend = "s3"
  config = {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/dev/network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

data "terraform_remote_state" "prod_network" {
  backend = "s3"
  config = {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/prod/network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}


module "vpc_peering" {
  source = "../modules/peering"

  prefix                           = var.prefix
  default_tags                     = var.default_tags
  requestor_vpc_id               = data.terraform_remote_state.dev_network.outputs.vpc_id
  peer_vpc_id                    = data.terraform_remote_state.prod_network.outputs.vpc_id
  requestor_vpc_cidr             = data.terraform_remote_state.dev_network.outputs.vpc_cidr
  peer_vpc_cidr                  = data.terraform_remote_state.prod_network.outputs.vpc_cidr
  requestor_public_route_table_id = tolist(data.terraform_remote_state.dev_network.outputs.public_route_table_ids)[0] # Assuming first public RT
  acceptor_private_route_table_ids  = tolist(data.terraform_remote_state.prod_network.outputs.private_route_table_ids)[*] # Assuming first private RT
}