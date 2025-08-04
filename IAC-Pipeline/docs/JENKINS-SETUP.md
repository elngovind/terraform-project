# Jenkins Setup Guide for Terraform IAC Pipeline

Complete guide to configure Jenkins for managing Terraform infrastructure deployments.

## 🚀 Initial Jenkins Setup

### Step 1: Access Jenkins

After deploying infrastructure:

```bash
# Get Jenkins URL
terraform output jenkins_url

# Get SSH access to Jenkins server
terraform output jenkins_ssh_command

# Get initial admin password
ssh -i your-key.pem ec2-user@JENKINS_IP "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

### Step 2: Complete Jenkins Installation

1. **Access Jenkins Web Interface**:
   - Open the Jenkins URL in your browser
   - Enter the initial admin password

2. **Install Suggested Plugins**:
   - Choose "Install suggested plugins"
   - Wait for plugin installation to complete

3. **Create Admin User**:
   - Create your admin user account
   - Configure Jenkins URL

## 🔧 Required Plugin Installation

Install these additional plugins for Terraform pipeline:

### Essential Plugins

```bash
# Via Jenkins CLI or Web Interface
- Pipeline
- Pipeline: Stage View
- Blue Ocean (optional, for better UI)
- AWS Pipeline
- Terraform Plugin
- AnsiColor (for colored output)
- Timestamper
- Workspace Cleanup
- Build Timeout
```

### Installation via Jenkins CLI

```bash
# SSH to Jenkins server
ssh -i your-key.pem ec2-user@JENKINS_IP

# Install plugins via CLI
sudo java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ install-plugin \
  pipeline-stage-view \
  blueocean \
  aws-pipeline \
  terraform \
  ansicolor \
  timestamper \
  ws-cleanup \
  build-timeout
```

## 🔐 AWS Credentials Configuration

### Method 1: IAM Instance Profile (Recommended)

The Jenkins server is already configured with an IAM instance profile with PowerUser access.

Verify access:
```bash
# SSH to Jenkins server
aws sts get-caller-identity
aws s3 ls  # Should list S3 buckets
```

### Method 2: AWS Credentials Plugin

1. **Install AWS Credentials Plugin**
2. **Go to**: Manage Jenkins → Manage Credentials
3. **Add Credentials**:
   - Kind: AWS Credentials
   - ID: `aws-credentials`
   - Access Key ID: Your access key
   - Secret Access Key: Your secret key

### Method 3: Cross-Account Roles (Multi-Account Setup)

For multi-account deployments, configure cross-account roles:

```bash
# Example assume role configuration
aws sts assume-role \
  --role-arn arn:aws:iam::ACCOUNT-ID:role/CrossAccountDeploymentRole \
  --role-session-name jenkins-deployment
```

## 📋 Pipeline Job Configuration

### Step 1: Create Pipeline Job

1. **New Item** → **Pipeline** → Enter name: `terraform-infrastructure`
2. **Configure Pipeline**:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your repository URL
   - Script Path: `IAC-Pipeline/pipelines/terraform-deploy.groovy`

### Step 2: Configure Build Parameters

Add these parameters to your pipeline job:

```groovy
parameters {
    choice(
        name: 'ENVIRONMENT',
        choices: ['development', 'production', 'single-account'],
        description: 'Target environment'
    )
    choice(
        name: 'ACTION',
        choices: ['plan', 'apply', 'destroy'],
        description: 'Terraform action'
    )
    booleanParam(
        name: 'AUTO_APPROVE',
        defaultValue: false,
        description: 'Auto-approve apply'
    )
}
```

### Step 3: Configure Environment Variables

Set global environment variables:

1. **Manage Jenkins** → **Configure System**
2. **Global Properties** → **Environment Variables**:

```bash
AWS_DEFAULT_REGION=ap-south-1
TF_IN_AUTOMATION=true
TF_INPUT=false
TERRAFORM_VERSION=1.9.0
```

## 🛠️ Pipeline Templates Setup

### Copy Pipeline Files

```bash
# SSH to Jenkins server
ssh -i your-key.pem ec2-user@JENKINS_IP

# Create pipeline directory
sudo mkdir -p /var/lib/jenkins/pipelines
sudo chown jenkins:jenkins /var/lib/jenkins/pipelines

# Copy pipeline files (from your local machine)
scp -i your-key.pem IAC-Pipeline/pipelines/* ec2-user@JENKINS_IP:/tmp/
ssh -i your-key.pem ec2-user@JENKINS_IP "sudo mv /tmp/*.groovy /var/lib/jenkins/pipelines/"
```

### Create Multiple Pipeline Jobs

Create separate jobs for different purposes:

1. **terraform-deploy** - Main deployment pipeline
2. **terraform-validate** - Validation only
3. **terraform-destroy** - Infrastructure cleanup
4. **single-account-deploy** - Single-account specific
5. **multi-account-deploy** - Multi-account specific

## 🔔 Notification Setup

### Slack Integration

1. **Install Slack Notification Plugin**
2. **Configure Slack**:
   - Workspace: Your Slack workspace
   - Channel: `#deployments`
   - Token: Slack bot token

3. **Add to Pipeline**:
```groovy
post {
    success {
        slackSend(
            channel: '#deployments',
            color: 'good',
            message: "✅ Deployment successful: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        )
    }
    failure {
        slackSend(
            channel: '#deployments',
            color: 'danger',
            message: "❌ Deployment failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}"
        )
    }
}
```

### Email Notifications

Configure SMTP in Jenkins:
1. **Manage Jenkins** → **Configure System**
2. **E-mail Notification**:
   - SMTP Server: Your SMTP server
   - Default Recipients: Your email

## 🔒 Security Configuration

### Enable Security

1. **Manage Jenkins** → **Configure Global Security**
2. **Security Realm**: Jenkins' own user database
3. **Authorization**: Matrix-based security
4. **Configure Permissions**:
   - Admin: Full access
   - Developer: Build, Read
   - Viewer: Read only

### Secure Terraform State

Ensure Terraform state is secure:

```bash
# Verify S3 bucket encryption
aws s3api get-bucket-encryption --bucket your-terraform-state-bucket

# Check bucket policy
aws s3api get-bucket-policy --bucket your-terraform-state-bucket
```

## 📊 Monitoring & Logging

### Enable Build Logs

1. **Configure System Log**:
   - Manage Jenkins → System Log
   - Add logger for `hudson.model.Build`

2. **Archive Artifacts**:
```groovy
post {
    always {
        archiveArtifacts artifacts: 'tfplan,terraform-outputs.json,deployment-report.md'
    }
}
```

### CloudWatch Integration

Monitor Jenkins logs in CloudWatch:

```bash
# Verify CloudWatch agent is running
sudo systemctl status amazon-cloudwatch-agent

# Check log groups
aws logs describe-log-groups --log-group-name-prefix "/aws/ec2"
```

## 🧪 Testing Pipeline Setup

### Test Basic Functionality

1. **Run Validation Pipeline**:
   - Job: terraform-validate
   - Parameters: environment=single-account

2. **Test AWS Access**:
```bash
# In Jenkins pipeline
sh 'aws sts get-caller-identity'
sh 'terraform version'
```

3. **Test Terraform Plan**:
   - Job: terraform-deploy
   - Parameters: environment=single-account, action=plan

## 🔧 Troubleshooting

### Common Issues

1. **Permission Denied**:
   ```bash
   # Fix Jenkins user permissions
   sudo usermod -a -G docker jenkins
   sudo systemctl restart jenkins
   ```

2. **Terraform Not Found**:
   ```bash
   # Add Terraform to PATH
   echo 'export PATH=$PATH:/usr/local/bin' | sudo tee -a /etc/profile
   ```

3. **AWS Credentials**:
   ```bash
   # Verify IAM instance profile
   curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
   ```

### Debug Commands

```bash
# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check system resources
df -h
free -m
top
```

## 📚 Next Steps

1. **Configure Pipeline Jobs** using the templates
2. **Set up Notifications** for deployment status
3. **Create Backup Strategy** for Jenkins configuration
4. **Implement Security Scanning** in pipelines
5. **Set up Monitoring** for infrastructure health

## 🔗 Related Documentation

- [Pipeline Stages Documentation](PIPELINE-STAGES.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Multi-Account Setup Guide](../README.md)