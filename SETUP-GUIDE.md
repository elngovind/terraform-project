# Step-by-Step Setup Guide

## Prerequisites

### 1. Install Required Tools
```bash
# Install Terraform (>= 1.9.0)
brew install terraform

# Install AWS CLI
brew install awscli

# Install Git
brew install git

# Verify installations
terraform version
aws --version
git --version
```

### 2. Configure AWS Credentials
```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region, Output format
```

## Step 1: Create Project Structure

```bash
# Create project directory
mkdir terraform-aws-infrastructure
cd terraform-aws-infrastructure

# Create directory structure
mkdir -p {modules/{networking,security,compute,database,jenkins,acm},terraform-configs/regions}

# Create main files
touch main.tf variables.tf outputs.tf modules.tf versions.tf regions.tf
touch terraform.tfvars.example .gitignore README.md
touch setup.sh Makefile CHANGELOG.md LICENSE

# Create module files
for module in networking security compute database jenkins acm; do
  touch modules/$module/{main.tf,variables.tf,outputs.tf}
done

# Create user data scripts
touch modules/compute/user_data.sh modules/jenkins/jenkins_user_data.sh

# Create environment files
touch terraform-configs/{dev.tfvars,prod.tfvars}
touch terraform-configs/regions/{us-west-2.tfvars,eu-west-1.tfvars,ap-southeast-1.tfvars}
```

## Step 2: Configure Terraform Backend

### 2.1 Create S3 Bucket for State
```bash
# Create unique bucket name
BUCKET_NAME="terraform-state-$(whoami)-$(date +%s)"

# Create bucket
aws s3 mb s3://$BUCKET_NAME

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### 2.2 Configure main.tf
```hcl
terraform {
  required_version = ">= 1.9.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "your-bucket-name-here"  # Replace with your bucket
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true  # S3 native locking
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}
```

## Step 3: Build Modules Step by Step

### 3.1 Start with Networking Module
```bash
# Edit modules/networking/main.tf
# Add VPC, subnets, IGW, NAT Gateway, route tables

# Edit modules/networking/variables.tf
# Add required variables

# Edit modules/networking/outputs.tf
# Add VPC ID, subnet IDs outputs
```

### 3.2 Add Security Module
```bash
# Edit modules/security/main.tf
# Add security groups and IAM roles

# Test networking + security
terraform init
terraform plan -target=module.networking -target=module.security
```

### 3.3 Add Compute Module
```bash
# Edit modules/compute/main.tf
# Add ALB, ASG, Launch Template

# Edit modules/compute/user_data.sh
# Add web server setup script

# Test with compute
terraform plan -target=module.compute
```

### 3.4 Add Database Module
```bash
# Edit modules/database/main.tf
# Add RDS instance, subnet group, secrets

# Test database
terraform plan -target=module.database
```

### 3.5 Add Jenkins Module
```bash
# Edit modules/jenkins/main.tf
# Add Jenkins EC2 instance

# Edit modules/jenkins/jenkins_user_data.sh
# Add Jenkins installation script

# Test Jenkins
terraform plan -target=module.jenkins
```

### 3.6 Add ACM Module (Optional)
```bash
# Edit modules/acm/main.tf
# Add certificate management

# Test ACM
terraform plan -target=module.acm
```

## Step 4: Configure Variables and Outputs

### 4.1 Global Variables (variables.tf)
```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraform-demo"
}

# Add all other variables...
```

### 4.2 Module Orchestration (modules.tf)
```hcl
module "networking" {
  source = "./modules/networking"
  # Pass variables
}

module "security" {
  source = "./modules/security"
  vpc_id = module.networking.vpc_id
  # Pass other variables
}

# Add all other modules...
```

### 4.3 Outputs (outputs.tf)
```hcl
output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "jenkins_url" {
  value = module.jenkins.jenkins_url
}

# Add all other outputs...
```

## Step 5: Environment Configuration

### 5.1 Create terraform.tfvars
```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

### 5.2 Configure Environment Files
```bash
# Edit terraform-configs/dev.tfvars
# Edit terraform-configs/prod.tfvars
# Edit terraform-configs/regions/*.tfvars
```

## Step 6: Testing and Validation

### 6.1 Initialize and Validate
```bash
terraform init
terraform validate
terraform fmt -recursive
```

### 6.2 Plan by Module
```bash
# Test networking first
terraform plan -target=module.networking

# Add security
terraform plan -target=module.networking -target=module.security

# Add compute
terraform plan -target=module.networking -target=module.security -target=module.compute

# Full plan
terraform plan
```

### 6.3 Apply Incrementally
```bash
# Apply networking first
terraform apply -target=module.networking

# Add security
terraform apply -target=module.networking -target=module.security

# Add compute
terraform apply -target=module.networking -target=module.security -target=module.compute

# Full apply
terraform apply
```

## Step 7: Automation and Documentation

### 7.1 Create Setup Script
```bash
chmod +x setup.sh
./setup.sh
```

### 7.2 Create Makefile
```bash
make help
make plan-dev
make deploy-dev
```

### 7.3 Add Git and CI/CD
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/repo.git
git push -u origin main
```

## Step 8: Multi-Region Testing

### 8.1 Test Different Regions
```bash
# Test US West 2
make deploy-region REGION=us-west-2

# Test EU West 1
make deploy-region REGION=eu-west-1

# Test AP Southeast 1
make deploy-region REGION=ap-southeast-1
```

### 8.2 Validate Region-Specific Features
```bash
# Check AMI availability
aws ec2 describe-images --owners amazon --region us-west-2

# Check AZ count
aws ec2 describe-availability-zones --region eu-west-1
```

## Step 9: Production Readiness

### 9.1 Security Review
- [ ] IAM roles follow least privilege
- [ ] Security groups are restrictive
- [ ] Encryption enabled for storage
- [ ] Secrets in AWS Secrets Manager

### 9.2 Monitoring Setup
- [ ] CloudWatch alarms configured
- [ ] RDS monitoring enabled
- [ ] Application logs configured

### 9.3 Backup and Recovery
- [ ] RDS automated backups
- [ ] Terraform state backup
- [ ] Disaster recovery plan

## Step 10: Cleanup

### 10.1 Destroy Resources
```bash
# Destroy specific environment
terraform destroy -var-file="terraform-configs/dev.tfvars"

# Destroy specific region
make destroy-region REGION=us-west-2

# Full destroy
terraform destroy
```

### 10.2 Clean State Bucket
```bash
# Remove state files
aws s3 rm s3://$BUCKET_NAME --recursive

# Delete bucket
aws s3 rb s3://$BUCKET_NAME
```

## Troubleshooting

### Common Issues
1. **Terraform version**: Ensure >= 1.9.0 for S3 native locking
2. **AWS permissions**: Verify IAM permissions for all services
3. **Region availability**: Check service availability in target region
4. **State conflicts**: Use proper workspace or state file separation

### Debug Commands
```bash
terraform show
terraform state list
terraform state show <resource>
terraform refresh
terraform import <resource> <id>
```

## Best Practices

1. **Start Small**: Build and test one module at a time
2. **Version Control**: Commit frequently with meaningful messages
3. **Environment Separation**: Use different state files for dev/prod
4. **Security First**: Never commit secrets or credentials
5. **Documentation**: Keep README and comments updated
6. **Testing**: Validate in dev before applying to prod
7. **Monitoring**: Set up alerts and monitoring from day one
8. **Backup**: Regular state file backups and disaster recovery plan