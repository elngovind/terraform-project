# Infrastructure as Code (IAC) Pipeline Management

Complete Jenkins pipeline templates for managing Terraform infrastructure deployment, validation, and lifecycle management.

## 📁 Directory Structure

```
IAC-Pipeline/
├── README.md                    # This file
├── pipelines/                   # Jenkins pipeline templates
│   ├── terraform-deploy.groovy     # Main deployment pipeline
│   ├── terraform-validate.groovy   # Validation pipeline
│   ├── terraform-destroy.groovy    # Destruction pipeline
│   ├── multi-account.groovy        # Multi-account deployment
│   └── single-account.groovy       # Single-account deployment
├── scripts/                     # Helper scripts
│   ├── terraform-wrapper.sh        # Terraform execution wrapper
│   ├── aws-assume-role.sh          # AWS role assumption
│   └── notification.sh             # Slack/Teams notifications
├── templates/                   # Pipeline templates
│   ├── Jenkinsfile.template        # Base Jenkinsfile template
│   └── shared-library.groovy       # Shared pipeline functions
└── docs/                       # Documentation
    ├── JENKINS-SETUP.md            # Jenkins configuration guide
    ├── PIPELINE-STAGES.md           # Pipeline stages documentation
    └── TROUBLESHOOTING.md           # Common issues and solutions
```

## 🚀 Quick Start

1. **Deploy Jenkins Server** (if not already done):
   ```bash
   terraform apply -var-file="terraform-configs/accounts/single-account.tfvars"
   ```

2. **Access Jenkins**:
   ```bash
   # Get Jenkins URL
   terraform output jenkins_url
   
   # Get initial admin password
   terraform output jenkins_ssh_command
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. **Configure Jenkins**:
   - Install required plugins (see [JENKINS-SETUP.md](docs/JENKINS-SETUP.md))
   - Set up AWS credentials
   - Create pipeline jobs

4. **Deploy Pipeline**:
   - Copy pipeline templates to Jenkins
   - Configure environment variables
   - Run infrastructure deployment

## 🔧 Pipeline Features

- **Multi-Stage Deployment**: Plan → Validate → Apply → Test
- **Multi-Account Support**: Deploy across AWS accounts
- **Rollback Capability**: Automatic rollback on failures
- **Approval Gates**: Manual approval for production deployments
- **Notifications**: Slack/Teams integration
- **State Management**: Terraform state locking and backup
- **Security Scanning**: Infrastructure security validation

## 📋 Available Pipelines

| Pipeline | Purpose | Use Case |
|----------|---------|----------|
| `terraform-deploy.groovy` | Main deployment pipeline | Production deployments |
| `terraform-validate.groovy` | Validation only | PR validation |
| `terraform-destroy.groovy` | Infrastructure cleanup | Environment cleanup |
| `multi-account.groovy` | Multi-account deployment | Enterprise setup |
| `single-account.groovy` | Single-account deployment | Cost-optimized setup |

## 🎯 Pipeline Stages

### 1. **Preparation**
- Checkout code
- Validate environment
- Set up AWS credentials

### 2. **Validation**
- Terraform format check
- Terraform validate
- Security scanning
- Cost estimation

### 3. **Planning**
- Terraform plan
- Plan review
- Approval gate (production)

### 4. **Deployment**
- Terraform apply
- Resource validation
- Health checks

### 5. **Testing**
- Infrastructure testing
- Application deployment
- End-to-end testing

### 6. **Notification**
- Success/failure notifications
- Deployment summary
- Resource inventory

## 🔐 Security Features

- **AWS IAM Roles**: Secure cross-account access
- **State Encryption**: Encrypted Terraform state
- **Secrets Management**: AWS Secrets Manager integration
- **Audit Logging**: Complete deployment audit trail
- **Approval Workflows**: Manual approval for critical changes

## 📊 Monitoring & Reporting

- **Deployment Metrics**: Success/failure rates
- **Resource Tracking**: Infrastructure inventory
- **Cost Monitoring**: Deployment cost tracking
- **Compliance Reports**: Security and compliance validation

## 🛠️ Getting Started

See detailed setup instructions in:
- [Jenkins Setup Guide](docs/JENKINS-SETUP.md)
- [Pipeline Stages Documentation](docs/PIPELINE-STAGES.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)