variable "prefix" {
  type    = string
  default = "vpc-peering"
}

variable "default_tags" {
  type = map(any)
  default = {
    Owner       = "Suraaj-Vashisht"
    Project     = "Assignment1"
  }
}