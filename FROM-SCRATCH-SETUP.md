# Complete From-Scratch Setup Guide

## Option 1: AWS CloudShell Setup (Recommended for Beginners)

### Step 1: Launch AWS CloudShell

1. **Login to AWS Console**
2. **Click CloudShell icon** (terminal icon in top navigation)
3. **Wait for CloudShell to initialize** (takes 1-2 minutes)

### Step 2: Install Terraform in CloudShell

```bash
# Download and install Terraform
wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
unzip terraform_1.9.8_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version

# Verify AWS CLI (pre-installed in CloudShell)
aws sts get-caller-identity
```

### Step 3: Clone and Setup Project

```bash
# Clone the repository
git clone https://github.com/elngovind/terraform-project.git
cd terraform-project

# Make scripts executable
chmod +x *.sh

# List project structure
ls -la
```

### Step 4: Choose Your Deployment Strategy

**For Single-Account (Recommended for first-time):**
```bash
# Use single-account setup
cp terraform-configs/accounts/single-account.tfvars terraform.tfvars

# Edit configuration
vim terraform.tfvars
```

**For Multi-Account (Advanced):**
```bash
# Choose account type
cp terraform-configs/accounts/devops.tfvars terraform.tfvars
# OR
cp terraform-configs/accounts/production.tfvars terraform.tfvars
```

## Option 2: Local Machine Setup

### Step 1: Install Prerequisites

**macOS:**
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tools
brew install terraform awscli git
```

**Linux (Ubuntu/Debian):**
```bash
# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
```powershell
# Install Chocolatey (if not installed)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools
choco install terraform awscli git
```

### Step 2: Configure AWS CLI

```bash
# Configure AWS credentials
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)

# Verify configuration
aws sts get-caller-identity
```

## Resource Deployment Sequence

### Phase 1: Foundation Setup

#### 1.1 Create S3 State Bucket
```bash
# Create unique bucket name
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="terraform-state-${ACCOUNT_ID}-$(date +%s)"

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

echo "S3 Bucket created: $BUCKET_NAME"
```

#### 1.2 Update Backend Configuration
```bash
# Update main.tf with your bucket name
sed -i "s/terraform-state-demo-2025/$BUCKET_NAME/g" main.tf

# Verify the change
grep "bucket" main.tf
```

#### 1.3 Configure Variables
```bash
# Copy and edit terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# Update with your values
vim terraform.tfvars
```

**Required Variables to Update:**
```hcl
aws_region   = "us-east-1"          # Your preferred region
project_name = "myapp"              # Your project name
environment  = "dev"                # Environment name
account_id   = "123456789012"       # Your AWS account ID
```

### Phase 2: Infrastructure Deployment Sequence

#### 2.1 Initialize Terraform
```bash
# Initialize Terraform (downloads providers and modules)
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

#### 2.2 Deploy Infrastructure in Sequence

**Option A: Deploy All at Once (Recommended)**
```bash
# Plan deployment
terraform plan -out=tfplan

# Review the plan, then apply
terraform apply tfplan
```

**Option B: Deploy Module by Module (Learning/Debugging)**
```bash
# 1. Deploy Networking First
terraform plan -target=module.networking
terraform apply -target=module.networking

# 2. Deploy Security
terraform plan -target=module.security
terraform apply -target=module.security

# 3. Deploy Database
terraform plan -target=module.database
terraform apply -target=module.database

# 4. Deploy Compute
terraform plan -target=module.compute
terraform apply -target=module.compute

# 5. Deploy Jenkins (if enabled)
terraform plan -target=module.jenkins
terraform apply -target=module.jenkins

# 6. Deploy remaining resources
terraform apply
```

### Phase 3: Resource Deployment Order (Technical Details)

#### 3.1 Networking Layer (First)
```
1. VPC
2. Internet Gateway
3. Subnets (Public, Private)
4. NAT Gateway (if enabled)
5. Route Tables
6. Route Table Associations
```

#### 3.2 Security Layer (Second)
```
1. Security Groups
2. IAM Roles
3. IAM Policies
4. Instance Profiles
```

#### 3.3 Database Layer (Third)
```
1. DB Subnet Group
2. DB Parameter Group
3. Secrets Manager Secret
4. RDS Instance
```

#### 3.4 Compute Layer (Fourth)
```
1. Launch Template
2. Application Load Balancer
3. Target Groups
4. Auto Scaling Group
5. ALB Listeners
```

#### 3.5 DevOps Layer (Fifth)
```
1. Jenkins EC2 Instance
2. Elastic IP
3. Security Group Rules
```

#### 3.6 Optional Components (Last)
```
1. ACM Certificate (if enabled)
2. Route53 Records (if enabled)
3. CloudWatch Alarms
```

## Deployment Commands by Strategy

### Single-Account Deployment
```bash
# Quick deployment
make deploy-single-account

# Manual deployment
terraform apply -var-file="terraform-configs/accounts/single-account.tfvars"

# Step-by-step deployment
terraform plan -var-file="terraform-configs/accounts/single-account.tfvars"
terraform apply -var-file="terraform-configs/accounts/single-account.tfvars"
```

### Multi-Account Deployment
```bash
# Automated deployment
./deploy-production.sh

# Manual account-by-account
export AWS_PROFILE=devops
terraform workspace new devops
terraform apply -var-file="terraform-configs/accounts/devops.tfvars"

export AWS_PROFILE=production
terraform workspace new production
terraform apply -var-file="terraform-configs/accounts/production.tfvars"
```

## Verification Steps

### 1. Check Terraform State
```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_vpc.main

# Get outputs
terraform output
```

### 2. Verify AWS Resources
```bash
# Check VPCs
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=myapp"

# Check instances
aws ec2 describe-instances --filters "Name=tag:Project,Values=myapp"

# Check load balancers
aws elbv2 describe-load-balancers

# Check RDS instances
aws rds describe-db-instances
```

### 3. Test Application Access
```bash
# Get application URL
APP_URL=$(terraform output -raw alb_dns_name)
curl -I http://$APP_URL

# Get Jenkins URL (if deployed)
JENKINS_URL=$(terraform output -raw jenkins_url)
curl -I $JENKINS_URL
```

## Troubleshooting Common Issues

### Issue 1: Terraform Not Found
```bash
# CloudShell: Reinstall Terraform
wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
unzip terraform_1.9.8_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Local: Check PATH
echo $PATH
which terraform
```

### Issue 2: AWS Credentials
```bash
# Check credentials
aws sts get-caller-identity

# Reconfigure if needed
aws configure

# Check region
aws configure get region
```

### Issue 3: S3 Bucket Issues
```bash
# Check if bucket exists
aws s3 ls s3://your-bucket-name

# Create bucket if missing
aws s3 mb s3://your-bucket-name
```

### Issue 4: Resource Limits
```bash
# Check VPC limits
aws ec2 describe-account-attributes --attribute-names supported-platforms

# Request limit increase if needed
# Go to AWS Console > Support > Service Quotas
```

## Next Steps After Deployment

1. **Access Jenkins**: Use the Jenkins URL from terraform output
2. **Configure DNS**: Set up Route53 or your DNS provider
3. **Enable HTTPS**: Configure ACM certificate
4. **Set up Monitoring**: Configure CloudWatch alarms
5. **Backup Strategy**: Set up automated backups
6. **CI/CD Pipeline**: Configure Jenkins pipelines

## Cleanup (When Done)

```bash
# Destroy infrastructure
terraform destroy

# Remove state files
rm -rf .terraform/
rm terraform.tfstate*

# Delete S3 bucket (optional)
aws s3 rb s3://$BUCKET_NAME --force
```

## Cost Estimation

**Single-Account Deployment:**
- **Development**: ~$50-100/month
- **Production**: ~$100-200/month

**Multi-Account Deployment:**
- **All Accounts**: ~$150-300/month

**Cost Optimization:**
- Use `t3.micro` instances for development
- Disable NAT Gateway for dev environments
- Use spot instances where possible
- Set up billing alerts