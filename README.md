# Terraform AWS Infrastructure Project

This project creates a **production-ready multi-account AWS infrastructure** using Terraform with enterprise-grade security and scalability.

## 🏭 Production Architecture

### Multi-Account Strategy

**Account Structure:**
```
Production Account (10.0.0.0/16)
├── Web Tier: 10.0.1.0/24, 10.0.2.0/24
├── App Tier: 10.0.11.0/24, 10.0.12.0/24
└── DB Tier: 10.0.21.0/24, 10.0.22.0/24

DevOps Account (10.100.0.0/16)
├── Jenkins: 10.100.1.0/24, 10.100.2.0/24
├── Tools: 10.100.11.0/24, 10.100.12.0/24
└── Monitoring: 10.100.21.0/24, 10.100.22.0/24

Development Account (10.10.0.0/16)
├── Dev Web: 10.10.1.0/24, 10.10.2.0/24
├── Dev App: 10.10.11.0/24, 10.10.12.0/24
└── Dev DB: 10.10.21.0/24, 10.10.22.0/24
```

**Security Model:**
- Cross-account IAM roles for deployment (multi-account)
- Network isolation with separate VPCs
- Jenkins in DevOps account/VPC deploys to Production
- Least privilege access principles

**Deployment Options:**
- **Multi-Account**: Separate AWS accounts for maximum isolation
- **Single-Account**: Separate VPCs within same account for cost optimization

### 🏗️ Infrastructure Components

**Per Account:**
1. **Dedicated VPC** with DNS support and custom CIDR
2. **6 Subnets** across 2 AZs (Web, App, Database tiers)
3. **Application Load Balancer** with health checks
4. **Auto Scaling Group** with CloudWatch alarms
5. **RDS MySQL** with encryption and Secrets Manager
6. **Security Groups** with restrictive rules
7. **IAM Roles** with least privilege access

**DevOps Account Only:**
- **Jenkins Server** with CI/CD tools (Docker, Terraform, kubectl)
- **Cross-account deployment roles**
- **Monitoring and logging infrastructure**



## 🚀 Quick Start

### Prerequisites

1. **Multiple AWS Accounts** (Production, DevOps, Development)
2. **AWS CLI configured** with profiles for each account
3. **Terraform >= 1.9.0** installed
4. **S3 buckets** for state storage in each account

### Step 1: Clone and Setup

```bash
git clone <your-repo>
cd Terraform-Demo

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
vim terraform.tfvars
```

### Step 2: Update Backend Configuration

Edit `main.tf` and update the S3 bucket name:

```hcl
backend "s3" {
  bucket       = "your-unique-terraform-state-bucket"  # Change this!
  key          = "dev/terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true  # S3 native locking (Terraform 1.9+)
}
```

### Step 3: Configure AWS Profiles

```bash
# Configure AWS profiles for each account
aws configure --profile devops
aws configure --profile production  
aws configure --profile development

# Verify access
aws sts get-caller-identity --profile devops
aws sts get-caller-identity --profile production
aws sts get-caller-identity --profile development
```

### Step 4: Choose Your Deployment Strategy

**📋 Quick Decision:**
- **Enterprise/Compliance**: Use [Multi-Account Deployment](MULTI-ACCOUNT-DEPLOYMENT.md)
- **Cost-Optimized/Startup**: Use [Single-Account Deployment](SINGLE-ACCOUNT-DEPLOYMENT.md)
- **Comparison**: See [Deployment Comparison](DEPLOYMENT-COMPARISON.md)

```bash
# Multi-Account Deployment
./deploy-production.sh
make deploy-devops && make deploy-production

# Single-Account Deployment
make deploy-single-account
terraform apply -var-file="environments/accounts/single-account.tfvars"
```

### Step 4: Access Your Resources

After deployment, Terraform will output:
- **Application URL**: Load balancer endpoint
- **Jenkins URL**: Jenkins server access
- **Database endpoint**: RDS connection details
- **SSH commands**: For server access

## 🔧 Configuration Options

### Account-Specific Deployments

```bash
# Multi-Account Deployment
terraform apply -var-file="environments/accounts/devops.tfvars"      # DevOps Account
terraform apply -var-file="environments/accounts/production.tfvars"  # Production Account
terraform apply -var-file="environments/accounts/development.tfvars" # Development Account

# Single-Account Deployment (Separate VPCs)
make deploy-single-account  # Deploy both Production and DevOps in same account
terraform apply -var-file="environments/accounts/single-account.tfvars"
```

### Environment-Specific Deployments

```bash
# Development environment
terraform apply -var-file="environments/dev.tfvars"

# Production environment
terraform apply -var-file="environments/prod.tfvars"
```

### Multi-Region Deployments

```bash
# Deploy to US West 2
make deploy-region REGION=us-west-2

# Deploy to EU West 1
make deploy-region REGION=eu-west-1

# Deploy to AP Southeast 1
make deploy-region REGION=ap-southeast-1
```

### Enable HTTPS with ACM

1. Set `enable_acm = true` in your `.tfvars` file
2. Provide your `domain_name`
3. Manually validate the certificate in AWS Console or set up Route53

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `account_type` | Account type (production/devops/development) | `development` |
| `aws_region` | AWS region | `us-east-1` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `web_subnet_cidrs` | Web tier subnet CIDRs | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `app_subnet_cidrs` | App tier subnet CIDRs | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `db_subnet_cidrs` | Database tier subnet CIDRs | `["10.0.21.0/24", "10.0.22.0/24"]` |
| `deployment_mode` | Deployment mode (multi-account/single-account) | `multi-account` |
| `deploy_jenkins` | Deploy Jenkins server | `false` |
| `deploy_devops_vpc` | Deploy separate DevOps VPC (single-account) | `false` |
| `devops_account_id` | DevOps account ID for cross-account access | `""` |
| `devops_vpc_cidr` | DevOps VPC CIDR (single-account mode) | `10.100.0.0/16` |
| `enable_acm` | Enable SSL certificate | `false` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `db_instance_class` | RDS instance class | `db.t3.micro` |

### Supported AWS Regions

This project works in all major AWS regions:
- **US**: us-east-1, us-east-2, us-west-1, us-west-2
- **EU**: eu-west-1, eu-west-2, eu-west-3, eu-central-1, eu-north-1
- **Asia Pacific**: ap-southeast-1, ap-southeast-2, ap-northeast-1, ap-northeast-2, ap-south-1
- **Other**: ca-central-1, sa-east-1

## 🏛️ Terraform Features Demonstrated

### Basic Features
- **Resources**: VPC, EC2, RDS, ALB, etc.
- **Variables**: Input parameters and validation
- **Outputs**: Resource information export
- **Data Sources**: AMI lookup, AZ discovery

### Intermediate Features
- **Modules**: Reusable infrastructure components
- **Count/For Each**: Dynamic resource creation
- **Conditionals**: Optional resource deployment
- **Functions**: cidrsubnet, templatefile, etc.

### Advanced Features
- **S3 Backend**: State management with native locking
- **Dynamic Blocks**: Conditional resource configuration
- **Lifecycle Rules**: Resource management policies
- **Sensitive Values**: Secure output handling
- **Template Files**: Dynamic user data generation

## 📁 Project Structure

```
├── main.tf                 # Main configuration & backend
├── variables.tf            # Global variables
├── modules.tf             # Module orchestration
├── outputs.tf             # Output definitions
├── regions.tf             # Region validation
├── deploy-production.sh   # Multi-account deployment
├── terraform.tfvars.example
├── environments/
│   ├── accounts/          # Account-specific configs
│   │   ├── production.tfvars  # Production account
│   │   ├── devops.tfvars      # DevOps account
│   │   ├── development.tfvars # Development account
│   │   └── single-account.tfvars # Single account with separate VPCs
│   ├── regions/           # Region-specific configs
│   │   ├── us-west-2.tfvars
│   │   ├── eu-west-1.tfvars
│   │   └── ap-southeast-1.tfvars
│   ├── dev.tfvars         # Development environment
│   └── prod.tfvars        # Production environment
└── modules/
    ├── networking/        # VPC, subnets, routing
    ├── security/          # Security groups, IAM
    ├── compute/           # ALB, ASG, Launch Template
    ├── database/          # RDS configuration
    ├── jenkins/           # Jenkins server setup
    ├── acm/              # SSL certificate management
    ├── cross-account/     # Cross-account IAM roles
    └── devops-vpc/        # DevOps VPC for single-account mode
```

## 🔐 Security Best Practices

### Multi-Account Security
1. **Account Isolation**: Separate AWS accounts for blast radius containment
2. **Cross-Account Roles**: Secure deployment access with external ID
3. **Network Segmentation**: Isolated VPCs per account with custom CIDRs
4. **Least Privilege**: Account-specific IAM policies and roles

### Infrastructure Security
5. **Security Groups**: Restrictive ingress rules per tier
6. **Encryption**: EBS and RDS encryption enabled by default
7. **Secrets Management**: Database credentials in AWS Secrets Manager
8. **Private Subnets**: Database and app tiers isolated from internet
9. **Conditional Resources**: Jenkins only deployed in DevOps account
10. **VPC Flow Logs**: Network monitoring and audit trails

## 🚀 Jenkins Pipeline Integration

### DevOps Account Jenkins Server

The Jenkins server (deployed only in DevOps account) comes pre-configured with:
- **Terraform**: Infrastructure as Code
- **Docker**: Containerization  
- **AWS CLI**: Multi-account AWS service interaction
- **kubectl**: Kubernetes management
- **Cross-Account Roles**: Deploy to Production from DevOps account

### Multi-Account CI/CD Pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Deploy to Development') {
            steps {
                sh 'aws sts assume-role --role-arn arn:aws:iam::DEV_ACCOUNT:role/deployment'
                sh 'terraform apply -var-file=environments/accounts/development.tfvars'
            }
        }
        stage('Deploy to Production') {
            when { branch 'main' }
            steps {
                sh 'aws sts assume-role --role-arn arn:aws:iam::PROD_ACCOUNT:role/deployment'
                sh 'terraform apply -var-file=environments/accounts/production.tfvars'
            }
        }
    }
}
```

## 🔍 Monitoring & Logging

- **CloudWatch Alarms**: Auto-scaling triggers
- **RDS Monitoring**: Enhanced monitoring enabled
- **Jenkins Logs**: CloudWatch integration
- **Application Logs**: Can be extended with CloudWatch agent

## 🛠️ Troubleshooting

### Multi-Account Issues

1. **AWS Profiles**: Ensure profiles are configured for each account
2. **Cross-Account Access**: Verify IAM roles and trust relationships
3. **State Buckets**: Separate S3 buckets required for each account
4. **VPC CIDR Conflicts**: Ensure non-overlapping CIDR blocks
5. **Workspace Management**: Use correct Terraform workspace per account

### Common Issues

6. **Account Permissions**: Verify account-specific IAM permissions
7. **Terraform Version**: Ensure version >= 1.9.0 for S3 native locking
8. **Domain Validation**: Manually validate ACM certificate if Route53 not used
9. **Jenkins Access**: Ensure Jenkins is only deployed in DevOps account

### Useful Commands

```bash
# Multi-account workspace management
terraform workspace list
terraform workspace select devops
terraform workspace new production

# Account-specific operations
terraform plan -var-file="environments/accounts/devops.tfvars"
terraform apply -var-file="environments/accounts/production.tfvars"

# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show current state
terraform show

# Destroy account-specific infrastructure
terraform destroy -var-file="environments/accounts/development.tfvars"
```

## 📚 Learning Resources

This project demonstrates Terraform concepts from basic to advanced:

1. **Beginners**: Start with `variables.tf` and `main.tf`
2. **Intermediate**: Explore module structure and account-specific configurations
3. **Advanced**: Study multi-account architecture, cross-account roles, and conditional deployments
4. **Enterprise**: Learn workspace management, state isolation, and production deployment patterns

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Note**: Remember to destroy resources when not needed to avoid unnecessary AWS charges:

```bash
# Destroy specific account infrastructure
terraform workspace select devops
terraform destroy -var-file="environments/accounts/devops.tfvars"

# Destroy all accounts (use with caution)
./deploy-production.sh --destroy
```

**⚠️ Production Warning**: Always destroy development and DevOps accounts before production to avoid dependency issues.