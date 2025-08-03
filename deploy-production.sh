#!/bin/bash

# Production Deployment Script
set -e

echo "🏭 Production Deployment Script"
echo "==============================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Deploy DevOps Account Infrastructure
print_step "1" "Deploying DevOps Account Infrastructure"

print_info "Switching to DevOps account configuration..."
export AWS_PROFILE=devops  # Assumes you have AWS profiles configured

print_info "Creating DevOps workspace..."
terraform workspace select devops || terraform workspace new devops

print_info "Deploying DevOps infrastructure..."
terraform init
terraform plan -var-file="environments/accounts/devops.tfvars" -out=devops.tfplan
terraform apply devops.tfplan

print_info "✅ DevOps infrastructure deployed"

# Step 2: Deploy Production Account Infrastructure
print_step "2" "Deploying Production Account Infrastructure"

print_info "Switching to Production account configuration..."
export AWS_PROFILE=production  # Switch to production profile

print_info "Creating Production workspace..."
terraform workspace select production || terraform workspace new production

print_info "Deploying Production infrastructure..."
terraform init
terraform plan -var-file="environments/accounts/production.tfvars" -out=production.tfplan

print_warning "About to deploy to PRODUCTION account!"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    print_error "Deployment cancelled"
    exit 1
fi

terraform apply production.tfplan

print_info "✅ Production infrastructure deployed"

# Step 3: Deploy Development Account Infrastructure (Optional)
print_step "3" "Deploying Development Account Infrastructure (Optional)"

read -p "Deploy to Development account? (y/n): " DEPLOY_DEV

if [ "$DEPLOY_DEV" = "y" ]; then
    print_info "Switching to Development account configuration..."
    export AWS_PROFILE=development

    print_info "Creating Development workspace..."
    terraform workspace select development || terraform workspace new development

    print_info "Deploying Development infrastructure..."
    terraform init
    terraform plan -var-file="environments/accounts/development.tfvars" -out=development.tfplan
    terraform apply development.tfplan

    print_info "✅ Development infrastructure deployed"
fi

# Step 4: Display Deployment Information
print_step "4" "Deployment Summary"

echo ""
echo "🎉 Multi-Account Deployment Complete!"
echo ""
echo "Account Deployments:"
echo "  ✅ DevOps Account: Jenkins, CI/CD tools"
echo "  ✅ Production Account: Application infrastructure"
if [ "$DEPLOY_DEV" = "y" ]; then
    echo "  ✅ Development Account: Development environment"
fi
echo ""

print_info "Getting deployment information..."

# DevOps Account Info
export AWS_PROFILE=devops
terraform workspace select devops
echo "DevOps Account Outputs:"
terraform output

# Production Account Info
export AWS_PROFILE=production
terraform workspace select production
echo ""
echo "Production Account Outputs:"
terraform output

print_warning "Remember to configure cross-account access and VPC peering manually if needed"

echo ""
echo "Next Steps:"
echo "1. Configure Jenkins with production deployment credentials"
echo "2. Set up monitoring and alerting"
echo "3. Configure backup and disaster recovery"
echo "4. Set up CI/CD pipelines for automated deployments"