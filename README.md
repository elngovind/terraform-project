# Terraform AWS Infrastructure Project

This project creates a **production-ready multi-account AWS infrastructure** using Terraform with enterprise-grade security and scalability.

## 🏭 Production Architecture

### Deployment Strategy Options

#### **Multi-Account Strategy (Enterprise)**
```
Production Account (123456789012)
├── Production VPC (10.0.0.0/16)
│   ├── Web Tier: 10.0.1.0/24, 10.0.2.0/24
│   ├── App Tier: 10.0.11.0/24, 10.0.12.0/24
│   └── DB Tier: 10.0.21.0/24, 10.0.22.0/24

DevOps Account (987654321098)
├── DevOps VPC (10.100.0.0/16)
│   ├── Jenkins: 10.100.1.0/24, 10.100.2.0/24
│   ├── Tools: 10.100.11.0/24, 10.100.12.0/24
│   └── Monitoring: 10.100.21.0/24, 10.100.22.0/24

Development Account (456789012345)
└── Dev VPC (10.10.0.0/16)
    ├── Dev Web: 10.10.1.0/24, 10.10.2.0/24
    ├── Dev App: 10.10.11.0/24, 10.10.12.0/24
    └── Dev DB: 10.10.21.0/24, 10.10.22.0/24
```

#### **Single-Account Strategy (Cost-Optimized)**
```
Single AWS Account (123456789012)
├── Production VPC (10.0.0.0/16)
│   ├── Web Tier: 10.0.1.0/24, 10.0.2.0/24
│   ├── App Tier: 10.0.11.0/24, 10.0.12.0/24
│   └── DB Tier: 10.0.21.0/24, 10.0.22.0/24
│
└── DevOps VPC (10.100.0.0/16)
    ├── Jenkins: 10.100.1.0/24, 10.100.2.0/24
    └── Tools: 10.100.11.0/24, 10.100.12.0/24
    └── VPC Peering ←→ Production VPC
```

### Security & Deployment Models

**Multi-Account Benefits:**
- Maximum security isolation (account boundaries)
- Enterprise compliance ready (SOC2, PCI-DSS)
- Cross-account IAM roles for secure deployment
- Complete blast radius containment

**Single-Account Benefits:**
- Cost optimization (no cross-account charges)
- Simplified management (single billing/IAM)
- Network isolation via separate VPCs
- Faster setup and deployment

### 🏗️ Infrastructure Components

**Core Infrastructure (Per VPC):**
1. **VPC** with DNS support and custom CIDR blocks
2. **Multi-AZ Subnets** across 2+ Availability Zones:
   - **Public Subnets** (Web tier) - Load balancers, NAT gateways
   - **Private Subnets** (App tier) - Application servers
   - **Private Subnets** (DB tier) - Databases, internal services
3. **Application Load Balancer** with health checks and SSL termination
4. **Auto Scaling Group** with CloudWatch-based scaling policies
5. **RDS MySQL** with encryption, automated backups, and Secrets Manager
6. **Security Groups** with least-privilege access rules
7. **IAM Roles** with minimal required permissions

**DevOps Infrastructure:**
- **Jenkins Server** with pre-installed tools (Docker, Terraform, kubectl, AWS CLI)
- **Cross-account deployment roles** (multi-account mode)
- **VPC Peering** for secure communication (single-account mode)
- **CloudWatch monitoring** and centralized logging
- **Elastic IP** for consistent Jenkins access

**Security Features:**
- **Encryption at rest** for EBS volumes and RDS
- **Secrets Manager** for database credentials
- **VPC Flow Logs** for network monitoring
- **CloudWatch Alarms** for operational monitoring
- **ACM SSL Certificates** for HTTPS (optional)



## 🚀 Quick Start

### Installation

#### Install Terraform on Ubuntu/Debian
```bash
# Add HashiCorp GPG key
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install Terraform
sudo apt update && sudo apt install terraform

# Verify installation
terraform version
```

#### Install Terraform on macOS
```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify installation
terraform version
```

#### Install Terraform on Windows
```powershell
# Using Chocolatey
choco install terraform

# Using Scoop
scoop install terraform

# Verify installation
terraform version
```

### Prerequisites

**For Multi-Account Deployment:**
1. **3 AWS Accounts** (Production, DevOps, Development)
2. **AWS CLI** with profiles configured for each account
3. **Terraform >= 1.9.0** installed
4. **S3 buckets** for state storage in each account

**For Single-Account Deployment:**
1. **1 AWS Account** with appropriate permissions
2. **AWS CLI** configured
3. **Terraform >= 1.9.0** installed
4. **S3 bucket** for state storage

### Step 1: Choose Your Setup Method

**🌟 New to AWS/Terraform? Start Here:**
- **[Complete From-Scratch Setup Guide](FROM-SCRATCH-SETUP.md)** - Includes CloudShell setup and resource deployment sequence

**Quick Setup (Experienced Users):**
```bash
git clone https://github.com/elngovind/terraform-project.git
cd terraform-project

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

| **Strategy** | **Best For** | **Setup Time** | **Cost** | **Security** |
|--------------|--------------|----------------|----------|-------------|
| **Multi-Account** | Enterprise, Compliance | 30-45 min | Higher | Maximum |
| **Single-Account** | Startups, Cost-conscious | 15-20 min | Lower | Good |

**📋 Detailed Guides:**
- **Enterprise/Compliance**: [Multi-Account Deployment Guide](MULTI-ACCOUNT-DEPLOYMENT.md)
- **Cost-Optimized/Startup**: [Single-Account Deployment Guide](SINGLE-ACCOUNT-DEPLOYMENT.md)
- **Decision Help**: [Deployment Strategy Comparison](DEPLOYMENT-COMPARISON.md)

**Quick Deploy Commands:**
```bash
# Multi-Account Deployment (Enterprise)
./deploy-production.sh                    # Automated multi-account
make deploy-devops && make deploy-production  # Manual step-by-step

# Single-Account Deployment (Cost-Optimized)
make deploy-single-account               # Automated single-account
terraform apply -var-file="terraform-configs/accounts/single-account.tfvars"
```

### Step 5: Access Your Resources

After deployment, Terraform will output:
- **Application URL**: Load balancer endpoint for your web application
- **Jenkins URL**: Jenkins server for CI/CD pipeline management
- **Database Endpoint**: RDS connection details for application database
- **VPC Information**: Network details for both Production and DevOps VPCs
- **SSH Commands**: Secure access commands for EC2 instances

**Example Output:**
```bash
terraform output
# application_url = "http://myapp-alb-123456789.us-east-1.elb.amazonaws.com"
# jenkins_url = "http://54.123.45.67:8080"
# database_endpoint = "myapp-prod-db.abc123.us-east-1.rds.amazonaws.com:3306"
```

## 🔧 Configuration Options

### Deployment Mode Selection

**Multi-Account Deployment (Maximum Security):**
```bash
# Deploy to separate AWS accounts
terraform apply -var-file="terraform-configs/accounts/devops.tfvars"      # DevOps Account
terraform apply -var-file="terraform-configs/accounts/production.tfvars"  # Production Account
terraform apply -var-file="terraform-configs/accounts/development.tfvars" # Development Account

# Or use automated deployment
./deploy-production.sh
```

**Single-Account Deployment (Cost-Optimized):**
```bash
# Deploy separate VPCs in same account
make deploy-single-account
terraform apply -var-file="terraform-configs/accounts/single-account.tfvars"
```

### Environment-Specific Deployments

```bash
# Development environment
terraform apply -var-file="terraform-configs/dev.tfvars"

# Production environment
terraform apply -var-file="terraform-configs/prod.tfvars"
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

### Key Configuration Variables

#### **Core Settings**
| Variable | Description | Default | Example |
|----------|-------------|---------|----------|
| `deployment_mode` | Deployment strategy | `multi-account` | `single-account` |
| `account_type` | Account type | `development` | `production` |
| `aws_region` | AWS region | `us-east-1` | `us-west-2` |
| `project_name` | Project identifier | `terraform-demo` | `myapp` |
| `environment` | Environment name | `dev` | `prod` |

#### **Network Configuration**
| Variable | Description | Default | Notes |
|----------|-------------|---------|-------|
| `vpc_cidr` | Production VPC CIDR | `10.0.0.0/16` | Must not overlap |
| `devops_vpc_cidr` | DevOps VPC CIDR | `10.100.0.0/16` | Single-account mode |
| `web_subnet_cidrs` | Public subnet CIDRs | `["10.0.1.0/24", "10.0.2.0/24"]` | Load balancers |
| `app_subnet_cidrs` | Private subnet CIDRs | `["10.0.11.0/24", "10.0.12.0/24"]` | Applications |
| `db_subnet_cidrs` | Database subnet CIDRs | `["10.0.21.0/24", "10.0.22.0/24"]` | Databases |
| `enable_nat_gateway` | Enable NAT Gateway | `true` | For private subnets |

#### **Deployment Options**
| Variable | Description | Default | When to Use |
|----------|-------------|---------|-------------|
| `deploy_jenkins` | Deploy Jenkins server | `false` | DevOps account only |
| `deploy_devops_vpc` | Deploy DevOps VPC | `false` | Single-account mode |
| `enable_vpc_peering` | Enable VPC peering | `false` | Single-account mode |
| `enable_acm` | Enable SSL certificate | `false` | Production workloads |

#### **Resource Sizing**
| Variable | Description | Default | Production Recommended |
|----------|-------------|---------|------------------------|
| `instance_type` | EC2 instance type | `t3.micro` | `t3.small` or larger |
| `jenkins_instance_type` | Jenkins instance type | `t3.medium` | `t3.large` |
| `db_instance_class` | RDS instance class | `db.t3.micro` | `db.t3.small` or larger |
| `min_size` | ASG minimum size | `1` | `2` |
| `max_size` | ASG maximum size | `3` | `10` |
| `desired_capacity` | ASG desired capacity | `2` | `3` |

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
├── 📄 Core Configuration
│   ├── main.tf                    # Main Terraform configuration & S3 backend
│   ├── variables.tf               # Global variable definitions
│   ├── modules.tf                 # Module orchestration and dependencies
│   ├── outputs.tf                 # Output definitions for all resources
│   ├── regions.tf                 # Multi-region support and validation
│   └── terraform.tfvars.example   # Example variable configuration
│
├── 🚀 Deployment Scripts
│   ├── deploy-production.sh       # Automated multi-account deployment
│   ├── setup.sh                   # Interactive project setup
│   ├── quick-start.sh             # Quick project initialization
│   └── module-builder.sh          # Interactive module development
│
├── 📋 Documentation
│   ├── README.md                  # Main project documentation
│   ├── MULTI-ACCOUNT-DEPLOYMENT.md   # Multi-account deployment guide
│   ├── SINGLE-ACCOUNT-DEPLOYMENT.md  # Single-account deployment guide
│   ├── DEPLOYMENT-COMPARISON.md      # Strategy comparison guide
│   ├── SETUP-GUIDE.md               # Step-by-step setup instructions
│   └── PRODUCTION-ARCHITECTURE.md   # Production architecture details
│
├── ⚙️ Environment Configurations
│   └── terraform-configs/
│       ├── accounts/              # Account-specific configurations
│       │   ├── production.tfvars     # Production account settings
│       │   ├── devops.tfvars         # DevOps account settings
│       │   ├── development.tfvars    # Development account settings
│       │   └── single-account.tfvars # Single-account deployment
│       ├── regions/               # Region-specific configurations
│       │   ├── us-west-2.tfvars      # US West 2 settings
│       │   ├── eu-west-1.tfvars      # EU West 1 settings
│       │   └── ap-southeast-1.tfvars # Asia Pacific settings
│       ├── dev.tfvars             # Development environment
│       └── prod.tfvars            # Production environment
│
└── 🏗️ Infrastructure Modules
    └── modules/
        ├── networking/            # VPC, subnets, routing, NAT gateways
        ├── security/              # Security groups, IAM roles, policies
        ├── compute/               # ALB, ASG, Launch Templates, EC2
        ├── database/              # RDS, subnet groups, parameter groups
        ├── jenkins/               # Jenkins server, user data, EIP
        ├── acm/                   # SSL certificates, Route53 validation
        ├── cross-account/         # Cross-account IAM roles and policies
        └── devops-vpc/            # DevOps VPC for single-account mode
```

### 📊 Module Dependencies
```
networking ──┬── security ──┬── compute
             │              ├── database
             │              └── jenkins (conditional)
             │
             ├── devops-vpc (conditional)
             └── cross-account
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

## 🚀 Jenkins CI/CD Integration

### Jenkins Server Configuration

**Deployment Location:**
- **Multi-Account**: Deployed in DevOps account only
- **Single-Account**: Deployed in DevOps VPC

**Pre-installed Tools:**
- **Terraform** (>= 1.9.0) - Infrastructure as Code
- **Docker** & Docker Compose - Containerization
- **AWS CLI** - Multi-account AWS service interaction
- **kubectl** - Kubernetes cluster management
- **Git** - Source code management
- **jq** - JSON processing

### Multi-Account CI/CD Pipeline Example

```groovy
pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TERRAFORM_VERSION = '1.9.0'
    }
    
    stages {
        stage('Validate') {
            steps {
                sh 'terraform fmt -check'
                sh 'terraform validate'
            }
        }
        
        stage('Plan Development') {
            steps {
                script {
                    sh '''
                        aws sts assume-role \
                            --role-arn arn:aws:iam::456789012345:role/myapp-dev-cross-account-deployment \
                            --role-session-name jenkins-dev-deploy
                        terraform workspace select development
                        terraform plan -var-file=terraform-configs/accounts/development.tfvars
                    '''
                }
            }
        }
        
        stage('Deploy to Development') {
            steps {
                sh 'terraform apply -var-file=terraform-configs/accounts/development.tfvars -auto-approve'
            }
        }
        
        stage('Plan Production') {
            when { branch 'main' }
            steps {
                script {
                    sh '''
                        aws sts assume-role \
                            --role-arn arn:aws:iam::123456789012:role/myapp-prod-cross-account-deployment \
                            --role-session-name jenkins-prod-deploy
                        terraform workspace select production
                        terraform plan -var-file=terraform-configs/accounts/production.tfvars
                    '''
                }
            }
        }
        
        stage('Deploy to Production') {
            when { 
                allOf {
                    branch 'main'
                    input message: 'Deploy to Production?', ok: 'Deploy'
                }
            }
            steps {
                sh 'terraform apply -var-file=terraform-configs/accounts/production.tfvars -auto-approve'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            slackSend channel: '#deployments', 
                     color: 'good', 
                     message: "✅ Deployment successful: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        }
        failure {
            slackSend channel: '#deployments', 
                     color: 'danger', 
                     message: "❌ Deployment failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        }
    }
}
```

### Single-Account CI/CD Pipeline Example

```groovy
pipeline {
    agent any
    
    stages {
        stage('Deploy Infrastructure') {
            steps {
                sh '''
                    terraform workspace select single-account || terraform workspace new single-account
                    terraform plan -var-file=terraform-configs/accounts/single-account.tfvars
                    terraform apply -var-file=terraform-configs/accounts/single-account.tfvars -auto-approve
                '''
            }
        }
        
        stage('Deploy Application') {
            steps {
                sh '''
                    # Deploy to Production VPC
                    docker build -t myapp:${BUILD_NUMBER} .
                    docker tag myapp:${BUILD_NUMBER} myapp:latest
                    
                    # Deploy using ALB target group
                    aws elbv2 register-targets --target-group-arn $(terraform output -raw target_group_arn) \
                        --targets Id=$(terraform output -raw instance_id)
                '''
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

## 🛠️ Troubleshooting Guide

### Multi-Account Deployment Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **AWS Profile Configuration** | `NoCredentialsError` | Configure profiles: `aws configure --profile devops` |
| **Cross-Account Access** | `AccessDenied` when assuming roles | Verify IAM trust relationships and external IDs |
| **State Bucket Conflicts** | State locking errors | Use separate S3 buckets per account |
| **VPC CIDR Overlaps** | Peering connection failures | Ensure non-overlapping CIDR blocks |
| **Workspace Confusion** | Wrong resources in wrong account | Use `terraform workspace select <account>` |

### Single-Account Deployment Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **VPC Peering Failures** | No connectivity between VPCs | Check route tables and security groups |
| **CIDR Conflicts** | Cannot create subnets | Use non-overlapping CIDRs (10.0.0.0/16 vs 10.100.0.0/16) |
| **Resource Limits** | `LimitExceeded` errors | Request limit increases or use smaller instances |
| **Jenkins Access** | Cannot reach Jenkins UI | Check security group allows port 8080 from your IP |

### Common Infrastructure Issues

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Terraform Version** | State locking not working | Upgrade to Terraform >= 1.9.0 |
| **AMI Not Found** | `InvalidAMIID.NotFound` | AMI may not exist in target region |
| **Domain Validation** | ACM certificate pending | Manually validate in AWS Console or use Route53 |
| **Database Connection** | App cannot connect to RDS | Check security groups and subnet routing |
| **Auto Scaling Issues** | Instances not launching | Verify launch template and IAM instance profile |

### Debug Commands

```bash
# Check Terraform state
terraform state list
terraform state show <resource>

# Validate configuration
terraform validate
terraform fmt -check

# Check AWS connectivity
aws sts get-caller-identity
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=myapp"

# Workspace management
terraform workspace list
terraform workspace show

# Force refresh state
terraform refresh -var-file="terraform-configs/accounts/production.tfvars"

# Import existing resources
terraform import aws_vpc.main vpc-12345678
```

### Useful Commands

```bash
# Multi-account workspace management
terraform workspace list
terraform workspace select devops
terraform workspace new production

# Account-specific operations
terraform plan -var-file="terraform-configs/accounts/devops.tfvars"
terraform apply -var-file="terraform-configs/accounts/production.tfvars"

# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show current state
terraform show

# Destroy account-specific infrastructure
terraform destroy -var-file="terraform-configs/accounts/development.tfvars"
```

## 📚 Learning Path & Resources

### 🎯 Learning Progression

#### **Beginner Level (Week 1-2)**
- **Start Here**: `variables.tf`, `main.tf`, and basic module structure
- **Concepts**: Resources, variables, outputs, data sources
- **Practice**: Deploy single-account infrastructure
- **Resources**: [Terraform Getting Started](https://learn.hashicorp.com/terraform)

#### **Intermediate Level (Week 3-4)**
- **Focus**: Module development, conditional resources, and environment management
- **Concepts**: Module composition, count/for_each, dynamic blocks
- **Practice**: Customize modules, deploy to multiple regions
- **Study**: `modules/` directory structure and dependencies

#### **Advanced Level (Week 5-6)**
- **Focus**: Multi-account architecture, cross-account roles, state management
- **Concepts**: Workspace management, remote state, security best practices
- **Practice**: Deploy multi-account infrastructure with CI/CD
- **Study**: `terraform-configs/accounts/` configurations and `deploy-production.sh`

#### **Enterprise Level (Week 7+)**
- **Focus**: Production deployment patterns, monitoring, and governance
- **Concepts**: Compliance, disaster recovery, cost optimization
- **Practice**: Implement monitoring, backup strategies, and automated deployments
- **Study**: Jenkins pipelines, cross-account security, and operational procedures

### 📖 Key Learning Files

| File/Directory | Learning Focus | Difficulty |
|----------------|----------------|------------|
| `variables.tf` | Variable definitions and validation | Beginner |
| `main.tf` | Provider configuration and backend | Beginner |
| `modules/networking/` | VPC, subnets, routing concepts | Beginner |
| `modules/security/` | IAM roles, security groups | Intermediate |
| `modules/compute/` | Load balancers, auto scaling | Intermediate |
| `terraform-configs/accounts/` | Multi-account patterns | Advanced |
| `deploy-production.sh` | Automation and orchestration | Advanced |
| Jenkins pipelines | CI/CD integration | Enterprise |

### 🔗 External Resources

- **Terraform Documentation**: [terraform.io/docs](https://terraform.io/docs)
- **AWS Provider**: [registry.terraform.io/providers/hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws)
- **AWS Well-Architected**: [aws.amazon.com/architecture/well-architected](https://aws.amazon.com/architecture/well-architected)
- **Terraform Best Practices**: [terraform-best-practices.com](https://terraform-best-practices.com)

### 🎓 Hands-On Exercises

1. **Deploy and Destroy**: Practice the full lifecycle
2. **Modify Variables**: Change instance types, regions, CIDRs
3. **Add Resources**: Extend modules with additional AWS services
4. **Multi-Region**: Deploy the same infrastructure to different regions
5. **Custom Modules**: Create your own modules for specific use cases
6. **CI/CD Integration**: Set up automated deployments with Jenkins

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

### 🗑️ Cleanup Instructions

**Multi-Account Cleanup (Reverse Order):**
```bash
# 1. Destroy Development Account
export AWS_PROFILE=development
terraform workspace select development
terraform destroy -var-file="terraform-configs/accounts/development.tfvars"

# 2. Destroy Production Account
export AWS_PROFILE=production
terraform workspace select production
terraform destroy -var-file="terraform-configs/accounts/production.tfvars"

# 3. Destroy DevOps Account (Last)
export AWS_PROFILE=devops
terraform workspace select devops
terraform destroy -var-file="terraform-configs/accounts/devops.tfvars"
```

**Single-Account Cleanup:**
```bash
# Destroy all resources in single account
terraform destroy -var-file="terraform-configs/accounts/single-account.tfvars"

# Or use Makefile
make destroy-single-account
```

**Complete Cleanup:**
```bash
# Remove Terraform state files
rm -rf .terraform/
rm terraform.tfstate*
rm tfplan*

# Remove S3 state buckets (optional - be very careful!)
# aws s3 rb s3://your-terraform-state-bucket --force
```

### 💰 Cost Management

**Estimated Monthly Costs:**
- **Multi-Account**: $150-300/month (depending on usage)
- **Single-Account**: $100-200/month (cost-optimized)

**Cost Optimization Tips:**
- Use `t3.micro` instances for development
- Enable `enable_nat_gateway = false` for dev environments
- Set up CloudWatch billing alarms
- Use spot instances for non-critical workloads
- Regularly review and cleanup unused resources

**⚠️ Important Warnings:**
- **Destruction Order**: Always destroy development → DevOps → production to avoid dependency issues
- **State Management**: Never delete S3 state buckets while infrastructure exists
- **Cross-Account**: Verify cross-account roles before destroying DevOps account
- **Data Backup**: Backup RDS data before destroying database resources

### 🆘 Support & Community

- **Issues**: [GitHub Issues](https://github.com/elngovind/terraform-project/issues)
- **Discussions**: [GitHub Discussions](https://github.com/elngovind/terraform-project/discussions)
- **Terraform Community**: [discuss.hashicorp.com](https://discuss.hashicorp.com/c/terraform-core)
- **AWS Community**: [re:Post](https://repost.aws/)