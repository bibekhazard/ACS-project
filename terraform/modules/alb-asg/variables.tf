variable "environment" {
  description = "Environment name (Dev, Staging, Prod)"
  type        = string
}

variable "group_name" {
  description = "Group name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "user_data_path" {
  description = "Path to user data script"
  type        = string
  default     = "user_data/webserver.sh"
}

variable "web_security_group_id" {
  description = "Web Security Group ID from compute module"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "alb_security_group_id" {
  description = "ALB Security Group ID from network module"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "assg1-labkey"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}