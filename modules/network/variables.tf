variable "public_cidr_blocks" {
  type        = list(string)
  description = "Public Subnet CIDRs"
}

variable "private_cidr_blocks" {
  type        = list(string)
  description = "Private Subnet CIDRs"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "default_tags" {
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

variable "prefix" {
  type        = string
  description = "Name prefix"
}

variable "env" {
  type        = string
  description = "Deployment Environment (e.g., dev, prod)"
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Enable NAT Gateway in public subnet"
}