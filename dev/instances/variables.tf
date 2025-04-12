variable "prefix" {
  type    = string
  default = "nonprod-instances"
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


variable "key_name" {
  type        = string
  description = "Name of the SSH key pair"
  default = "assg1-labkey"
}

variable "your_name" {
  type    = string
  default = "Suraaj Vashisht"
}