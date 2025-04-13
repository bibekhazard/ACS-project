variable "region" {
  default = "us-east-1"
}

variable "prefix" {
  default = "acs730"
}

variable "env" {
  default = "prod"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "state_bucket" {
  default     = "acs-730-group-bucket"
  description = "S3 bucket containing the network state file"
}

