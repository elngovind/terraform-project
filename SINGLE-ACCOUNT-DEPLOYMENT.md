# Single-Account Deployment Strategy

## Overview

Deploy infrastructure within a **single AWS account** using separate VPCs for cost optimization while maintaining workload isolation.

```
Single AWS Account (123456789012)
├── Production VPC (10.0.0.0/16)
│   ├── Web: 10.0.1.0/24, 10.0.2.0/24
│   ├── App: 10.0.11.0/24, 10.0.12.0/24
│   └── DB: 10.0.21.0/24, 10.0.22.0/24
│
└── DevOps VPC (10.100.0.0/16)
    ├── Jenkins: 10.100.1.0/24, 10.100.2.0/24
    └── Tools: 10.100.11.0/24, 10.100.12.0/24
```

## Prerequisites

1. **Single AWS Account** with appropriate permissions
2. **AWS CLI** configured
3. **Terraform >= 1.9.0**
4. **S3 bucket** for state storage

## Step 1: Configure AWS CLI

```bash
# Configure AWS CLI for your account
aws configure

# Verify access
aws sts get-caller-identity
```

## Step 2: Create S3 State Bucket

```bash
# Create state bucket
BUCKET_NAME="terraform-state-single-account-$(date +%s)"
aws s3 mb s3://$BUCKET_NAME

# Enable versioning and encryption
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
    "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "AES256"
        }
    }]
}'
```

## Step 3: Update Backend Configuration

Edit `main.tf` and update the S3 bucket name:

```hcl
backend "s3" {
  bucket       = "your-bucket-name-here"  # Replace with your bucket
  key          = "single-account/terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
}
```

## Step 4: Configure Single-Account Variables

Update `terraform-configs/accounts/single-account.tfvars`:

```hcl
# Single Account Configuration
aws_region   = "us-east-1"
project_name = "myapp"
environment  = "single-account"

# Account Configuration
account_type    = "single-account"
account_id      = "123456789012"  # Your account ID
deployment_mode = "single-account"

# Production VPC Configuration
vpc_cidr           = "10.0.0.0/16"
web_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
app_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
db_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]

# DevOps VPC Configuration
deploy_devops_vpc       = true
devops_vpc_cidr         = "10.100.0.0/16"
devops_web_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24"]
devops_app_subnet_cidrs = ["10.100.11.0/24", "10.100.12.0/24"]

# Jenkins Configuration
deploy_jenkins        = true
jenkins_instance_type = "t3.large"

# Enable VPC Peering
enable_vpc_peering = true
```

## Step 5: Deploy Infrastructure

### Option 1: Using Makefile (Recommended)
```bash
make deploy-single-account
```

### Option 2: Manual Deployment
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="terraform-configs/accounts/single-account.tfvars" -out=tfplan

# Apply deployment
terraform apply tfplan
```

### Option 3: Step-by-Step Validation
```bash
# Validate configuration
terraform validate

# Plan with target (deploy networking first)
terraform plan -var-file="terraform-configs/accounts/single-account.tfvars" -target=module.networking -target=module.devops_vpc

# Apply networking
terraform apply -var-file="terraform-configs/accounts/single-account.tfvars" -target=module.networking -target=module.devops_vpc

# Deploy remaining infrastructure
terraform apply -var-file="terraform-configs/accounts/single-account.tfvars"
```

## Step 6: Verify Deployment

```bash
# Check outputs
terraform output

# Verify VPCs
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=myapp"

# Check Jenkins access
curl -I http://$(terraform output -raw jenkins_url)
```

## Step 7: Configure Jenkins

1. Access Jenkins at the provided URL
2. Configure AWS credentials for same-account deployments
3. Set up pipelines for Production and DevOps VPC deployments

## Benefits

- **Cost Savings**: No cross-account data transfer charges
- **Simplified Management**: Single billing and IAM management
- **Network Isolation**: Separate VPCs maintain security boundaries
- **Workload Separation**: DevOps tools isolated from production
- **Easy Setup**: Single account configuration

## Architecture Details

### Production VPC (10.0.0.0/16)
- **Web Subnets**: Public subnets for load balancers
- **App Subnets**: Private subnets for application servers
- **DB Subnets**: Private subnets for databases

### DevOps VPC (10.100.0.0/16)
- **Jenkins Subnets**: Public subnets for Jenkins access
- **Tools Subnets**: Private subnets for CI/CD tools

### VPC Peering
- Enables communication between Production and DevOps VPCs
- Allows Jenkins to deploy to Production VPC
- Maintains network isolation while enabling necessary connectivity

## Cleanup

```bash
# Destroy infrastructure
terraform destroy -var-file="terraform-configs/accounts/single-account.tfvars"

# Delete state bucket (optional)
aws s3 rb s3://$BUCKET_NAME --force
```

## Troubleshooting

- **CIDR Conflicts**: Ensure Production and DevOps VPCs have non-overlapping CIDRs
- **VPC Peering**: Verify peering connection is active and routes are configured
- **Jenkins Access**: Check security groups allow access from your IP
- **Resource Limits**: Ensure account has sufficient limits for all resources

## Cost Optimization Tips

- Use smaller instance types for development workloads
- Disable NAT Gateway for DevOps VPC if not needed
- Use spot instances for non-critical workloads
- Set up CloudWatch billing alarms