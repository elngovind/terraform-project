# Production Account Configuration
aws_region   = "us-east-1"
project_name = "myapp"
environment  = "prod"

# Account Configuration
account_type = "production"
account_id   = "123456789012"  # Replace with actual production account ID

# Network Configuration - Production VPC
vpc_cidr           = "10.0.0.0/16"
enable_nat_gateway = true

# Production Workload Subnets
web_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
app_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
db_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

# Production Compute Configuration
instance_type    = "t3.small"
min_size         = 2
max_size         = 10
desired_capacity = 3

# Production Database Configuration
db_instance_class = "db.t3.small"
db_name          = "proddb"
db_username      = "prodadmin"

# Security Configuration
enable_acm  = true
domain_name = "myapp.com"

# Cross-Account Configuration
devops_account_id = "987654321098"  # DevOps account ID
devops_vpc_cidr   = "10.100.0.0/16"

# Disable Jenkins in production account
deploy_jenkins = false