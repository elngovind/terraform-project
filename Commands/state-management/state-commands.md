# Terraform State Management Commands

## Overview
State management is crucial for Terraform operations. These commands help you inspect, modify, and maintain your infrastructure state.

## Core State Commands

### `terraform state list`
**Purpose**: List all resources in the state file

**Syntax**:
```bash
terraform state list [options]
```

**Examples**:
```bash
# List all resources
terraform state list

# Example output:
# aws_instance.web
# aws_security_group.web_sg
# aws_vpc.main
# module.database.aws_db_instance.main
# module.database.aws_db_subnet_group.main

# Filter by resource type
terraform state list | grep aws_instance

# List resources in specific module
terraform state list module.database
```

### `terraform state show`
**Purpose**: Show detailed information about a resource

**Syntax**:
```bash
terraform state show [resource_address]
```

**Examples**:
```bash
# Show specific resource
terraform state show aws_instance.web

# Example output:
# resource "aws_instance" "web" {
#     ami                    = "ami-0c02fb55956c7d316"
#     instance_type          = "t3.micro"
#     id                     = "i-1234567890abcdef0"
#     private_ip             = "10.0.1.100"
#     public_ip              = "54.123.45.67"
#     vpc_security_group_ids = ["sg-12345678"]
# }

# Show module resource
terraform state show module.database.aws_db_instance.main
```

### `terraform state mv`
**Purpose**: Move/rename resources in state

**Syntax**:
```bash
terraform state mv [source] [destination]
```

**Examples**:
```bash
# Rename resource
terraform state mv aws_instance.web aws_instance.web_server

# Move resource to module
terraform state mv aws_instance.web module.compute.aws_instance.web

# Move resource from module
terraform state mv module.compute.aws_instance.web aws_instance.web

# Move entire module
terraform state mv module.old_name module.new_name

# Move with index (for count/for_each)
terraform state mv 'aws_instance.web[0]' 'aws_instance.web[1]'
```

### `terraform state rm`
**Purpose**: Remove resources from state (without destroying them)

**Syntax**:
```bash
terraform state rm [resource_address]
```

**Examples**:
```bash
# Remove single resource
terraform state rm aws_instance.web

# Remove multiple resources
terraform state rm aws_instance.web aws_security_group.web_sg

# Remove module
terraform state rm module.database

# Remove resource with index
terraform state rm 'aws_instance.web[0]'

# Remove all instances of a resource
terraform state rm 'aws_instance.web'
```

**⚠️ Warning**: Resources removed from state still exist in the cloud but are no longer managed by Terraform.

### `terraform state pull`
**Purpose**: Download and output the state file

**Syntax**:
```bash
terraform state pull
```

**Examples**:
```bash
# Output state to console
terraform state pull

# Save state to file
terraform state pull > current_state.json

# Pretty print state
terraform state pull | jq '.'

# Extract specific information
terraform state pull | jq '.resources[] | select(.type=="aws_instance")'
```

### `terraform state push`
**Purpose**: Upload a local state file to remote backend

**Syntax**:
```bash
terraform state push [path]
```

**Examples**:
```bash
# Push modified state
terraform state push modified_state.json

# Force push (overwrite remote state)
terraform state push -force modified_state.json
```

**⚠️ Warning**: Use with extreme caution. Can corrupt state if used incorrectly.

---

## Advanced State Operations

### State Inspection Workflow
```bash
# 1. List all resources
terraform state list

# 2. Show specific resource details
terraform state show aws_instance.web

# 3. Pull state for analysis
terraform state pull > state_backup.json

# 4. Analyze with jq
cat state_backup.json | jq '.resources[].instances[].attributes.id'
```

### Resource Migration Workflow
```bash
# 1. Check current state
terraform state list

# 2. Plan the move
terraform plan

# 3. Move resource in state
terraform state mv aws_instance.old aws_instance.new

# 4. Update configuration to match
# Edit .tf files to reflect new resource name

# 5. Verify no changes needed
terraform plan
```

### Module Refactoring Workflow
```bash
# 1. Create new module structure
mkdir -p modules/compute

# 2. Move configuration files
mv compute.tf modules/compute/main.tf

# 3. Move state resources
terraform state mv aws_instance.web module.compute.aws_instance.web
terraform state mv aws_security_group.web module.compute.aws_security_group.web

# 4. Update main configuration
module "compute" {
  source = "./modules/compute"
  # ... variables
}

# 5. Verify
terraform plan
```

---

## State File Management

### Backup and Restore
```bash
# Create backup
terraform state pull > backup_$(date +%Y%m%d_%H%M%S).json

# List backups
ls -la backup_*.json

# Restore from backup (if needed)
terraform state push backup_20240115_143000.json
```

### State File Analysis
```bash
# Check state file size
terraform state pull | wc -c

# Count resources
terraform state list | wc -l

# Find largest resources
terraform state pull | jq -r '.resources[] | "\(.type).\(.name): \(.instances | length) instances"'

# Check for drift
terraform plan -detailed-exitcode
echo $?  # 0=no changes, 1=error, 2=changes needed
```

### State Cleanup
```bash
# Remove unused resources
terraform state list | grep "unused_resource" | xargs terraform state rm

# Clean up after resource deletion
terraform apply  # This will update state

# Refresh state to match reality
terraform refresh
```

---

## Working with Remote State

### Remote State Configuration
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Remote State Operations
```bash
# Initialize with remote backend
terraform init

# Pull remote state
terraform state pull

# Push to remote backend
terraform state push local_state.json

# Force unlock remote state
terraform force-unlock LOCK_ID
```

### State Migration
```bash
# Migrate from local to remote
terraform init -migrate-state

# Migrate between backends
# 1. Update backend configuration
# 2. Run migration
terraform init -migrate-state

# Copy state between workspaces
terraform workspace select source
terraform state pull > temp_state.json
terraform workspace select destination
terraform state push temp_state.json
```

---

## Troubleshooting State Issues

### State Lock Issues
```bash
# Check lock status
terraform plan

# If locked, check who has the lock
# (Lock info is shown in error message)

# Force unlock (use carefully)
terraform force-unlock LOCK_ID

# Verify unlock worked
terraform plan
```

### State Corruption
```bash
# Symptoms: Terraform crashes or shows unexpected changes

# 1. Backup current state
terraform state pull > corrupted_state_backup.json

# 2. Try to refresh
terraform refresh

# 3. If refresh fails, restore from backup
# (Use a known good backup)
terraform state push good_backup.json

# 4. Verify state integrity
terraform plan
```

### Missing Resources
```bash
# Resource exists in cloud but not in state

# 1. Import the resource
terraform import aws_instance.web i-1234567890abcdef0

# 2. Verify import
terraform state show aws_instance.web

# 3. Plan to check configuration matches
terraform plan
```

### Duplicate Resources
```bash
# Resource exists in both state and cloud with different IDs

# 1. Check state
terraform state show aws_instance.web

# 2. Check cloud
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# 3. Remove from state if needed
terraform state rm aws_instance.web

# 4. Re-import correct resource
terraform import aws_instance.web i-correct-instance-id
```

---

## State Best Practices

### 1. Regular Backups
```bash
#!/bin/bash
# backup-state.sh
DATE=$(date +%Y%m%d_%H%M%S)
terraform state pull > "backups/state_backup_${DATE}.json"
echo "State backed up to backups/state_backup_${DATE}.json"
```

### 2. State Validation
```bash
#!/bin/bash
# validate-state.sh
echo "Checking state consistency..."
terraform plan -detailed-exitcode
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ State is consistent with configuration"
elif [ $EXIT_CODE -eq 2 ]; then
    echo "⚠️  State drift detected - changes needed"
    terraform plan
else
    echo "❌ Error in configuration or state"
    exit 1
fi
```

### 3. Safe State Operations
```bash
# Always backup before state operations
terraform state pull > backup_before_operation.json

# Perform operation
terraform state mv aws_instance.old aws_instance.new

# Verify operation
terraform plan

# If something went wrong, restore
# terraform state push backup_before_operation.json
```

### 4. State File Security
```bash
# Encrypt state files
# Use encrypted S3 bucket for remote state
terraform {
  backend "s3" {
    bucket  = "my-terraform-state"
    key     = "prod/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# Never commit state files to version control
echo "*.tfstate" >> .gitignore
echo "*.tfstate.*" >> .gitignore
```

---

## Automation Scripts

### State Health Check
```bash
#!/bin/bash
# state-health-check.sh

echo "=== Terraform State Health Check ==="

echo "1. Checking state accessibility..."
if terraform state list > /dev/null 2>&1; then
    echo "✅ State accessible"
else
    echo "❌ Cannot access state"
    exit 1
fi

echo "2. Counting resources..."
RESOURCE_COUNT=$(terraform state list | wc -l)
echo "📊 Total resources: $RESOURCE_COUNT"

echo "3. Checking for drift..."
terraform plan -detailed-exitcode > /dev/null 2>&1
case $? in
    0) echo "✅ No drift detected" ;;
    1) echo "❌ Configuration error" ; exit 1 ;;
    2) echo "⚠️  Drift detected - run 'terraform plan' for details" ;;
esac

echo "4. State file size..."
STATE_SIZE=$(terraform state pull | wc -c)
echo "📏 State size: $STATE_SIZE bytes"

echo "=== Health check complete ==="
```

### Resource Inventory
```bash
#!/bin/bash
# resource-inventory.sh

echo "=== Terraform Resource Inventory ==="

terraform state list | while read resource; do
    echo "Resource: $resource"
    terraform state show "$resource" | grep -E "^\s*(id|arn)\s*=" | head -2
    echo "---"
done
```

---

## Next Steps

After mastering state management:
1. **[Workspace Management](../workspace/workspace-commands.md)** - Multi-environment workflows
2. **[Import/Export](../advanced/import-export.md)** - Advanced resource management
3. **[Debugging](../debugging/logging.md)** - Advanced troubleshooting

## Quick Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `terraform state list` | List resources | `terraform state list` |
| `terraform state show` | Show resource details | `terraform state show aws_instance.web` |
| `terraform state mv` | Move/rename resource | `terraform state mv old new` |
| `terraform state rm` | Remove from state | `terraform state rm aws_instance.web` |
| `terraform state pull` | Download state | `terraform state pull > backup.json` |
| `terraform state push` | Upload state | `terraform state push backup.json` |