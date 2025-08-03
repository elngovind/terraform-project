# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "web_subnet_ids" {
  description = "IDs of the web subnets"
  value       = module.networking.web_subnet_ids
}

output "app_subnet_ids" {
  description = "IDs of the app subnets"
  value       = module.networking.app_subnet_ids
}

output "db_subnet_ids" {
  description = "IDs of the database subnets"
  value       = module.networking.db_subnet_ids
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = var.enable_acm ? "https://${var.domain_name}" : "http://${module.compute.alb_dns_name}"
}

# Database Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_instance_endpoint
}

output "database_secrets_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = module.database.secrets_manager_secret_arn
}

# Jenkins Outputs (Conditional)
output "jenkins_url" {
  description = "Jenkins server URL"
  value       = var.deploy_jenkins ? module.jenkins[0].jenkins_url : "Jenkins not deployed in this account"
}

output "jenkins_public_ip" {
  description = "Jenkins server public IP"
  value       = var.deploy_jenkins ? module.jenkins[0].jenkins_public_ip : "N/A"
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins server"
  value       = var.deploy_jenkins ? module.jenkins[0].jenkins_ssh_command : "N/A"
}

# ACM Outputs (conditional)
output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.enable_acm ? module.acm.certificate_arn : "ACM not enabled"
}

output "domain_validation_options" {
  description = "Domain validation options for manual DNS setup"
  value       = var.enable_acm ? module.acm.domain_validation_options : []
}

# Security Outputs
output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.security.ec2_instance_profile_name
}

# Cross-Account Outputs
output "cross_account_role_arn" {
  description = "ARN of the cross-account deployment role"
  value       = module.cross_account.cross_account_role_arn
}

# Deployment Information
output "deployment_info" {
  description = "Important deployment information"
  value = {
    account_type       = var.account_type
    application_url    = var.enable_acm ? "https://${var.domain_name}" : "http://${module.compute.alb_dns_name}"
    jenkins_url        = var.deploy_jenkins ? module.jenkins[0].jenkins_url : "Jenkins not deployed"
    database_endpoint  = module.database.db_instance_endpoint
    environment        = var.environment
    region            = var.aws_region
    vpc_cidr          = var.vpc_cidr
  }
}