# Terraform Workspace Practice Lab

## 🎯 Overview
This lab provides hands-on practice with Terraform workspaces, demonstrating how to manage multiple environments (dev, staging, prod) with the same configuration.

## 📁 Files Structure
```
Workspace/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── outputs.tf              # Output definitions
├── user_data.sh           # EC2 user data script
├── terraform.tfvars       # Variable values
├── workspace-practice.md  # Detailed practice guide
├── quick-start.sh         # Automated deployment script
├── cleanup.sh             # Cleanup script
└── README.md              # This file
```

## 🚀 Quick Start

### Option 1: Automated Setup
```bash
cd /Users/govind-axcess/Terraform-Demo/Workspace
./quick-start.sh
```

### Option 2: Manual Step-by-Step
```bash
# Initialize
terraform init

# Create workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Deploy to each environment
terraform workspace select dev && terraform apply -auto-approve
terraform workspace select staging && terraform apply -auto-approve
terraform workspace select prod && terraform apply -auto-approve
```

## 🎓 Learning Exercises

1. **Basic Operations**: Follow `workspace-practice.md` for detailed exercises
2. **Environment Comparison**: Compare resources across workspaces
3. **State Management**: Understand separate state files
4. **Conditional Resources**: Practice workspace-specific deployments

## 🧹 Cleanup
```bash
./cleanup.sh
```

## 💡 Key Concepts Demonstrated

- **Workspace Management**: Creating, switching, and deleting workspaces
- **Environment Isolation**: Separate state files per environment
- **Variable Interpolation**: Using `terraform.workspace` in configurations
- **Conditional Resources**: Environment-specific resource deployment
- **Resource Naming**: Workspace-aware naming conventions

## 🔍 What You'll Learn

- How workspaces provide environment isolation
- Managing multiple environments with single configuration
- Workspace-specific variable values and resource configurations
- Best practices for workspace naming and management
- State file organization and separation

Start with the `workspace-practice.md` file for detailed step-by-step exercises!