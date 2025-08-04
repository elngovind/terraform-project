# Terraform Workspace Practice Guide

## 🎯 Learning Objectives
- Understand Terraform workspaces
- Practice workspace management commands
- Deploy environment-specific infrastructure
- Compare workspace configurations

## 📚 What are Terraform Workspaces?

Terraform workspaces allow you to manage multiple environments (dev, staging, prod) with the same configuration but separate state files.

**Key Benefits:**
- Separate state files per environment
- Environment-specific variable values
- Reduced code duplication
- Easy environment switching

## 🚀 Practice Exercises

### Exercise 1: Basic Workspace Operations

```bash
# Navigate to workspace directory
cd /Users/govind-axcess/Terraform-Demo/Workspace

# Initialize Terraform
terraform init

# List available workspaces (should show 'default')
terraform workspace list

# Show current workspace
terraform workspace show

# Create new workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# List workspaces again
terraform workspace list

# Switch between workspaces
terraform workspace select dev
terraform workspace show

terraform workspace select staging
terraform workspace show

terraform workspace select prod
terraform workspace show
```

### Exercise 2: Deploy to Different Environments

```bash
# Deploy to dev environment
terraform workspace select dev
terraform plan
terraform apply -auto-approve

# Check outputs
terraform output

# Deploy to staging environment
terraform workspace select staging
terraform plan
terraform apply -auto-approve

# Check outputs
terraform output

# Deploy to prod environment
terraform workspace select prod
terraform plan
terraform apply -auto-approve

# Check outputs
terraform output
```

### Exercise 3: Compare Environments

```bash
# Compare instance types across environments
echo "=== DEV Environment ==="
terraform workspace select dev
terraform output instance_type

echo "=== STAGING Environment ==="
terraform workspace select staging
terraform output instance_type

echo "=== PROD Environment ==="
terraform workspace select prod
terraform output instance_type

# Compare full environment summaries
echo "=== DEV Summary ==="
terraform workspace select dev
terraform output environment_summary

echo "=== STAGING Summary ==="
terraform workspace select staging
terraform output environment_summary

echo "=== PROD Summary ==="
terraform workspace select prod
terraform output environment_summary
```

### Exercise 4: State File Inspection

```bash
# Check state files for different workspaces
ls -la terraform.tfstate.d/

# View state file structure
terraform workspace select dev
terraform state list

terraform workspace select staging
terraform state list

terraform workspace select prod
terraform state list
```

### Exercise 5: Workspace-Specific Modifications

```bash
# Modify dev environment only
terraform workspace select dev

# Create a dev-specific resource
cat >> dev-specific.tf << EOF
resource "aws_s3_bucket" "dev_logs" {
  count  = terraform.workspace == "dev" ? 1 : 0
  bucket = "\${var.project_name}-\${terraform.workspace}-logs-\${random_id.bucket_suffix.hex}"
}
EOF

terraform plan
terraform apply -auto-approve

# Verify it only exists in dev
terraform workspace select staging
terraform plan  # Should show no changes

terraform workspace select prod
terraform plan   # Should show no changes
```

### Exercise 6: Cleanup Practice

```bash
# Destroy resources in each environment
terraform workspace select dev
terraform destroy -auto-approve

terraform workspace select staging
terraform destroy -auto-approve

terraform workspace select prod
terraform destroy -auto-approve

# Delete workspaces (switch to default first)
terraform workspace select default
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod

# Clean up files
rm -f dev-specific.tf
```

## 🔍 Key Commands Reference

| Command | Description |
|---------|-------------|
| `terraform workspace list` | List all workspaces |
| `terraform workspace show` | Show current workspace |
| `terraform workspace new <name>` | Create new workspace |
| `terraform workspace select <name>` | Switch to workspace |
| `terraform workspace delete <name>` | Delete workspace |

## 💡 Best Practices

1. **Naming Convention**: Use consistent workspace names (dev, staging, prod)
2. **State Isolation**: Each workspace has separate state files
3. **Variable Management**: Use workspace-specific variable values
4. **Resource Naming**: Include workspace name in resource names
5. **Conditional Resources**: Use `terraform.workspace` for environment-specific resources

## 🎯 Advanced Exercises

### Exercise A: Multi-Region Workspaces

```bash
# Create region-specific workspaces
terraform workspace new us-east-1
terraform workspace new us-west-2
terraform workspace new eu-west-1

# Deploy to different regions
terraform workspace select us-east-1
terraform apply -var="aws_region=us-east-1" -auto-approve

terraform workspace select us-west-2
terraform apply -var="aws_region=us-west-2" -auto-approve

terraform workspace select eu-west-1
terraform apply -var="aws_region=eu-west-1" -auto-approve
```

### Exercise B: Workspace Variables

Create `workspace-vars.tf`:
```hcl
locals {
  workspace_configs = {
    dev = {
      instance_count = 1
      backup_enabled = false
    }
    staging = {
      instance_count = 2
      backup_enabled = true
    }
    prod = {
      instance_count = 3
      backup_enabled = true
    }
  }
  
  current_config = local.workspace_configs[terraform.workspace]
}
```

## 🏆 Success Criteria

After completing these exercises, you should be able to:
- ✅ Create and manage multiple workspaces
- ✅ Deploy different configurations per environment
- ✅ Understand state file separation
- ✅ Use workspace-specific variables
- ✅ Implement conditional resources
- ✅ Clean up resources properly

## 🚨 Important Notes

- **State Files**: Each workspace maintains separate state files
- **Default Workspace**: Cannot be deleted, always exists
- **Resource Conflicts**: Resources in different workspaces are completely isolated
- **Naming**: Use `terraform.workspace` in resource names to avoid conflicts
- **Cleanup**: Always destroy resources before deleting workspaces