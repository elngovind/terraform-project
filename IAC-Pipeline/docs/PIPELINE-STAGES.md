# Terraform Pipeline Stages Documentation

Comprehensive guide to all pipeline stages for Terraform infrastructure management.

## 🎯 Pipeline Overview

Our Terraform pipelines follow a structured approach with multiple stages for validation, deployment, and verification.

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Preparation │ -> │ Validation  │ -> │ Planning    │ -> │ Deployment  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       v                   v                   v                   v
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Cleanup     │ <- │ Reporting   │ <- │ Testing     │ <- │ Validation  │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## 📋 Stage Details

### 1. Preparation Stage

**Purpose**: Initialize the pipeline environment and prepare for deployment.

**Activities**:
- Clean workspace
- Checkout source code
- Set environment variables
- Validate parameters

**Example**:
```groovy
stage('Preparation') {
    steps {
        script {
            echo "🚀 Starting Terraform ${params.ACTION} for ${params.ENVIRONMENT}"
            cleanWs()
            checkout scm
            env.CONFIG_FILE = "terraform-configs/accounts/${params.ENVIRONMENT}.tfvars"
        }
    }
}
```

**Success Criteria**:
- ✅ Workspace cleaned
- ✅ Code checked out successfully
- ✅ Environment variables set
- ✅ Configuration file exists

### 2. AWS Authentication Stage

**Purpose**: Establish secure connection to AWS services.

**Activities**:
- Verify AWS credentials
- Assume cross-account roles (if needed)
- Validate account access
- Set up regional configuration

**Example**:
```groovy
stage('AWS Authentication') {
    steps {
        script {
            sh '''
                aws sts get-caller-identity
                echo "Current AWS Account: $(aws sts get-caller-identity --query Account --output text)"
                
                # For multi-account deployments
                if [ "${ENVIRONMENT}" = "production" ]; then
                    aws sts assume-role --role-arn arn:aws:iam::PROD-ACCOUNT:role/DeploymentRole --role-session-name jenkins-deploy
                fi
            '''
        }
    }
}
```

**Success Criteria**:
- ✅ AWS credentials validated
- ✅ Correct account identified
- ✅ Required permissions verified
- ✅ Cross-account roles assumed (if applicable)

### 3. Terraform Initialization Stage

**Purpose**: Initialize Terraform and prepare the working directory.

**Activities**:
- Run `terraform init`
- Configure backend
- Select/create workspace
- Download provider plugins

**Example**:
```groovy
stage('Terraform Init') {
    steps {
        script {
            sh '''
                terraform --version
                terraform init -upgrade
                terraform workspace select ${ENVIRONMENT} || terraform workspace new ${ENVIRONMENT}
                echo "Current workspace: $(terraform workspace show)"
            '''
        }
    }
}
```

**Success Criteria**:
- ✅ Terraform initialized successfully
- ✅ Backend configured
- ✅ Workspace selected/created
- ✅ Providers downloaded

### 4. Validation Stage

**Purpose**: Validate Terraform configuration and code quality.

**Activities**:
- Format checking (`terraform fmt`)
- Configuration validation (`terraform validate`)
- Syntax checking
- Variable validation

**Example**:
```groovy
stage('Terraform Validate') {
    steps {
        script {
            sh '''
                terraform fmt -check -recursive
                terraform validate
                terraform validate -var-file="${CONFIG_FILE}"
            '''
        }
    }
}
```

**Success Criteria**:
- ✅ Code properly formatted
- ✅ Configuration valid
- ✅ Variables validated
- ✅ No syntax errors

### 5. Security Scanning Stage

**Purpose**: Scan infrastructure code for security vulnerabilities.

**Activities**:
- Static security analysis
- Policy compliance checking
- Vulnerability scanning
- Best practices validation

**Tools**:
- **tfsec**: Terraform security scanner
- **checkov**: Infrastructure security scanner
- **terrascan**: Policy as code scanner

**Example**:
```groovy
stage('Security Scan') {
    steps {
        script {
            sh '''
                # Install and run tfsec
                curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
                tfsec . --format json --out tfsec-results.json
                
                # Install and run checkov
                pip3 install checkov
                checkov -d . --framework terraform --output json --output-file checkov-results.json
            '''
            
            // Archive security scan results
            archiveArtifacts artifacts: '*-results.json', fingerprint: true
        }
    }
}
```

**Success Criteria**:
- ✅ No critical security issues
- ✅ Policy compliance verified
- ✅ Scan results archived
- ✅ Acceptable risk level

### 6. Planning Stage

**Purpose**: Create and review Terraform execution plan.

**Activities**:
- Generate Terraform plan
- Analyze resource changes
- Cost estimation
- Plan review and approval

**Example**:
```groovy
stage('Terraform Plan') {
    steps {
        script {
            sh '''
                terraform plan -var-file="${CONFIG_FILE}" -out=tfplan -detailed-exitcode
                terraform show -no-color tfplan > plan-output.txt
            '''
            
            archiveArtifacts artifacts: 'tfplan,plan-output.txt', fingerprint: true
        }
    }
}
```

**Success Criteria**:
- ✅ Plan generated successfully
- ✅ Changes identified and documented
- ✅ Plan archived for review
- ✅ No planning errors

### 7. Cost Estimation Stage

**Purpose**: Estimate the cost impact of infrastructure changes.

**Activities**:
- Calculate resource costs
- Compare with current spending
- Generate cost reports
- Validate budget constraints

**Example**:
```groovy
stage('Cost Estimation') {
    steps {
        script {
            sh '''
                # Using AWS Pricing Calculator API or custom scripts
                echo "=== ESTIMATED MONTHLY COSTS ==="
                
                # Count resources and estimate costs
                INSTANCE_COUNT=$(terraform plan -var-file="${CONFIG_FILE}" | grep -c "aws_instance" || echo "0")
                RDS_COUNT=$(terraform plan -var-file="${CONFIG_FILE}" | grep -c "aws_db_instance" || echo "0")
                
                echo "EC2 Instances: $INSTANCE_COUNT (~$$(($INSTANCE_COUNT * 50))/month)"
                echo "RDS Instances: $RDS_COUNT (~$$(($RDS_COUNT * 25))/month)"
                echo "Estimated Total: ~$$(($INSTANCE_COUNT * 50 + $RDS_COUNT * 25))/month"
            '''
        }
    }
}
```

**Success Criteria**:
- ✅ Cost estimation completed
- ✅ Budget constraints validated
- ✅ Cost report generated
- ✅ Stakeholder approval (if required)

### 8. Approval Gate Stage

**Purpose**: Manual approval for critical deployments.

**Activities**:
- Display deployment summary
- Request manual approval
- Log approver information
- Validate approval permissions

**Example**:
```groovy
stage('Plan Review') {
    when {
        allOf {
            expression { params.ACTION == 'apply' }
            expression { params.ENVIRONMENT == 'production' }
        }
    }
    steps {
        script {
            sh 'terraform show -no-color tfplan'
            
            input message: 'Review the plan above. Proceed with deployment?', 
                  ok: 'Deploy',
                  submitterParameter: 'APPROVER'
            
            echo "✅ Deployment approved by: ${env.APPROVER}"
        }
    }
}
```

**Success Criteria**:
- ✅ Plan reviewed by authorized person
- ✅ Approval granted
- ✅ Approver logged
- ✅ Deployment authorized

### 9. Deployment Stage

**Purpose**: Apply Terraform configuration to create/update infrastructure.

**Activities**:
- Execute Terraform apply
- Monitor deployment progress
- Handle deployment errors
- Validate resource creation

**Example**:
```groovy
stage('Terraform Apply') {
    when {
        expression { params.ACTION == 'apply' }
    }
    steps {
        script {
            sh '''
                terraform apply tfplan
                terraform output -json > terraform-outputs.json
            '''
            
            archiveArtifacts artifacts: 'terraform-outputs.json', fingerprint: true
        }
    }
}
```

**Success Criteria**:
- ✅ Terraform apply successful
- ✅ All resources created/updated
- ✅ Outputs generated
- ✅ No deployment errors

### 10. Infrastructure Validation Stage

**Purpose**: Verify that deployed infrastructure is working correctly.

**Activities**:
- Test resource connectivity
- Validate service endpoints
- Check resource health
- Verify configurations

**Example**:
```groovy
stage('Infrastructure Validation') {
    steps {
        script {
            sh '''
                # Test VPC creation
                aws ec2 describe-vpcs --filters "Name=tag:Project,Values=myapp"
                
                # Test ALB endpoint
                if terraform output alb_dns_name >/dev/null 2>&1; then
                    ALB_URL=$(terraform output -raw alb_dns_name)
                    curl -I "http://$ALB_URL" || echo "ALB not yet ready"
                fi
                
                # Test Jenkins endpoint
                if terraform output jenkins_url >/dev/null 2>&1; then
                    JENKINS_URL=$(terraform output -raw jenkins_url)
                    curl -I "$JENKINS_URL" || echo "Jenkins not yet ready"
                fi
                
                # Test database connectivity
                if terraform output rds_endpoint >/dev/null 2>&1; then
                    RDS_ENDPOINT=$(terraform output -raw rds_endpoint)
                    echo "Database endpoint: $RDS_ENDPOINT"
                fi
            '''
        }
    }
}
```

**Success Criteria**:
- ✅ All resources accessible
- ✅ Services responding
- ✅ Health checks passing
- ✅ Connectivity verified

### 11. Testing Stage

**Purpose**: Run automated tests against the deployed infrastructure.

**Activities**:
- Infrastructure tests
- Application deployment tests
- End-to-end testing
- Performance validation

**Example**:
```groovy
stage('Infrastructure Testing') {
    steps {
        script {
            sh '''
                # Install testing tools
                pip3 install pytest boto3
                
                # Run infrastructure tests
                python3 -m pytest tests/infrastructure/ -v --junitxml=test-results.xml
                
                # Run connectivity tests
                python3 tests/connectivity_test.py
            '''
            
            publishTestResults testResultsPattern: 'test-results.xml'
        }
    }
}
```

**Success Criteria**:
- ✅ All tests passing
- ✅ Performance benchmarks met
- ✅ Test results published
- ✅ No critical failures

### 12. Reporting Stage

**Purpose**: Generate comprehensive deployment reports.

**Activities**:
- Create deployment summary
- Generate resource inventory
- Document configuration changes
- Archive deployment artifacts

**Example**:
```groovy
stage('Generate Report') {
    steps {
        script {
            sh '''
                cat > deployment-report.md << EOF
# Deployment Report

**Environment:** ${ENVIRONMENT}
**Action:** ${ACTION}
**Date:** $(date)
**Build:** ${BUILD_NUMBER}

## Resources Deployed
$(terraform state list)

## Outputs
$(terraform output)

## Status
Deployment completed successfully ✅
EOF
            '''
            
            archiveArtifacts artifacts: 'deployment-report.md', fingerprint: true
        }
    }
}
```

**Success Criteria**:
- ✅ Report generated
- ✅ All artifacts archived
- ✅ Documentation updated
- ✅ Stakeholders notified

### 13. Cleanup Stage

**Purpose**: Clean up temporary files and secure sensitive data.

**Activities**:
- Remove temporary files
- Clean up credentials
- Archive important artifacts
- Reset workspace

**Example**:
```groovy
post {
    always {
        script {
            sh '''
                rm -f tfplan
                rm -f terraform.tfstate*
                rm -f .terraform.lock.hcl
                rm -f *.json
            '''
        }
    }
    cleanup {
        cleanWs()
    }
}
```

**Success Criteria**:
- ✅ Sensitive files removed
- ✅ Workspace cleaned
- ✅ Artifacts preserved
- ✅ Security maintained

## 🔄 Stage Flow Control

### Conditional Stages

Use `when` conditions to control stage execution:

```groovy
stage('Production Approval') {
    when {
        allOf {
            expression { params.ENVIRONMENT == 'production' }
            expression { params.ACTION == 'apply' }
        }
    }
    steps {
        // Production-specific approval logic
    }
}
```

### Parallel Stages

Run independent stages in parallel:

```groovy
stage('Parallel Validation') {
    parallel {
        stage('Security Scan') {
            steps {
                sh 'tfsec .'
            }
        }
        stage('Cost Analysis') {
            steps {
                sh 'terraform-cost-estimation'
            }
        }
    }
}
```

### Error Handling

Implement proper error handling:

```groovy
stage('Terraform Apply') {
    steps {
        script {
            try {
                sh 'terraform apply tfplan'
            } catch (Exception e) {
                echo "Deployment failed: ${e.getMessage()}"
                sh 'terraform show tfplan'  // Show what was attempted
                throw e  // Re-throw to fail the build
            }
        }
    }
}
```

## 📊 Stage Metrics

Track stage performance and success rates:

```groovy
post {
    always {
        script {
            // Record stage metrics
            def stageMetrics = [
                environment: params.ENVIRONMENT,
                action: params.ACTION,
                duration: currentBuild.duration,
                result: currentBuild.result
            ]
            
            writeJSON file: 'stage-metrics.json', json: stageMetrics
            archiveArtifacts artifacts: 'stage-metrics.json'
        }
    }
}
```

## 🔧 Customization

### Environment-Specific Stages

Customize stages based on environment:

```groovy
script {
    def stages = [
        'development': ['validate', 'plan', 'apply'],
        'production': ['validate', 'security-scan', 'plan', 'approval', 'apply', 'test']
    ]
    
    def currentStages = stages[params.ENVIRONMENT]
    // Execute only relevant stages
}
```

### Dynamic Stage Generation

Generate stages dynamically:

```groovy
script {
    def environments = ['dev', 'staging', 'prod']
    
    environments.each { env ->
        stage("Deploy to ${env}") {
            steps {
                sh "terraform apply -var-file=terraform-configs/accounts/${env}.tfvars"
            }
        }
    }
}
```

## 📚 Best Practices

1. **Always validate before applying**
2. **Use approval gates for production**
3. **Archive important artifacts**
4. **Implement proper error handling**
5. **Clean up sensitive data**
6. **Monitor stage performance**
7. **Use parallel execution where possible**
8. **Implement comprehensive testing**

## 🔗 Related Documentation

- [Jenkins Setup Guide](JENKINS-SETUP.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Pipeline Templates](../pipelines/)