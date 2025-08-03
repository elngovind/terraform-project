# Global Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-demo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Network Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "account_type" {
  description = "Type of AWS account (production, devops, development)"
  type        = string
  default     = "development"
  
  validation {
    condition     = contains(["production", "devops", "development"], var.account_type)
    error_message = "Account type must be production, devops, or development."
  }
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
  default     = ""
}

variable "web_subnet_cidrs" {
  description = "CIDR blocks for web subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for app subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "deploy_jenkins" {
  description = "Deploy Jenkins server"
  type        = bool
  default     = false
}

variable "devops_account_id" {
  description = "DevOps AWS Account ID for cross-account access"
  type        = string
  default     = ""
}

variable "production_account_id" {
  description = "Production AWS Account ID for cross-account access"
  type        = string
  default     = ""
}

variable "devops_vpc_cidr" {
  description = "DevOps VPC CIDR for peering"
  type        = string
  default     = "10.100.0.0/16"
}

variable "production_vpc_cidr" {
  description = "Production VPC CIDR for peering"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

# ACM Variables
variable "enable_acm" {
  description = "Enable ACM certificate creation"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for ACM certificate"
  type        = string
  default     = ""
}

# Instance Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 6
}

variable "desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

# RDS Variables
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

# Jenkins Variables
variable "jenkins_instance_type" {
  description = "Jenkins server instance type"
  type        = string
  default     = "t3.medium"
}