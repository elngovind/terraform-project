# Development Environment Configuration
environment = "dev"

# Network
vpc_cidr           = "10.0.0.0/16"
enable_nat_gateway = true

# Compute - Smaller instances for dev
instance_type    = "t3.micro"
min_size         = 1
max_size         = 3
desired_capacity = 1

# Database - Smaller instance for dev
db_instance_class = "db.t3.micro"

# Jenkins - Medium instance for dev
jenkins_instance_type = "t3.medium"

# ACM - Usually disabled for dev
enable_acm  = false
domain_name = ""