#!/bin/bash

# Module Builder Script - Build Terraform modules step by step
set -e

echo "🏗️ Terraform Module Builder"
echo "==========================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}Building: $1 Module${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create module template
create_module() {
    local module_name=$1
    local description=$2
    
    print_step "$module_name"
    
    mkdir -p modules/$module_name
    
    # Create main.tf template
    cat > modules/$module_name/main.tf << EOF
# $description Module
# Add your resources here

# Example resource (replace with actual resources)
# resource "aws_example" "main" {
#   name = "\${var.project_name}-\${var.environment}-example"
# }
EOF

    # Create variables.tf template
    cat > modules/$module_name/variables.tf << EOF
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Add module-specific variables here
EOF

    # Create outputs.tf template
    cat > modules/$module_name/outputs.tf << EOF
# Add module outputs here
# output "example_id" {
#   description = "ID of the example resource"
#   value       = aws_example.main.id
# }
EOF

    print_info "✅ $module_name module template created"
}

# Function to test module
test_module() {
    local module_name=$1
    
    print_info "Testing $module_name module..."
    
    if terraform plan -target=module.$module_name > /dev/null 2>&1; then
        print_info "✅ $module_name module test passed"
    else
        print_error "❌ $module_name module test failed"
        return 1
    fi
}

# Main menu
show_menu() {
    echo ""
    echo "Select module to build:"
    echo "1) Networking (VPC, Subnets, IGW, NAT)"
    echo "2) Security (Security Groups, IAM)"
    echo "3) Compute (ALB, ASG, Launch Template)"
    echo "4) Database (RDS, Secrets Manager)"
    echo "5) Jenkins (EC2, User Data)"
    echo "6) ACM (SSL Certificate)"
    echo "7) Build All Modules"
    echo "8) Test Current Configuration"
    echo "9) Exit"
    echo ""
}

# Build networking module
build_networking() {
    print_step "Networking"
    
    cat > modules/networking/main.tf << 'EOF'
# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "web" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-web-subnet-${count.index + 1}"
    Type = "Public"
  }
}

# Private Subnets (App)
resource "aws_subnet" "app" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name = "${var.project_name}-${var.environment}-app-subnet-${count.index + 1}"
    Type = "Private"
  }
}

# Private Subnets (DB)
resource "aws_subnet" "db" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-${count.index + 1}"
    Type = "Private"
  }
}

# NAT Gateway
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.web[0].id
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-gateway"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "web" {
  count = 2
  subnet_id      = aws_subnet.web[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "app" {
  count = 2
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
  count = 2
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private.id
}

data "aws_availability_zones" "available" {
  state = "available"
}
EOF

    cat > modules/networking/variables.tf << 'EOF'
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}
EOF

    cat > modules/networking/outputs.tf << 'EOF'
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "web_subnet_ids" {
  description = "IDs of the web subnets"
  value       = aws_subnet.web[*].id
}

output "app_subnet_ids" {
  description = "IDs of the app subnets"
  value       = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.db[*].id
}
EOF

    # Add to modules.tf
    if ! grep -q "module \"networking\"" modules.tf 2>/dev/null; then
        cat >> modules.tf << 'EOF'
module "networking" {
  source = "./modules/networking"

  vpc_cidr           = var.vpc_cidr
  project_name       = var.project_name
  environment        = var.environment
  enable_nat_gateway = var.enable_nat_gateway
}
EOF
    fi

    # Add variables
    if ! grep -q "enable_nat_gateway" variables.tf; then
        cat >> variables.tf << 'EOF'

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}
EOF
    fi

    print_info "✅ Networking module built"
}

# Interactive mode
while true; do
    show_menu
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1)
            build_networking
            ;;
        2)
            create_module "security" "Security Groups and IAM"
            ;;
        3)
            create_module "compute" "Load Balancer and Auto Scaling"
            ;;
        4)
            create_module "database" "RDS Database"
            ;;
        5)
            create_module "jenkins" "Jenkins CI/CD Server"
            ;;
        6)
            create_module "acm" "SSL Certificate Management"
            ;;
        7)
            print_info "Building all modules..."
            build_networking
            create_module "security" "Security Groups and IAM"
            create_module "compute" "Load Balancer and Auto Scaling"
            create_module "database" "RDS Database"
            create_module "jenkins" "Jenkins CI/CD Server"
            create_module "acm" "SSL Certificate Management"
            print_info "✅ All modules created"
            ;;
        8)
            print_info "Testing configuration..."
            terraform validate
            terraform plan
            ;;
        9)
            print_info "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid choice. Please try again."
            ;;
    esac
    
    read -p "Press Enter to continue..."
done