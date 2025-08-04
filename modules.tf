# Networking Module
module "networking" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr
  project_name       = var.project_name
  environment        = var.environment
  enable_nat_gateway = var.enable_nat_gateway
  web_subnet_cidrs   = var.web_subnet_cidrs
  app_subnet_cidrs   = var.app_subnet_cidrs
  db_subnet_cidrs    = var.db_subnet_cidrs
}

# Security Module
module "security" {
  source = "./modules/security"

  vpc_id           = module.networking.vpc_id
  vpc_cidr_block   = module.networking.vpc_cidr_block
  project_name     = var.project_name
  environment      = var.environment
}

# ACM Module (Conditional)
module "acm" {
  source = "./modules/acm"

  enable_acm              = var.enable_acm
  domain_name             = var.domain_name
  project_name            = var.project_name
  environment             = var.environment
  create_route53_records  = false  # Set to true if you want Terraform to manage Route53
  alb_dns_name            = var.enable_acm ? module.compute.alb_dns_name : ""
  alb_zone_id             = var.enable_acm ? module.compute.alb_zone_id : ""
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  vpc_id                     = module.networking.vpc_id
  web_subnet_ids             = module.networking.web_subnet_ids
  app_subnet_ids             = module.networking.app_subnet_ids
  alb_security_group_id      = module.security.alb_security_group_id
  web_app_security_group_id  = module.security.web_app_security_group_id
  ec2_instance_profile_name  = module.security.ec2_instance_profile_name
  project_name               = var.project_name
  environment                = var.environment
  instance_type              = var.instance_type
  min_size                   = var.min_size
  max_size                   = var.max_size
  desired_capacity           = var.desired_capacity
  enable_acm                 = var.enable_acm
  acm_certificate_arn        = var.enable_acm ? module.acm.certificate_arn : ""
}

# Database Module
module "database" {
  source = "./modules/database"

  db_subnet_ids         = module.networking.db_subnet_ids
  rds_security_group_id = module.security.rds_security_group_id
  project_name          = var.project_name
  environment           = var.environment
  db_instance_class     = var.db_instance_class
  db_name               = var.db_name
  db_username           = var.db_username
}

# Jenkins Module (Conditional - DevOps account or single-account mode)
module "jenkins" {
  count  = var.deploy_jenkins ? 1 : 0
  source = "./modules/jenkins"

  web_subnet_ids             = module.networking.web_subnet_ids
  devops_web_subnet_ids      = var.deploy_devops_vpc ? module.devops_vpc[0].devops_web_subnet_ids : module.networking.web_subnet_ids
  jenkins_security_group_id  = module.security.jenkins_security_group_id
  ec2_instance_profile_name  = module.security.ec2_instance_profile_name
  project_name               = var.project_name
  environment                = var.environment
  jenkins_instance_type      = var.jenkins_instance_type
}

# DevOps VPC Module (Conditional - only in single-account mode)
module "devops_vpc" {
  count  = var.deploy_devops_vpc ? 1 : 0
  source = "./modules/devops-vpc"

  project_name             = var.project_name
  environment              = var.environment
  devops_vpc_cidr          = var.devops_vpc_cidr
  devops_web_subnet_cidrs  = var.devops_web_subnet_cidrs
  devops_app_subnet_cidrs  = var.devops_app_subnet_cidrs
}

# Cross-Account Module
module "cross_account" {
  source = "./modules/cross-account"

  account_type          = var.account_type
  project_name          = var.project_name
  environment           = var.environment
  devops_account_id     = var.devops_account_id
  production_account_id = var.production_account_id
}