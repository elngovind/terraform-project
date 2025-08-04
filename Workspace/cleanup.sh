#!/bin/bash

echo "🧹 Terraform Workspace Cleanup"
echo "==============================="

# Destroy resources in each environment
for env in dev staging prod; do
    echo "🗑️  Destroying $env environment..."
    terraform workspace select $env
    terraform destroy -auto-approve
    echo "✅ $env environment destroyed!"
done

# Switch to default workspace
terraform workspace select default

# Delete workspaces
echo "🗑️  Deleting workspaces..."
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod

echo "✅ All workspaces cleaned up!"
echo "📋 Remaining workspaces:"
terraform workspace list