variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "web_subnet_ids" {
  description = "List of web subnet IDs"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "List of app subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "web_app_security_group_id" {
  description = "Web/App security group ID"
  type        = string
}

variable "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

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

variable "enable_acm" {
  description = "Enable ACM certificate"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
  default     = ""
}