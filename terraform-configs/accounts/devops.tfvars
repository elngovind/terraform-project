# DevOps Account Configuration
aws_region   = "us-east-1"
project_name = "myapp"
environment  = "devops"

# Account Configuration
account_type = "devops"
account_id   = "987654321098"  # Replace with actual DevOps account ID

# Network Configuration - DevOps VPC
vpc_cidr           = "10.100.0.0/16"
enable_nat_gateway = true

# DevOps Tool Subnets
web_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24"]  # For ALB
app_subnet_cidrs = ["10.100.11.0/24", "10.100.12.0/24"] # For tools
db_subnet_cidrs  = ["10.100.21.0/24", "10.100.22.0/24"] # For tool databases

# DevOps Compute Configuration (Smaller instances)
instance_type    = "t3.micro"
min_size         = 1
max_size         = 3
desired_capacity = 1

# DevOps Database Configuration
db_instance_class = "db.t3.micro"
db_name          = "devopsdb"
db_username      = "devopsadmin"

# Jenkins Configuration
deploy_jenkins        = true
jenkins_instance_type = "t3.large"  # Larger for CI/CD workloads

# Security Configuration
enable_acm  = false
domain_name = ""

# Cross-Account Configuration
production_account_id = "123456789012"  # Production account ID
production_vpc_cidr   = "10.0.0.0/16"

# Additional DevOps Tools
deploy_monitoring = true
deploy_logging    = true