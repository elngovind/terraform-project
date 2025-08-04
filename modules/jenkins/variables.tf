variable "web_subnet_ids" {
  description = "List of web subnet IDs"
  type        = list(string)
}

variable "devops_web_subnet_ids" {
  description = "List of DevOps web subnet IDs"
  type        = list(string)
}

variable "jenkins_security_group_id" {
  description = "Jenkins security group ID"
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

variable "jenkins_instance_type" {
  description = "Jenkins server instance type"
  type        = string
  default     = "t3.medium"
}