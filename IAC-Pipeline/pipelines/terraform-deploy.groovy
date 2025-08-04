pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['development', 'production', 'single-account'],
            description: 'Target environment for deployment'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to perform'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto-approve terraform apply (use with caution)'
        )
    }
    
    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_VAR_environment = "${params.ENVIRONMENT}"
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
    }
    
    stages {
        stage('Preparation') {
            steps {
                script {
                    echo "🚀 Starting Terraform ${params.ACTION} for ${params.ENVIRONMENT}"
                    
                    // Clean workspace
                    cleanWs()
                    
                    // Checkout code
                    checkout scm
                    
                    // Set up environment variables
                    env.CONFIG_FILE = "terraform-configs/accounts/${params.ENVIRONMENT}.tfvars"
                    env.STATE_KEY = "${params.ENVIRONMENT}/terraform.tfstate"
                }
            }
        }
        
        stage('AWS Authentication') {
            steps {
                script {
                    echo "🔐 Setting up AWS authentication for ${params.ENVIRONMENT}"
                    
                    // Verify AWS credentials
                    sh '''
                        aws sts get-caller-identity
                        echo "Current AWS Account: $(aws sts get-caller-identity --query Account --output text)"
                    '''
                }
            }
        }
        
        stage('Terraform Init') {
            steps {
                script {
                    echo "⚙️ Initializing Terraform"
                    
                    sh '''
                        terraform --version
                        terraform init -upgrade
                        terraform workspace list
                        terraform workspace select ${ENVIRONMENT} || terraform workspace new ${ENVIRONMENT}
                    '''
                }
            }
        }
        
        stage('Terraform Validate') {
            steps {
                script {
                    echo "✅ Validating Terraform configuration"
                    
                    sh '''
                        terraform fmt -check -recursive
                        terraform validate
                    '''
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    echo "🔍 Running security scan"
                    
                    // Add security scanning tools like tfsec, checkov
                    sh '''
                        echo "Security scan placeholder - integrate tfsec/checkov here"
                        # tfsec .
                        # checkov -d .
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    echo "📋 Creating Terraform plan"
                    
                    sh '''
                        terraform plan -var-file="${CONFIG_FILE}" -out=tfplan -detailed-exitcode
                    '''
                    
                    // Archive the plan
                    archiveArtifacts artifacts: 'tfplan', fingerprint: true
                }
            }
        }
        
        stage('Plan Review') {
            when {
                allOf {
                    expression { params.ACTION == 'apply' }
                    expression { params.ENVIRONMENT == 'production' }
                    expression { !params.AUTO_APPROVE }
                }
            }
            steps {
                script {
                    echo "👀 Plan review required for production deployment"
                    
                    // Show plan summary
                    sh 'terraform show -no-color tfplan'
                    
                    // Manual approval for production
                    input message: 'Review the plan above. Proceed with deployment?', 
                          ok: 'Deploy',
                          submitterParameter: 'APPROVER'
                    
                    echo "✅ Deployment approved by: ${env.APPROVER}"
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "🚀 Applying Terraform configuration"
                    
                    sh '''
                        terraform apply tfplan
                    '''
                }
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    echo "💥 Destroying Terraform infrastructure"
                    
                    // Additional confirmation for destroy
                    input message: 'Are you sure you want to DESTROY all infrastructure?', 
                          ok: 'DESTROY',
                          submitterParameter: 'DESTROYER'
                    
                    sh '''
                        terraform destroy -var-file="${CONFIG_FILE}" -auto-approve
                    '''
                }
            }
        }
        
        stage('Infrastructure Validation') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "🔍 Validating deployed infrastructure"
                    
                    sh '''
                        # Get outputs
                        terraform output -json > terraform-outputs.json
                        
                        # Validate key resources exist
                        if [ "${ENVIRONMENT}" != "single-account" ]; then
                            aws ec2 describe-vpcs --filters "Name=tag:Project,Values=myapp" --query 'Vpcs[0].VpcId' --output text
                        fi
                        
                        # Test application endpoints if available
                        if terraform output alb_dns_name >/dev/null 2>&1; then
                            ALB_URL=$(terraform output -raw alb_dns_name)
                            echo "Testing ALB endpoint: $ALB_URL"
                            curl -I "http://$ALB_URL" || echo "ALB not yet ready"
                        fi
                        
                        # Test Jenkins if deployed
                        if terraform output jenkins_url >/dev/null 2>&1; then
                            JENKINS_URL=$(terraform output -raw jenkins_url)
                            echo "Testing Jenkins endpoint: $JENKINS_URL"
                            curl -I "$JENKINS_URL" || echo "Jenkins not yet ready"
                        fi
                    '''
                    
                    // Archive outputs
                    archiveArtifacts artifacts: 'terraform-outputs.json', fingerprint: true
                }
            }
        }
        
        stage('Generate Report') {
            steps {
                script {
                    echo "📊 Generating deployment report"
                    
                    sh '''
                        cat > deployment-report.md << EOF
# Deployment Report

**Environment:** ${ENVIRONMENT}
**Action:** ${ACTION}
**Date:** $(date)
**Build:** ${BUILD_NUMBER}
**Git Commit:** ${GIT_COMMIT}

## Resources Deployed
$(terraform state list 2>/dev/null || echo "No state available")

## Outputs
$(terraform output 2>/dev/null || echo "No outputs available")

## Status
Deployment completed successfully ✅
EOF
                    '''
                    
                    archiveArtifacts artifacts: 'deployment-report.md', fingerprint: true
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "🧹 Cleaning up workspace"
                
                // Clean up sensitive files
                sh '''
                    rm -f tfplan
                    rm -f terraform.tfstate*
                    rm -f .terraform.lock.hcl
                '''
            }
        }
        
        success {
            script {
                echo "✅ Pipeline completed successfully"
                
                // Send success notification
                sh '''
                    echo "Deployment successful for ${ENVIRONMENT} environment"
                    # Add Slack/Teams notification here
                '''
            }
        }
        
        failure {
            script {
                echo "❌ Pipeline failed"
                
                // Send failure notification
                sh '''
                    echo "Deployment failed for ${ENVIRONMENT} environment"
                    # Add Slack/Teams notification here
                '''
            }
        }
        
        cleanup {
            cleanWs()
        }
    }
}