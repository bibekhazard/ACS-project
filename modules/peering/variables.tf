variable "prefix" {
  type    = string
  default = "vpc-peering"
}

variable "default_tags" {
  type = map(any)
  default = {
    Owner       = "your-name"
    Project     = "LabWork4"
  }
}

variable "requestor_vpc_id" {
  type        = string
  description = "Requestor VPC ID (Non-Prod)"
}

variable "peer_vpc_id" {
  type        = string
  description = "Peer VPC ID (Prod)"
}

variable "requestor_vpc_cidr" {
  type        = string
  description = "Requestor VPC CIDR (Non-Prod)"
}

variable "peer_vpc_cidr" {
  type        = string
  description = "Peer VPC CIDR (Prod)"
}

variable "requestor_public_route_table_id" {
  type        = string
  description = "Requestor VPC Public Route Table ID (Non-Prod)"
}

variable "acceptor_private_route_table_ids" {
  type        = list(string)
  description = "Acceptor VPC Private Route Table IDs (Prod)"
}
