variable "prefix" {
  type    = string
  default = "prod-instances"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "default_tags" {
  type = map(any)
  default = {
    Owner       = "Suraaj-Vashisht"
    Environment = "prod"
    Project     = "Assignment1"
  }
}


variable "key_name" {
  type        = string
  description = "Name of the SSH key pair"
  default = "assg1-labkey"
}
