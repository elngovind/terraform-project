# Common Terraform Errors and Solutions

## Overview
This guide covers the most common Terraform errors encountered by users and provides step-by-step solutions for each.

## State-Related Errors

### Error: State Lock
```bash
Error: Error acquiring the state lock

Error message: ConditionalCheckFailedException: The conditional request failed
Lock Info:
  ID:        12345678-1234-1234-1234-123456789012
  Path:      terraform-state-bucket/terraform.tfstate
  Operation: OperationTypePlan
  Who:       user@hostname
  Version:   1.9.0
  Created:   2024-01-15 10:30:00 UTC
```

**Cause**: Another Terraform process is running or crashed without releasing the lock.

**Solutions**:
```bash
# 1. Wait for other process to complete (recommended)
# Check if another terraform process is running
ps aux | grep terraform

# 2. Force unlock (use with caution)
terraform force-unlock 12345678-1234-1234-1234-123456789012

# 3. If lock persists, check backend
aws dynamodb describe-table --table-name terraform-state-lock
```

### Error: State File Not Found
```bash
Error: Failed to load state: state file not found
```

**Cause**: State file doesn't exist or backend configuration is incorrect.

**Solutions**:
```bash
# 1. Check backend configuration
cat main.tf | grep -A 10 "backend"

# 2. Initialize backend
terraform init

# 3. If migrating, use init with migration
terraform init -migrate-state

# 4. For new infrastructure
terraform apply  # Creates new state
```

### Error: State Drift
```bash
Error: Resource not found in state but exists in cloud
```

**Cause**: Resource exists in cloud but not in Terraform state.

**Solutions**:
```bash
# 1. Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# 2. Refresh state to detect changes
terraform refresh

# 3. Plan to see differences
terraform plan
```

---

## Configuration Errors

### Error: Invalid Configuration
```bash
Error: Invalid configuration

  on main.tf line 15, in resource "aws_instance" "web":
  15:   instance_type = var.instance_type

The given value is not suitable for child module variable "instance_type"
as it is not a string.
```

**Cause**: Type mismatch or invalid syntax in configuration.

**Solutions**:
```bash
# 1. Validate configuration
terraform validate

# 2. Check variable types
# In variables.tf:
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

# 3. Format configuration
terraform fmt

# 4. Check syntax
terraform console
> var.instance_type
```

### Error: Missing Required Variable
```bash
Error: No value for required variable

  on variables.tf line 1:
   1: variable "region" {

The root module input variable "region" is not set, and has no default value.
```

**Cause**: Required variable not provided.

**Solutions**:
```bash
# 1. Set in terraform.tfvars
echo 'region = "us-east-1"' >> terraform.tfvars

# 2. Use command line
terraform plan -var="region=us-east-1"

# 3. Use environment variable
export TF_VAR_region="us-east-1"
terraform plan

# 4. Add default value
variable "region" {
  type    = string
  default = "us-east-1"
}
```

### Error: Resource Already Exists
```bash
Error: resource already exists

  on main.tf line 10, in resource "aws_s3_bucket" "example":
  10: resource "aws_s3_bucket" "example" {

A resource with the ID "my-unique-bucket" already exists.
```

**Cause**: Resource exists in AWS but not in Terraform state.

**Solutions**:
```bash
# 1. Import existing resource
terraform import aws_s3_bucket.example my-unique-bucket

# 2. Use different name
resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-v2"
}

# 3. Remove existing resource manually (if safe)
aws s3 rb s3://my-unique-bucket --force
```

---

## Provider Errors

### Error: Provider Not Found
```bash
Error: Failed to query available provider packages

Could not retrieve the list of available versions for provider
hashicorp/aws: provider registry service is unreachable
```

**Cause**: Network issues or provider registry problems.

**Solutions**:
```bash
# 1. Check internet connectivity
curl -I https://registry.terraform.io

# 2. Re-initialize with upgrade
terraform init -upgrade

# 3. Clear provider cache
rm -rf .terraform/
terraform init

# 4. Use specific provider version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.31.0"
    }
  }
}
```

### Error: Provider Version Constraint
```bash
Error: Incompatible provider version

Provider registry.terraform.io/hashicorp/aws v4.67.0 does not satisfy the
version constraints "~> 5.0" specified by the root module.
```

**Cause**: Provider version doesn't match constraints.

**Solutions**:
```bash
# 1. Update version constraint
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
}

# 2. Upgrade provider
terraform init -upgrade

# 3. Lock specific version
terraform providers lock -platform=linux_amd64
```

### Error: Authentication Failed
```bash
Error: error configuring Terraform AWS Provider: no valid credential sources for Terraform AWS Provider found
```

**Cause**: AWS credentials not configured or invalid.

**Solutions**:
```bash
# 1. Configure AWS CLI
aws configure

# 2. Check credentials
aws sts get-caller-identity

# 3. Use environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# 4. Use IAM role (EC2)
# Ensure EC2 instance has proper IAM role attached

# 5. Use AWS profile
export AWS_PROFILE=myprofile
terraform plan
```

---

## Resource Errors

### Error: Dependency Cycle
```bash
Error: Cycle: aws_security_group.web, aws_security_group.db
```

**Cause**: Circular dependency between resources.

**Solutions**:
```bash
# 1. Visualize dependencies
terraform graph | dot -Tpng > graph.png

# 2. Break circular dependency
# Instead of:
resource "aws_security_group" "web" {
  ingress {
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.db.id]
  }
}

resource "aws_security_group" "db" {
  ingress {
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.web.id]
  }
}

# Use:
resource "aws_security_group_rule" "web_to_db" {
  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id       = aws_security_group.db.id
}
```

### Error: Resource Timeout
```bash
Error: timeout while waiting for resource to become ready

  on main.tf line 20, in resource "aws_instance" "web":
  20: resource "aws_instance" "web" {

Timeout waiting for instance i-1234567890abcdef0 to become ready
```

**Cause**: Resource taking too long to provision.

**Solutions**:
```bash
# 1. Increase timeout
resource "aws_instance" "web" {
  # ... other configuration
  
  timeouts {
    create = "10m"
    update = "5m"
    delete = "10m"
  }
}

# 2. Check resource status manually
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# 3. Check for underlying issues
# - Security groups blocking traffic
# - Subnet configuration
# - AMI availability
```

---

## Module Errors

### Error: Module Not Found
```bash
Error: Module not found

The module address "vpc" could not be resolved.
```

**Cause**: Module source is incorrect or inaccessible.

**Solutions**:
```bash
# 1. Check module source
module "vpc" {
  source = "./modules/vpc"  # Local path
  # or
  source = "terraform-aws-modules/vpc/aws"  # Registry
  # or
  source = "git::https://github.com/user/repo.git"  # Git
}

# 2. Download modules
terraform get

# 3. Re-initialize
terraform init

# 4. Check module exists
ls -la modules/vpc/  # For local modules
```

### Error: Module Input Validation
```bash
Error: Invalid value for module argument

  on main.tf line 25, in module "vpc":
  25:   cidr_block = "invalid-cidr"

The given value is not a valid CIDR block.
```

**Cause**: Invalid input provided to module.

**Solutions**:
```bash
# 1. Check module documentation
terraform-docs modules/vpc/

# 2. Validate CIDR format
module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"  # Valid CIDR
}

# 3. Use terraform console to test
terraform console
> cidrsubnet("10.0.0.0/16", 8, 1)
```

---

## Performance Issues

### Error: Too Many API Calls
```bash
Error: Rate limit exceeded

Too many requests to AWS API. Please retry after some time.
```

**Cause**: Hitting AWS API rate limits.

**Solutions**:
```bash
# 1. Reduce parallelism
terraform apply -parallelism=1

# 2. Add delays between operations
resource "time_sleep" "wait" {
  create_duration = "30s"
}

# 3. Use depends_on to sequence operations
resource "aws_instance" "web" {
  depends_on = [time_sleep.wait]
}
```

### Error: Large State File
```bash
Error: State file too large for backend
```

**Cause**: State file exceeds backend limits.

**Solutions**:
```bash
# 1. Split into multiple state files
# Use separate backends for different components

# 2. Remove unused resources
terraform state list
terraform state rm aws_instance.unused

# 3. Use remote state data sources
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Debugging Commands

### Enable Debug Logging
```bash
# Set log level
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log

# Run command
terraform plan

# Check logs
tail -f terraform.log
```

### Analyze State
```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Show current state
terraform show

# Show in JSON format
terraform show -json > state.json
```

### Validate and Format
```bash
# Validate configuration
terraform validate

# Format files
terraform fmt -recursive

# Check formatting
terraform fmt -check
```

---

## Emergency Recovery

### Corrupted State
```bash
# 1. Backup current state
cp terraform.tfstate terraform.tfstate.backup

# 2. Try to recover
terraform refresh

# 3. If refresh fails, restore from backup
cp terraform.tfstate.backup terraform.tfstate

# 4. Manual state editing (last resort)
terraform state pull > state.json
# Edit state.json carefully
terraform state push state.json
```

### Lost State File
```bash
# 1. Try to recover from backend
terraform init

# 2. Import existing resources
terraform import aws_instance.web i-1234567890abcdef0

# 3. Recreate state from scratch
# List all resources and import them one by one
```

### Complete Reset
```bash
# 1. Backup everything
cp -r . ../terraform-backup

# 2. Clean slate
rm -rf .terraform/
rm terraform.tfstate*
rm .terraform.lock.hcl

# 3. Start fresh
terraform init
terraform plan
```

## Quick Reference

| Error Type | Quick Fix | Command |
|------------|-----------|---------|
| State Lock | Force unlock | `terraform force-unlock LOCK_ID` |
| Missing Variable | Set variable | `terraform plan -var="key=value"` |
| Provider Issue | Re-initialize | `terraform init -upgrade` |
| Config Error | Validate | `terraform validate` |
| Resource Exists | Import | `terraform import resource.name id` |
| Dependency Cycle | Check graph | `terraform graph` |