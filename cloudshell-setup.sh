#!/bin/bash

# AWS CloudShell Setup Script for Terraform Project
set -e

echo "🚀 AWS CloudShell Terraform Setup"
echo "================================="

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

# Step 1: Install Terraform
print_step "1" "Installing Terraform"

if ! command -v terraform &> /dev/null; then
    print_info "Downloading Terraform..."
    wget -q https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
    unzip -q terraform_1.9.8_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_1.9.8_linux_amd64.zip
    print_info "✅ Terraform installed successfully"
else
    print_info "✅ Terraform already installed"
fi

terraform version

# Step 2: Verify AWS CLI
print_step "2" "Verifying AWS Configuration"

if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    REGION=$(aws configure get region || echo "us-east-1")
    print_info "✅ AWS CLI configured"
    print_info "Account ID: $ACCOUNT_ID"
    print_info "Region: $REGION"
else
    print_warning "AWS CLI not configured properly"
    exit 1
fi

# Step 3: Clone Repository
print_step "3" "Cloning Terraform Project"

if [ ! -d "terraform-project" ]; then
    print_info "Cloning repository..."
    git clone https://github.com/elngovind/terraform-project.git
    print_info "✅ Repository cloned"
else
    print_info "✅ Repository already exists"
fi

cd terraform-project

# Step 4: Make Scripts Executable
print_step "4" "Setting Up Scripts"

chmod +x *.sh
print_info "✅ Scripts made executable"

# Step 5: Create S3 Bucket for State
print_step "5" "Creating S3 State Bucket"

BUCKET_NAME="terraform-state-cloudshell-${ACCOUNT_ID}-$(date +%s)"

if aws s3 mb s3://$BUCKET_NAME --region $REGION; then
    print_info "✅ S3 bucket created: $BUCKET_NAME"
    
    # Enable versioning
    aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
    
    # Enable encryption
    aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
    
    print_info "✅ Bucket configured with versioning and encryption"
else
    print_warning "Failed to create S3 bucket"
    exit 1
fi

# Step 6: Update Configuration
print_step "6" "Updating Configuration"

# Update main.tf with bucket name
sed -i "s/terraform-state-demo-2025/$BUCKET_NAME/g" main.tf
print_info "✅ Backend configuration updated"

# Create terraform.tfvars from single-account template
cp environments/accounts/single-account.tfvars terraform.tfvars

# Update with current account details
sed -i "s/123456789012/$ACCOUNT_ID/g" terraform.tfvars
sed -i "s/us-east-1/$REGION/g" terraform.tfvars

print_info "✅ Variables configured for single-account deployment"

# Step 7: Initialize Terraform
print_step "7" "Initializing Terraform"

if terraform init; then
    print_info "✅ Terraform initialized successfully"
else
    print_warning "Terraform initialization failed"
    exit 1
fi

# Step 8: Validate Configuration
print_step "8" "Validating Configuration"

if terraform validate; then
    print_info "✅ Configuration is valid"
else
    print_warning "Configuration validation failed"
    exit 1
fi

# Final Instructions
print_step "9" "Setup Complete!"

echo ""
echo "🎉 CloudShell setup completed successfully!"
echo ""
echo "Your environment is ready with:"
echo "  ✅ Terraform $(terraform version | head -n1 | cut -d' ' -f2)"
echo "  ✅ AWS CLI configured for account $ACCOUNT_ID"
echo "  ✅ S3 state bucket: $BUCKET_NAME"
echo "  ✅ Project configured for single-account deployment"
echo ""
echo "Next steps:"
echo "1. Review configuration: vim terraform.tfvars"
echo "2. Deploy infrastructure: make deploy-single-account"
echo "3. Or deploy manually: terraform plan && terraform apply"
echo ""
echo "Quick commands:"
echo "  terraform plan                    # Preview changes"
echo "  terraform apply                   # Deploy infrastructure"
echo "  terraform output                  # Show deployment info"
echo "  terraform destroy                 # Clean up resources"
echo ""
print_warning "Remember: CloudShell sessions timeout after 20 minutes of inactivity"
print_warning "Save your work frequently and bookmark important URLs"