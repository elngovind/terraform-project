# Multi-Account Deployment Strategy

## Overview

Deploy infrastructure across **separate AWS accounts** for maximum security isolation and enterprise compliance.

```
Production Account (123456789012)
├── Production VPC (10.0.0.0/16)
│   ├── Web: 10.0.1.0/24, 10.0.2.0/24
│   ├── App: 10.0.11.0/24, 10.0.12.0/24
│   └── DB: 10.0.21.0/24, 10.0.22.0/24

DevOps Account (987654321098)
├── DevOps VPC (10.100.0.0/16)
│   ├── Jenkins: 10.100.1.0/24, 10.100.2.0/24
│   └── Tools: 10.100.11.0/24, 10.100.12.0/24

Development Account (456789012345)
└── Dev VPC (10.10.0.0/16)
    └── Development environment
```

## Prerequisites

1. **3 AWS Accounts** (Production, DevOps, Development)
2. **AWS CLI** with profiles configured
3. **Terraform >= 1.9.0**
4. **S3 buckets** for state in each account

## Step 1: Configure AWS Profiles

```bash
# Configure profiles for each account
aws configure --profile devops
aws configure --profile production
aws configure --profile development

# Verify access
aws sts get-caller-identity --profile devops
aws sts get-caller-identity --profile production
aws sts get-caller-identity --profile development
```

## Step 2: Create S3 State Buckets

```bash
# DevOps Account
export AWS_PROFILE=devops
aws s3 mb s3://terraform-state-devops-$(date +%s)
aws s3api put-bucket-versioning --bucket terraform-state-devops-$(date +%s) --versioning-configuration Status=Enabled

# Production Account
export AWS_PROFILE=production
aws s3 mb s3://terraform-state-production-$(date +%s)
aws s3api put-bucket-versioning --bucket terraform-state-production-$(date +%s) --versioning-configuration Status=Enabled

# Development Account
export AWS_PROFILE=development
aws s3 mb s3://terraform-state-development-$(date +%s)
aws s3api put-bucket-versioning --bucket terraform-state-development-$(date +%s) --versioning-configuration Status=Enabled
```

## Step 3: Update Account Configurations

### DevOps Account (`terraform-configs/accounts/devops.tfvars`)
```hcl
account_type = "devops"
account_id   = "987654321098"  # Your DevOps account ID
vpc_cidr     = "10.100.0.0/16"
deploy_jenkins = true
production_account_id = "123456789012"
```

### Production Account (`terraform-configs/accounts/production.tfvars`)
```hcl
account_type = "production"
account_id   = "123456789012"  # Your Production account ID
vpc_cidr     = "10.0.0.0/16"
deploy_jenkins = false
devops_account_id = "987654321098"
```

### Development Account (`terraform-configs/accounts/development.tfvars`)
```hcl
account_type = "development"
account_id   = "456789012345"  # Your Development account ID
vpc_cidr     = "10.10.0.0/16"
deploy_jenkins = false
devops_account_id = "987654321098"
```

## Step 4: Deploy Infrastructure

### Option 1: Automated Deployment
```bash
./deploy-production.sh
```

### Option 2: Manual Step-by-Step
```bash
# 1. Deploy DevOps Account (Jenkins, CI/CD tools)
export AWS_PROFILE=devops
terraform workspace new devops
terraform init
terraform apply -var-file="terraform-configs/accounts/devops.tfvars"

# 2. Deploy Production Account (Application workloads)
export AWS_PROFILE=production
terraform workspace new production
terraform init
terraform apply -var-file="terraform-configs/accounts/production.tfvars"

# 3. Deploy Development Account (Development environment)
export AWS_PROFILE=development
terraform workspace new development
terraform init
terraform apply -var-file="terraform-configs/accounts/development.tfvars"
```

### Option 3: Using Makefile
```bash
make deploy-devops
make deploy-production
make deploy-development
```

## Step 5: Configure Cross-Account Access

After deployment, configure Jenkins in DevOps account to deploy to Production:

```bash
# In Jenkins, configure AWS credentials with cross-account role
# Role ARN: arn:aws:iam::123456789012:role/myapp-prod-cross-account-deployment
```

## Step 6: Verify Deployment

```bash
# Check DevOps account outputs
export AWS_PROFILE=devops
terraform workspace select devops
terraform output

# Check Production account outputs
export AWS_PROFILE=production
terraform workspace select production
terraform output
```

## Benefits

- **Maximum Security**: Account-level isolation
- **Compliance**: Meets strict regulatory requirements
- **Blast Radius**: Complete failure isolation
- **Enterprise Scale**: Supports large organizations
- **Separate Billing**: Clear cost allocation per environment

## Cleanup

```bash
# Destroy in reverse order
export AWS_PROFILE=development
terraform destroy -var-file="terraform-configs/accounts/development.tfvars"

export AWS_PROFILE=production
terraform destroy -var-file="terraform-configs/accounts/production.tfvars"

export AWS_PROFILE=devops
terraform destroy -var-file="terraform-configs/accounts/devops.tfvars"
```

## Troubleshooting

- **Profile Issues**: Ensure AWS profiles are correctly configured
- **Cross-Account Access**: Verify IAM roles and trust relationships
- **State Conflicts**: Use separate S3 buckets for each account
- **CIDR Conflicts**: Ensure non-overlapping VPC CIDRs