variable "environment" {
  description = "Environment name"
  type        = string
  default     = "Prod"
}

variable "group_name" {
  description = "Group name for resource naming"
  type        = string
  default     = "Group1"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "ACS730-Final"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "web_instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t3.medium"
}

variable "db_instance_type" {
  description = "EC2 instance type for database"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "assg1-labkey"
}

variable "ssh_access_cidr" {
  description = "Allowed SSH access CIDR block"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {
    CostCenter  = "ACS730"
    Application = "WebApp"
  }
}
