# Production Environment Configuration
environment = "prod"

# Network
vpc_cidr           = "10.1.0.0/16"
enable_nat_gateway = true

# Compute - Larger instances for prod
instance_type    = "t3.small"
min_size         = 2
max_size         = 10
desired_capacity = 3

# Database - Larger instance for prod
db_instance_class = "db.t3.small"

# Jenkins - Larger instance for prod
jenkins_instance_type = "t3.large"

# ACM - Enable for production with your domain
enable_acm  = false  # Set to true and provide domain_name for production
domain_name = ""     # e.g., "yourdomain.com"