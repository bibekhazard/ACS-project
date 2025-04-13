variable "environment" {
  description = "Environment name (Dev, Staging, Prod)"
  type        = string
}

variable "group_name" {
  description = "Group name for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}