# Terraform Planning and Applying Commands

## Overview
Planning and applying are the core execution commands in Terraform. These commands show what changes will be made and then execute those changes.

## Core Commands

### `terraform plan`
**Purpose**: Create an execution plan showing what Terraform will do

**Syntax**:
```bash
terraform plan [options]
```

**What it does**:
1. Reads current state file
2. Compares with configuration
3. Shows planned changes
4. Validates configuration

**Step-by-step Example**:
```bash
# 1. Navigate to your Terraform project
cd /path/to/terraform/project

# 2. Create execution plan
terraform plan

# Expected output:
# Terraform will perform the following actions:
#
#   # aws_instance.web will be created
#   + resource "aws_instance" "web" {
#       + ami           = "ami-0c02fb55956c7d316"
#       + instance_type = "t3.micro"
#       ...
#     }
#
# Plan: 1 to add, 0 to change, 0 to destroy.
```

**Common Options**:
```bash
# Save plan to file
terraform plan -out=tfplan

# Plan with specific variable file
terraform plan -var-file="prod.tfvars"

# Plan with inline variables
terraform plan -var="instance_type=t3.small"

# Plan for destroy
terraform plan -destroy

# Detailed exit codes
terraform plan -detailed-exitcode

# Refresh state before planning
terraform plan -refresh=true

# Target specific resources
terraform plan -target=aws_instance.web
```

**Understanding Plan Output**:
```bash
# Symbols meaning:
# + create
# - destroy
# ~ update in-place
# -/+ destroy and re-create
# <= read (data source)

# Example output:
Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                    = "ami-0c02fb55956c7d316"
      + instance_type          = "t3.micro"
      + key_name               = "my-key"
      + vpc_security_group_ids = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

---

### `terraform apply`
**Purpose**: Apply the changes required to reach the desired state

**Syntax**:
```bash
terraform apply [options]
```

**What it does**:
1. Creates execution plan (if not provided)
2. Shows plan and asks for confirmation
3. Executes the plan
4. Updates state file

**Step-by-step Example**:
```bash
# 1. Apply changes with confirmation
terraform apply

# Terraform will show plan and ask:
# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
#
#   Enter a value: yes

# 2. Resources will be created/modified
# aws_instance.web: Creating...
# aws_instance.web: Still creating... [10s elapsed]
# aws_instance.web: Creation complete after 15s [id=i-1234567890abcdef0]
#
# Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

**Common Options**:
```bash
# Apply without confirmation
terraform apply -auto-approve

# Apply saved plan
terraform apply tfplan

# Apply with variable file
terraform apply -var-file="prod.tfvars"

# Apply with inline variables
terraform apply -var="instance_type=t3.small"

# Target specific resources
terraform apply -target=aws_instance.web

# Apply with parallelism control
terraform apply -parallelism=5

# Replace specific resource
terraform apply -replace=aws_instance.web
```

---

### `terraform destroy`
**Purpose**: Destroy Terraform-managed infrastructure

**Syntax**:
```bash
terraform destroy [options]
```

**What it does**:
1. Creates destruction plan
2. Shows what will be destroyed
3. Asks for confirmation
4. Destroys resources in reverse dependency order

**Step-by-step Example**:
```bash
# 1. Plan destruction
terraform destroy

# Terraform will show destruction plan:
# Terraform will perform the following actions:
#
#   # aws_instance.web will be destroyed
#   - resource "aws_instance" "web" {
#       - ami           = "ami-0c02fb55956c7d316"
#       - instance_type = "t3.micro"
#       ...
#     }
#
# Plan: 0 to add, 0 to change, 1 to destroy.
#
# Do you really want to destroy all resources?
#   Enter a value: yes

# 2. Resources will be destroyed
# aws_instance.web: Destroying... [id=i-1234567890abcdef0]
# aws_instance.web: Still destroying... [10s elapsed]
# aws_instance.web: Destruction complete after 15s
#
# Destroy complete! Resources: 1 destroyed.
```

**Common Options**:
```bash
# Destroy without confirmation
terraform destroy -auto-approve

# Destroy with variable file
terraform destroy -var-file="prod.tfvars"

# Target specific resources for destruction
terraform destroy -target=aws_instance.web

# Plan destruction only (don't execute)
terraform plan -destroy
```

---

## Planning and Applying Workflow

### Standard Workflow
```bash
# 1. Initialize (if not done)
terraform init

# 2. Validate configuration
terraform validate

# 3. Format code
terraform fmt

# 4. Create and review plan
terraform plan

# 5. Apply changes
terraform apply

# 6. Verify outputs
terraform output
```

### Production Workflow
```bash
# 1. Create plan file
terraform plan -out=production.tfplan

# 2. Review plan file (optional)
terraform show production.tfplan

# 3. Apply specific plan
terraform apply production.tfplan

# 4. Clean up plan file
rm production.tfplan
```

### Targeted Workflow
```bash
# 1. Plan specific resource
terraform plan -target=aws_instance.web

# 2. Apply to specific resource
terraform apply -target=aws_instance.web

# 3. Plan remaining resources
terraform plan

# 4. Apply all remaining
terraform apply
```

---

## Advanced Planning Techniques

### Using Plan Files
```bash
# Create plan file
terraform plan -out=myplan.tfplan

# Inspect plan file
terraform show myplan.tfplan

# Apply plan file
terraform apply myplan.tfplan

# Convert plan to JSON
terraform show -json myplan.tfplan > plan.json
```

### Variable Management
```bash
# Using variable files
terraform plan -var-file="environments/prod.tfvars"

# Multiple variable files
terraform plan \
  -var-file="common.tfvars" \
  -var-file="prod.tfvars"

# Inline variables
terraform plan \
  -var="environment=production" \
  -var="instance_count=3"

# Environment variables
export TF_VAR_environment=production
terraform plan
```

### Conditional Planning
```bash
# Plan with different configurations
terraform plan -var="enable_monitoring=true"
terraform plan -var="enable_monitoring=false"

# Plan for different environments
terraform workspace select production
terraform plan -var-file="prod.tfvars"

terraform workspace select staging
terraform plan -var-file="staging.tfvars"
```

---

## Understanding Plan Output

### Resource Actions
```bash
# Create new resource
+ resource "aws_instance" "web" {
    + ami           = "ami-12345"
    + instance_type = "t3.micro"
  }

# Update existing resource
~ resource "aws_instance" "web" {
    ~ instance_type = "t3.micro" -> "t3.small"
  }

# Destroy and recreate
-/+ resource "aws_instance" "web" {
    ~ ami = "ami-12345" -> "ami-67890" # forces replacement
  }

# Destroy resource
- resource "aws_instance" "web" {
    - ami           = "ami-12345"
    - instance_type = "t3.micro"
  }

# Read data source
<= data "aws_ami" "ubuntu" {
     + architecture = (known after apply)
     + id           = (known after apply)
   }
```

### Plan Summary
```bash
# At the end of plan output:
Plan: 2 to add, 1 to change, 1 to destroy.

# Meaning:
# - 2 resources will be created
# - 1 resource will be modified in place
# - 1 resource will be destroyed
```

---

## Error Handling and Troubleshooting

### Common Planning Errors

#### Configuration Errors
```bash
# Error: Invalid configuration
terraform plan

# Fix: Validate first
terraform validate
terraform fmt
terraform plan
```

#### State Lock Errors
```bash
# Error: State locked
# Solution: Wait or force unlock
terraform force-unlock LOCK_ID
terraform plan
```

#### Provider Errors
```bash
# Error: Provider not found
# Solution: Re-initialize
terraform init -upgrade
terraform plan
```

#### Variable Errors
```bash
# Error: Variable not defined
# Solution: Provide variable
terraform plan -var="missing_var=value"
# or add to terraform.tfvars
```

### Common Apply Errors

#### Resource Conflicts
```bash
# Error: Resource already exists
# Solution: Import existing resource
terraform import aws_instance.web i-1234567890abcdef0
terraform plan
terraform apply
```

#### Permission Errors
```bash
# Error: Access denied
# Solution: Check AWS credentials
aws sts get-caller-identity
# Update IAM permissions
terraform apply
```

#### Dependency Errors
```bash
# Error: Dependency cycle
# Solution: Review dependencies
terraform graph | dot -Tpng > graph.png
# Fix circular dependencies in configuration
```

---

## Best Practices

### 1. Always Plan Before Apply
```bash
# Good practice
terraform plan
# Review output carefully
terraform apply

# Avoid (unless in automation)
terraform apply -auto-approve
```

### 2. Use Plan Files for Production
```bash
# Production deployment
terraform plan -out=prod.tfplan
# Review plan with team
terraform apply prod.tfplan
```

### 3. Target Resources Carefully
```bash
# Use targeting sparingly
terraform plan -target=aws_instance.web
terraform apply -target=aws_instance.web

# Then plan everything
terraform plan
terraform apply
```

### 4. Handle Sensitive Data
```bash
# Use variable files for sensitive data
terraform plan -var-file="secrets.tfvars"

# Or environment variables
export TF_VAR_db_password="secret"
terraform plan
```

### 5. Validate Before Planning
```bash
# Complete validation workflow
terraform fmt
terraform validate
terraform plan
terraform apply
```

---

## Automation Scripts

### CI/CD Pipeline Script
```bash
#!/bin/bash
# deploy.sh - Automated deployment script

set -e

echo "Formatting Terraform files..."
terraform fmt -check

echo "Validating configuration..."
terraform validate

echo "Creating execution plan..."
terraform plan -out=tfplan -input=false

echo "Applying changes..."
terraform apply -input=false tfplan

echo "Cleaning up..."
rm tfplan

echo "Deployment complete!"
```

### Plan Review Script
```bash
#!/bin/bash
# plan-review.sh - Generate plan for review

terraform plan -out=review.tfplan
terraform show review.tfplan > plan-output.txt
terraform show -json review.tfplan > plan.json

echo "Plan files generated:"
echo "- review.tfplan (binary plan)"
echo "- plan-output.txt (human readable)"
echo "- plan.json (machine readable)"
```

---

## Next Steps

After mastering planning and applying:
1. **[State Management](../state-management/state-commands.md)** - Manage infrastructure state
2. **[Troubleshooting](../troubleshooting/common-errors.md)** - Handle common issues
3. **[Workspace Management](../workspace/workspace-commands.md)** - Multi-environment workflows

## Quick Reference

| Command | Purpose | Common Options |
|---------|---------|----------------|
| `terraform plan` | Show execution plan | `-out`, `-var-file`, `-target` |
| `terraform apply` | Apply changes | `-auto-approve`, `-var-file`, `-target` |
| `terraform destroy` | Destroy resources | `-auto-approve`, `-target` |
| `terraform plan -destroy` | Plan destruction | `-out`, `-var-file` |
| `terraform apply -replace` | Force resource replacement | `=resource_address` |