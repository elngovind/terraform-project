variable "account_type" {
  description = "Type of AWS account"
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

variable "devops_account_id" {
  description = "DevOps AWS Account ID"
  type        = string
  default     = ""
}

variable "production_account_id" {
  description = "Production AWS Account ID"
  type        = string
  default     = ""
}