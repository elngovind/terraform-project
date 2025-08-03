# Terraform AWS Infrastructure Project

This project creates a complete AWS infrastructure using Terraform with the following components:

## Architecture Overview

### 🏗️ Infrastructure Components

1. **Network Blueprint**
   - VPC with DNS support
   - 6 Subnets across 2 AZs:
     - 2 Public subnets (Web tier)
     - 2 Private subnets (App tier)
     - 2 Private subnets (Database tier)
   - Internet Gateway
   - NAT Gateway (configurable)
   - Route tables and associations

2. **Load Balancer**
   - Application Load Balancer (ALB)
   - Target groups with health checks
   - HTTP/HTTPS listeners (HTTPS if ACM enabled)

3. **ACM Certificate (Optional)**
   - SSL/TLS certificate for HTTPS
   - DNS validation support
   - Route53 integration (optional)

4. **Compute Resources**
   - Auto Scaling Group (ASG)
   - Launch Template with user data
   - CloudWatch alarms for scaling
   - EC2 instances with PowerUser IAM role

5. **Database**
   - RDS MySQL instance in private subnets
   - Encrypted storage
   - Automated backups
   - Secrets Manager integration
   - Enhanced monitoring

6. **Jenkins Server**
   - EC2 instance with Jenkins, Docker, Terraform
   - Elastic IP for consistent access
   - Pre-configured with CI/CD tools
   - CloudWatch logging

## 🚀 Quick Start

### Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform >= 1.9.0** installed
3. **S3 bucket** for state storage (update bucket name in `main.tf`)

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

### Step 3: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

### Step 4: Access Your Resources

After deployment, Terraform will output:
- **Application URL**: Load balancer endpoint
- **Jenkins URL**: Jenkins server access
- **Database endpoint**: RDS connection details
- **SSH commands**: For server access

## 🔧 Configuration Options

### Environment-Specific Deployments

```bash
# Development
terraform apply -var-file="environments/dev.tfvars"

# Production
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

# Manual deployment to any region
terraform apply -var-file="environments/regions/REGION.tfvars"
```

### Enable HTTPS with ACM

1. Set `enable_acm = true` in your `.tfvars` file
2. Provide your `domain_name`
3. Manually validate the certificate in AWS Console or set up Route53

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
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
├── terraform.tfvars.example
├── environments/
│   ├── dev.tfvars         # Development config
│   └── prod.tfvars        # Production config
└── modules/
    ├── networking/        # VPC, subnets, routing
    ├── security/          # Security groups, IAM
    ├── compute/           # ALB, ASG, Launch Template
    ├── database/          # RDS configuration
    ├── jenkins/           # Jenkins server setup
    └── acm/              # SSL certificate management
```

## 🔐 Security Best Practices

1. **IAM Roles**: Least privilege access
2. **Security Groups**: Restrictive ingress rules
3. **Encryption**: EBS and RDS encryption enabled
4. **Secrets Management**: Database credentials in Secrets Manager
5. **Private Subnets**: Database and app tiers isolated
6. **VPC Flow Logs**: Network monitoring (can be added)

## 🚀 Jenkins Pipeline Integration

The Jenkins server comes pre-configured with:
- **Terraform**: Infrastructure as Code
- **Docker**: Containerization
- **AWS CLI**: AWS service interaction
- **kubectl**: Kubernetes management

### Sample Pipeline

Check `/var/lib/jenkins/pipeline-examples/terraform-pipeline.groovy` on the Jenkins server for a complete Terraform pipeline example.

## 🔍 Monitoring & Logging

- **CloudWatch Alarms**: Auto-scaling triggers
- **RDS Monitoring**: Enhanced monitoring enabled
- **Jenkins Logs**: CloudWatch integration
- **Application Logs**: Can be extended with CloudWatch agent

## 🛠️ Troubleshooting

### Common Issues

1. **State Bucket**: Ensure S3 bucket exists and is accessible
2. **Permissions**: Verify AWS credentials have required permissions
3. **Terraform Version**: Ensure version >= 1.9.0 for S3 native locking
4. **Domain Validation**: Manually validate ACM certificate if Route53 not used

### Useful Commands

```bash
# Check Terraform version
terraform version

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show current state
terraform show

# Destroy infrastructure
terraform destroy
```

## 📚 Learning Resources

This project demonstrates Terraform concepts from basic to advanced:

1. **Beginners**: Start with `variables.tf` and `main.tf`
2. **Intermediate**: Explore module structure and relationships
3. **Advanced**: Study dynamic blocks, conditionals, and state management

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
terraform destroy
```