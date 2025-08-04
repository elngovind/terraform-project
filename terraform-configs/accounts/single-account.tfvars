# Single Account Configuration - Separate VPCs for DevOps and Production
aws_region   = "us-east-1"
project_name = "myapp"
environment  = "single-account"

# Account Configuration
account_type = "single-account"
account_id   = "123456789012"  # Replace with your account ID

# Deployment Mode - Deploy both DevOps and Production in same account
deployment_mode = "single-account"  # Options: multi-account, single-account

# Production VPC Configuration
vpc_cidr           = "10.0.0.0/16"
enable_nat_gateway = true

# Production Workload Subnets
web_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

# DevOps VPC Configuration (separate VPC in same account)
devops_vpc_cidr           = "10.100.0.0/16"
devops_web_subnet_cidrs   = ["10.100.1.0/24", "10.100.2.0/24"]
devops_app_subnet_cidrs   = ["10.100.11.0/24", "10.100.12.0/24"]
devops_db_subnet_cidrs    = ["10.100.21.0/24", "10.100.22.0/24"]

# Production Compute Configuration
instance_type    = "t3.small"
min_size         = 2
max_size         = 10
desired_capacity = 3

# Production Database Configuration
db_instance_class = "db.t3.small"
db_name          = "proddb"
db_username      = "prodadmin"

# DevOps Configuration
deploy_jenkins        = true
jenkins_instance_type = "t3.large"
deploy_devops_vpc     = true  # Deploy separate DevOps VPC

# Security Configuration
enable_acm  = true
domain_name = "myapp.com"

# VPC Peering between Production and DevOps VPCs
enable_vpc_peering = true