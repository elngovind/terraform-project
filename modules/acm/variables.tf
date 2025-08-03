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

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "create_route53_records" {
  description = "Create Route53 records for domain validation and ALB alias"
  type        = bool
  default     = false
}

variable "alb_dns_name" {
  description = "ALB DNS name for Route53 alias record"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "ALB zone ID for Route53 alias record"
  type        = string
  default     = ""
}