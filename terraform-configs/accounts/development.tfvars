# Development Account Configuration
aws_region   = "us-east-1"
project_name = "myapp"
environment  = "dev"

# Account Configuration
account_type = "development"
account_id   = "456789012345"  # Replace with actual development account ID

# Network Configuration - Development VPC
vpc_cidr           = "10.10.0.0/16"
enable_nat_gateway = false  # Cost optimization for dev

# Development Subnets
web_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]
app_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
db_subnet_cidrs  = ["10.10.21.0/24", "10.10.22.0/24"]

# Development Compute Configuration (Minimal resources)
instance_type    = "t3.micro"
min_size         = 1
max_size         = 2
desired_capacity = 1

# Development Database Configuration
db_instance_class = "db.t3.micro"
db_name          = "devdb"
db_username      = "devadmin"

# Security Configuration
enable_acm  = false
domain_name = ""

# Cross-Account Configuration
devops_account_id = "987654321098"  # DevOps account ID
devops_vpc_cidr   = "10.100.0.0/16"

# Disable Jenkins in development account (use DevOps account)
deploy_jenkins = false