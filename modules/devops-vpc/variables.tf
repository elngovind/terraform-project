variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "devops_vpc_cidr" {
  description = "CIDR block for DevOps VPC"
  type        = string
}

variable "devops_web_subnet_cidrs" {
  description = "CIDR blocks for DevOps web subnets"
  type        = list(string)
}

variable "devops_app_subnet_cidrs" {
  description = "CIDR blocks for DevOps app subnets"
  type        = list(string)
}