#!/bin/bash

# Quick Interactive Setup Script
set -e

echo "⚡ Quick Terraform Project Setup"
echo "==============================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_question() {
    echo -e "${BLUE}[QUESTION]${NC} $1"
}

# Get user preferences
print_question "What's your project name? (default: myapp)"
read -p "Project name: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-myapp}

print_question "Which deployment strategy do you prefer?"
echo "1) Single-Account (Cost-optimized, easier setup)"
echo "2) Multi-Account (Enterprise-grade, maximum security)"
read -p "Choose (1 or 2): " STRATEGY

print_question "Which AWS region? (default: us-east-1)"
read -p "Region: " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

print_question "Do you want to deploy Jenkins? (y/n, default: y)"
read -p "Deploy Jenkins: " DEPLOY_JENKINS
DEPLOY_JENKINS=${DEPLOY_JENKINS:-y}

# Get AWS account info
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Configure based on strategy
if [ "$STRATEGY" = "1" ]; then
    print_info "Configuring for Single-Account deployment..."
    cp environments/accounts/single-account.tfvars terraform.tfvars
    
    # Update configuration
    sed -i "s/myapp/$PROJECT_NAME/g" terraform.tfvars
    sed -i "s/123456789012/$ACCOUNT_ID/g" terraform.tfvars
    sed -i "s/us-east-1/$AWS_REGION/g" terraform.tfvars
    
    if [ "$DEPLOY_JENKINS" = "y" ]; then
        sed -i "s/deploy_jenkins = true/deploy_jenkins = true/g" terraform.tfvars
    else
        sed -i "s/deploy_jenkins = true/deploy_jenkins = false/g" terraform.tfvars
    fi
    
    print_info "✅ Configured for single-account deployment"
    
else
    print_info "Configuring for Multi-Account deployment..."
    
    print_question "Which account type is this?"
    echo "1) DevOps Account (Jenkins, CI/CD tools)"
    echo "2) Production Account (Application workloads)"
    echo "3) Development Account (Development environment)"
    read -p "Choose (1, 2, or 3): " ACCOUNT_TYPE
    
    case $ACCOUNT_TYPE in
        1)
            cp environments/accounts/devops.tfvars terraform.tfvars
            print_info "✅ Configured for DevOps account"
            ;;
        2)
            cp environments/accounts/production.tfvars terraform.tfvars
            print_info "✅ Configured for Production account"
            ;;
        3)
            cp environments/accounts/development.tfvars terraform.tfvars
            print_info "✅ Configured for Development account"
            ;;
        *)
            print_info "Invalid choice, using DevOps account configuration"
            cp environments/accounts/devops.tfvars terraform.tfvars
            ;;
    esac
    
    # Update configuration
    sed -i "s/myapp/$PROJECT_NAME/g" terraform.tfvars
    sed -i "s/987654321098/$ACCOUNT_ID/g" terraform.tfvars
    sed -i "s/123456789012/$ACCOUNT_ID/g" terraform.tfvars
    sed -i "s/456789012345/$ACCOUNT_ID/g" terraform.tfvars
    sed -i "s/us-east-1/$AWS_REGION/g" terraform.tfvars
fi

# Create S3 bucket for state
print_info "Creating S3 bucket for Terraform state..."
BUCKET_NAME="terraform-state-${PROJECT_NAME}-${ACCOUNT_ID}-$(date +%s)"

aws s3 mb s3://$BUCKET_NAME --region $AWS_REGION
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
    "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "AES256"
        }
    }]
}'

# Update main.tf with bucket name
sed -i "s/terraform-state-demo-2025/$BUCKET_NAME/g" main.tf

print_info "✅ S3 bucket created and configured: $BUCKET_NAME"

# Initialize Terraform
print_info "Initializing Terraform..."
terraform init

print_info "Validating configuration..."
terraform validate

# Show summary
echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "Configuration Summary:"
echo "  Project Name: $PROJECT_NAME"
echo "  AWS Account: $ACCOUNT_ID"
echo "  AWS Region: $AWS_REGION"
echo "  State Bucket: $BUCKET_NAME"
if [ "$STRATEGY" = "1" ]; then
    echo "  Strategy: Single-Account"
    echo "  Deploy Jenkins: $DEPLOY_JENKINS"
else
    echo "  Strategy: Multi-Account"
fi
echo ""
echo "Next steps:"
echo "1. Review configuration: vim terraform.tfvars"
echo "2. Plan deployment: terraform plan"
echo "3. Deploy infrastructure: terraform apply"
echo ""
echo "Quick deployment commands:"
if [ "$STRATEGY" = "1" ]; then
    echo "  make deploy-single-account     # Automated deployment"
else
    echo "  ./deploy-production.sh         # Multi-account deployment"
fi
echo "  terraform apply                # Manual deployment"
echo ""
echo "Useful commands:"
echo "  terraform output               # Show deployment info"
echo "  terraform destroy              # Clean up resources"