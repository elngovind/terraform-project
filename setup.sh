#!/bin/bash

# Terraform AWS Infrastructure Setup Script
# This script helps you set up the Terraform project step by step

set -e

echo "🚀 Terraform AWS Infrastructure Setup"
echo "====================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check prerequisites
print_header "Checking Prerequisites"

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install Terraform >= 1.9.0"
    echo "Visit: https://www.terraform.io/downloads.html"
    exit 1
fi

# Check Terraform version
TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
print_status "Terraform version: $TERRAFORM_VERSION"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install AWS CLI"
    echo "Visit: https://aws.amazon.com/cli/"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure'"
    exit 1
fi

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
print_status "AWS Account: $AWS_ACCOUNT"
print_status "AWS Region: $AWS_REGION"

# Step 1: Create S3 bucket for state
print_header "Step 1: S3 Backend Setup"

read -p "Enter a unique S3 bucket name for Terraform state (or press Enter for default): " BUCKET_NAME
if [ -z "$BUCKET_NAME" ]; then
    BUCKET_NAME="terraform-state-demo-$(date +%s)"
fi

print_status "Creating S3 bucket: $BUCKET_NAME"

# Create S3 bucket
if aws s3 mb s3://$BUCKET_NAME --region $AWS_REGION; then
    print_status "S3 bucket created successfully"
    
    # Enable versioning
    aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
    print_status "S3 bucket versioning enabled"
    
    # Enable server-side encryption
    aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
    print_status "S3 bucket encryption enabled"
    
else
    print_warning "S3 bucket might already exist or there was an error"
fi

# Update main.tf with bucket name
print_status "Updating main.tf with bucket name..."
sed -i.bak "s/terraform-state-demo-2025/$BUCKET_NAME/g" main.tf
print_status "Backend configuration updated"

# Step 2: Configure variables
print_header "Step 2: Variable Configuration"

if [ ! -f "terraform.tfvars" ]; then
    print_status "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    
    # Update region in tfvars
    sed -i.bak "s/us-east-1/$AWS_REGION/g" terraform.tfvars
    
    print_status "terraform.tfvars created. Please review and modify as needed."
    print_warning "Important: Review terraform.tfvars file before proceeding!"
    
    read -p "Do you want to edit terraform.tfvars now? (y/n): " EDIT_VARS
    if [ "$EDIT_VARS" = "y" ] || [ "$EDIT_VARS" = "Y" ]; then
        ${EDITOR:-vim} terraform.tfvars
    fi
else
    print_status "terraform.tfvars already exists"
fi

# Step 3: Initialize Terraform
print_header "Step 3: Terraform Initialization"

print_status "Initializing Terraform..."
if terraform init; then
    print_status "Terraform initialized successfully"
else
    print_error "Terraform initialization failed"
    exit 1
fi

# Step 4: Validate configuration
print_header "Step 4: Configuration Validation"

print_status "Validating Terraform configuration..."
if terraform validate; then
    print_status "Configuration is valid"
else
    print_error "Configuration validation failed"
    exit 1
fi

# Step 5: Plan deployment
print_header "Step 5: Deployment Planning"

print_status "Creating deployment plan..."
if terraform plan -out=tfplan; then
    print_status "Plan created successfully"
else
    print_error "Planning failed"
    exit 1
fi

# Step 6: Apply (optional)
print_header "Step 6: Infrastructure Deployment"

echo -e "\n${YELLOW}Ready to deploy infrastructure!${NC}"
echo "This will create:"
echo "  • VPC with 6 subnets"
echo "  • Application Load Balancer"
echo "  • Auto Scaling Group with Launch Template"
echo "  • RDS MySQL database"
echo "  • Jenkins server"
echo "  • Security groups and IAM roles"
echo ""

read -p "Do you want to apply the changes now? (y/n): " APPLY_NOW
if [ "$APPLY_NOW" = "y" ] || [ "$APPLY_NOW" = "Y" ]; then
    print_status "Applying Terraform configuration..."
    if terraform apply tfplan; then
        print_status "Infrastructure deployed successfully!"
        
        # Show outputs
        print_header "Deployment Information"
        terraform output
        
        print_status "Setup completed successfully! 🎉"
        echo ""
        echo "Next steps:"
        echo "1. Access your application via the ALB URL"
        echo "2. Configure Jenkins at the provided URL"
        echo "3. Set up your CI/CD pipelines"
        echo ""
        print_warning "Remember to run 'terraform destroy' when you're done to avoid charges!"
        
    else
        print_error "Deployment failed"
        exit 1
    fi
else
    print_status "Skipping deployment. You can run 'terraform apply tfplan' later."
fi

print_header "Setup Complete"
print_status "Your Terraform project is ready!"
echo ""
echo "Useful commands:"
echo "  terraform plan                    # Preview changes"
echo "  terraform apply                   # Apply changes"
echo "  terraform destroy                 # Destroy infrastructure"
echo "  terraform output                  # Show outputs"
echo "  terraform state list              # List resources"
echo ""
echo "Environment-specific deployments:"
echo "  terraform apply -var-file='environments/dev.tfvars'"
echo "  terraform apply -var-file='environments/prod.tfvars'"