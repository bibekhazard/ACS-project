variable "environment" {
  description = "Environment name (Dev, Staging, Prod)"
  type        = string
}

variable "group_name" {
  description = "Group name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from network module"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs from network module"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs from network module"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_type" {
  description = "EC2 instance type for database"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "assg1-labkey"
}

variable "ssh_access_cidr" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
variable "alb_security_group_id" {
  description = "ALB Security Group ID"
  type        = string
}
