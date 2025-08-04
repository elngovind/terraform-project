#!/bin/bash

echo "🚀 Terraform Workspace Quick Start"
echo "=================================="

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Create workspaces
echo "🏗️  Creating workspaces..."
terraform workspace new dev 2>/dev/null || echo "Dev workspace already exists"
terraform workspace new staging 2>/dev/null || echo "Staging workspace already exists"
terraform workspace new prod 2>/dev/null || echo "Prod workspace already exists"

# List workspaces
echo "📋 Available workspaces:"
terraform workspace list

# Deploy to dev
echo "🔧 Deploying to DEV environment..."
terraform workspace select dev
terraform apply -auto-approve

echo "✅ Dev environment deployed!"
echo "Instance Type: $(terraform output -raw instance_type)"
echo "Bucket Name: $(terraform output -raw bucket_name)"

# Deploy to staging
echo "🔧 Deploying to STAGING environment..."
terraform workspace select staging
terraform apply -auto-approve

echo "✅ Staging environment deployed!"
echo "Instance Type: $(terraform output -raw instance_type)"
echo "Bucket Name: $(terraform output -raw bucket_name)"

# Deploy to prod
echo "🔧 Deploying to PROD environment..."
terraform workspace select prod
terraform apply -auto-approve

echo "✅ Prod environment deployed!"
echo "Instance Type: $(terraform output -raw instance_type)"
echo "Bucket Name: $(terraform output -raw bucket_name)"

echo ""
echo "🎉 All environments deployed successfully!"
echo ""
echo "📊 Environment Summary:"
echo "======================"

for env in dev staging prod; do
    echo "--- $env ---"
    terraform workspace select $env
    terraform output environment_summary
    echo ""
done

echo "🧹 To clean up all environments, run: ./cleanup.sh"