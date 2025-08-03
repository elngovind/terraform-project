#!/bin/bash

# Quick Start Script - Build Terraform Project from Scratch
set -e

echo "🚀 Terraform AWS Infrastructure - Quick Start"
echo "============================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}Step $1: $2${NC}"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Step 1: Prerequisites Check
print_step "1" "Checking Prerequisites"

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Install with: brew install terraform"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Install with: brew install awscli"
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured. Run: aws configure"
    exit 1
fi

print_info "✅ All prerequisites met"

# Step 2: Project Structure
print_step "2" "Creating Project Structure"

read -p "Enter project name (default: terraform-aws-infrastructure): " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-terraform-aws-infrastructure}

if [ -d "$PROJECT_NAME" ]; then
    print_warning "Directory $PROJECT_NAME already exists"
    read -p "Continue anyway? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        exit 1
    fi
fi

mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Create directory structure
mkdir -p modules/{networking,security,compute,database,jenkins,acm}
mkdir -p environments/regions
mkdir -p .github/workflows

print_info "✅ Project structure created"

# Step 3: S3 Backend Setup
print_step "3" "Setting up S3 Backend"

BUCKET_NAME="terraform-state-$(whoami)-$(date +%s)"
AWS_REGION=$(aws configure get region)

print_info "Creating S3 bucket: $BUCKET_NAME"

aws s3 mb s3://$BUCKET_NAME --region $AWS_REGION
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
    "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "AES256"
        }
    }]
}'

print_info "✅ S3 backend configured"

# Step 4: Core Files
print_step "4" "Creating Core Configuration Files"

# Create main.tf
cat > main.tf << EOF
terraform {
  required_version = ">= 1.9.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "$BUCKET_NAME"
    key          = "dev/terraform.tfstate"
    region       = "$AWS_REGION"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
EOF

# Create basic variables.tf
cat > variables.tf << EOF
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "$AWS_REGION"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "$PROJECT_NAME"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}
EOF

# Create terraform.tfvars
cat > terraform.tfvars << EOF
aws_region   = "$AWS_REGION"
project_name = "$PROJECT_NAME"
environment  = "dev"
vpc_cidr     = "10.0.0.0/16"
EOF

print_info "✅ Core files created"

# Step 5: Initialize
print_step "5" "Initializing Terraform"

terraform init

print_info "✅ Terraform initialized"

# Step 6: Next Steps
print_step "6" "Next Steps"

echo ""
echo "🎉 Project initialized successfully!"
echo ""
echo "Your project is ready at: $(pwd)"
echo ""
echo "Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. Build modules step by step (see SETUP-GUIDE.md)"
echo "3. Start with networking module"
echo "4. Test each module before adding the next"
echo ""
echo "Quick commands:"
echo "  terraform validate  # Validate configuration"
echo "  terraform plan      # Preview changes"
echo "  terraform apply     # Apply changes"
echo ""
echo "S3 Backend Details:"
echo "  Bucket: $BUCKET_NAME"
echo "  Region: $AWS_REGION"
echo "  Encryption: Enabled"
echo "  Versioning: Enabled"
echo ""
print_warning "Remember to destroy resources when done: terraform destroy"