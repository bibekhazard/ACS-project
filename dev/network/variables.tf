variable "prefix" {
  type    = string
  default = "nonprod"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "public_cidr_blocks" {
  type    = list(string)
  default = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_cidr_blocks" {
  type    = list(string)
  default = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "default_tags" {
  type = map(any)
  default = {
    Owner       = "Suraaj-Vashisht"
    Environment = "dev"
    Project     = "Assignment1"
  }
}