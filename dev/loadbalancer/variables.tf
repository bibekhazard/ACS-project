variable "prefix" {
  type    = string
  default = "nonprod-lb"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "default_tags" {
  type = map(any)
  default = {
    Owner       = "Suraaj-Vashisht"
    Environment = "dev"
    Project     = "Assignment1"
  }
}

