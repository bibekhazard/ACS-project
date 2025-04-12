variable "prefix" {
  type    = string
  default = "prod"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_cidr_blocks" {
  type    = list(string)
  default = [] # No public subnets in prod
}

variable "private_cidr_blocks" {
  type    = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "default_tags" {
  type = map(any)
  default = {
    Owner       = "Suraaj-Vashisht"
    Environment = "prod"
    Project     = "Assignment1"
  }
}