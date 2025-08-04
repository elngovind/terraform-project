# AP Southeast 1 (Singapore) Region Configuration
aws_region = "ap-southeast-1"
environment = "dev"

# Network
vpc_cidr = "10.2.0.0/16"
enable_nat_gateway = true

# Compute
instance_type = "t3.micro"
min_size = 1
max_size = 3
desired_capacity = 2

# Database
db_instance_class = "db.t3.micro"

# Jenkins
jenkins_instance_type = "t3.medium"

# ACM
enable_acm = false
domain_name = ""