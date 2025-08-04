pipeline {
    agent any
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to perform'
        )
        booleanParam(
            name: 'DEPLOY_JENKINS',
            defaultValue: true,
            description: 'Deploy Jenkins server'
        )
        booleanParam(
            name: 'ENABLE_VPC_PEERING',
            defaultValue: true,
            description: 'Enable VPC peering between Production and DevOps VPCs'
        )
    }
    
    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_VAR_environment = 'single-account'
        TF_VAR_deploy_jenkins = "${params.DEPLOY_JENKINS}"
        TF_VAR_enable_vpc_peering = "${params.ENABLE_VPC_PEERING}"
        CONFIG_FILE = 'terraform-configs/accounts/single-account.tfvars'
    }
    
    stages {
        stage('Preparation') {
            steps {
                script {
                    echo "🏗️ Single-Account Infrastructure Pipeline"
                    echo "Action: ${params.ACTION}"
                    echo "Deploy Jenkins: ${params.DEPLOY_JENKINS}"
                    echo "VPC Peering: ${params.ENABLE_VPC_PEERING}"
                }
                
                cleanWs()
                checkout scm
            }
        }
        
        stage('Environment Validation') {
            steps {
                script {
                    echo "🔍 Validating single-account environment"
                    
                    sh '''
                        # Verify AWS account
                        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                        echo "Deploying to AWS Account: $ACCOUNT_ID"
                        
                        # Check if config file exists
                        if [ ! -f "${CONFIG_FILE}" ]; then
                            echo "❌ Configuration file not found: ${CONFIG_FILE}"
                            exit 1
                        fi
                        
                        # Validate configuration
                        grep -q "single-account" "${CONFIG_FILE}" || {
                            echo "❌ Invalid configuration file"
                            exit 1
                        }
                        
                        echo "✅ Environment validation passed"
                    '''
                }
            }
        }
        
        stage('Terraform Init & Workspace') {
            steps {
                script {
                    echo "⚙️ Initializing Terraform for single-account deployment"
                    
                    sh '''
                        terraform init -upgrade
                        
                        # Select or create single-account workspace
                        terraform workspace select single-account || terraform workspace new single-account
                        
                        echo "Current workspace: $(terraform workspace show)"
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
                        
                        # Validate variable file
                        terraform validate -var-file="${CONFIG_FILE}"
                    '''
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                script {
                    echo "📋 Creating Terraform plan for single-account deployment"
                    
                    sh '''
                        terraform plan -var-file="${CONFIG_FILE}" -out=tfplan -detailed-exitcode
                        
                        # Show plan summary
                        echo "=== PLAN SUMMARY ==="
                        terraform show -no-color tfplan | grep -E "(Plan:|No changes)"
                    '''
                    
                    archiveArtifacts artifacts: 'tfplan', fingerprint: true
                }
            }
        }
        
        stage('Cost Estimation') {
            steps {
                script {
                    echo "💰 Estimating deployment costs"
                    
                    sh '''
                        echo "=== ESTIMATED MONTHLY COSTS ==="
                        echo "Production VPC: ~$50-100/month"
                        echo "DevOps VPC: ~$30-50/month"
                        echo "Jenkins Server (t3.large): ~$60/month"
                        echo "RDS (db.t3.small): ~$25/month"
                        echo "NAT Gateway: ~$45/month"
                        echo "Total Estimated: ~$210-280/month"
                        echo ""
                        echo "Note: Actual costs may vary based on usage"
                    '''
                }
            }
        }
        
        stage('Approval Gate') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "👀 Manual approval required for infrastructure deployment"
                    
                    // Show deployment summary
                    sh '''
                        echo "=== DEPLOYMENT SUMMARY ==="
                        echo "Environment: Single-Account"
                        echo "Region: ${AWS_DEFAULT_REGION}"
                        echo "Deploy Jenkins: ${DEPLOY_JENKINS}"
                        echo "VPC Peering: ${ENABLE_VPC_PEERING}"
                        echo ""
                        echo "Resources to be created:"
                        echo "- Production VPC (10.0.0.0/16)"
                        echo "- DevOps VPC (10.100.0.0/16)"
                        echo "- Application Load Balancer"
                        echo "- Auto Scaling Group"
                        echo "- RDS MySQL Database"
                        if [ "${DEPLOY_JENKINS}" = "true" ]; then
                            echo "- Jenkins Server"
                        fi
                        if [ "${ENABLE_VPC_PEERING}" = "true" ]; then
                            echo "- VPC Peering Connection"
                        fi
                    '''
                    
                    input message: 'Review the deployment plan. Proceed with infrastructure creation?', 
                          ok: 'Deploy Infrastructure',
                          submitterParameter: 'APPROVER'
                    
                    echo "✅ Deployment approved by: ${env.APPROVER}"
                }
            }
        }
        
        stage('Deploy Infrastructure') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "🚀 Deploying single-account infrastructure"
                    
                    sh '''
                        terraform apply tfplan
                        
                        echo "✅ Infrastructure deployment completed"
                    '''
                }
            }
        }
        
        stage('Destroy Infrastructure') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                script {
                    echo "💥 Destroying single-account infrastructure"
                    
                    input message: 'Are you sure you want to DESTROY all single-account infrastructure?', 
                          ok: 'DESTROY ALL',
                          submitterParameter: 'DESTROYER'
                    
                    sh '''
                        terraform destroy -var-file="${CONFIG_FILE}" -auto-approve
                        
                        echo "💥 Infrastructure destruction completed"
                    '''
                }
            }
        }
        
        stage('Post-Deployment Validation') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "🔍 Validating deployed infrastructure"
                    
                    sh '''
                        # Get and display outputs
                        terraform output -json > outputs.json
                        
                        echo "=== DEPLOYMENT OUTPUTS ==="
                        terraform output
                        
                        # Validate VPCs
                        echo "=== VPC VALIDATION ==="
                        aws ec2 describe-vpcs --filters "Name=tag:Project,Values=myapp" --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table
                        
                        # Test Jenkins if deployed
                        if [ "${DEPLOY_JENKINS}" = "true" ]; then
                            echo "=== JENKINS VALIDATION ==="
                            JENKINS_URL=$(terraform output -raw jenkins_url 2>/dev/null || echo "Not available")
                            echo "Jenkins URL: $JENKINS_URL"
                            
                            if [ "$JENKINS_URL" != "Not available" ]; then
                                echo "Testing Jenkins connectivity..."
                                timeout 30 bash -c 'until curl -s -o /dev/null -w "%{http_code}" '"$JENKINS_URL"' | grep -q "200\\|403"; do sleep 5; done' || echo "Jenkins not yet accessible"
                            fi
                        fi
                        
                        # Test ALB
                        echo "=== APPLICATION LOAD BALANCER VALIDATION ==="
                        ALB_DNS=$(terraform output -raw alb_dns_name 2>/dev/null || echo "Not available")
                        echo "ALB DNS: $ALB_DNS"
                        
                        if [ "$ALB_DNS" != "Not available" ]; then
                            echo "Testing ALB connectivity..."
                            timeout 30 bash -c 'until curl -s -o /dev/null -w "%{http_code}" http://'"$ALB_DNS"' | grep -q "200\\|503"; do sleep 5; done' || echo "ALB not yet accessible"
                        fi
                        
                        # Validate VPC Peering if enabled
                        if [ "${ENABLE_VPC_PEERING}" = "true" ]; then
                            echo "=== VPC PEERING VALIDATION ==="
                            aws ec2 describe-vpc-peering-connections --filters "Name=tag:Project,Values=myapp" --query 'VpcPeeringConnections[*].[VpcPeeringConnectionId,Status.Code]' --output table
                        fi
                    '''
                    
                    archiveArtifacts artifacts: 'outputs.json', fingerprint: true
                }
            }
        }
        
        stage('Generate Access Guide') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "📋 Generating access guide"
                    
                    sh '''
                        cat > access-guide.md << EOF
# Single-Account Infrastructure Access Guide

## 🎯 Deployment Summary
- **Environment**: Single-Account
- **Region**: ${AWS_DEFAULT_REGION}
- **Date**: $(date)
- **Build**: ${BUILD_NUMBER}

## 🔗 Access URLs
$(terraform output 2>/dev/null | grep -E "(jenkins_url|alb_dns_name)" || echo "URLs will be available once deployment completes")

## 🔑 SSH Access
$(terraform output jenkins_ssh_command 2>/dev/null || echo "SSH command will be available once Jenkins is deployed")

## 📊 Infrastructure Overview
- **Production VPC**: 10.0.0.0/16
- **DevOps VPC**: 10.100.0.0/16
- **Jenkins Deployed**: ${DEPLOY_JENKINS}
- **VPC Peering**: ${ENABLE_VPC_PEERING}

## 🛠️ Next Steps
1. Access Jenkins and complete initial setup
2. Configure AWS credentials in Jenkins
3. Set up deployment pipelines
4. Deploy applications to the infrastructure

## 📞 Support
- Check deployment logs in Jenkins
- Review Terraform outputs for resource details
- Consult troubleshooting guide for common issues
EOF
                    '''
                    
                    archiveArtifacts artifacts: 'access-guide.md', fingerprint: true
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Clean up sensitive files
                sh '''
                    rm -f tfplan
                    rm -f terraform.tfstate*
                '''
            }
        }
        
        success {
            script {
                echo "✅ Single-account pipeline completed successfully"
                
                if (params.ACTION == 'apply') {
                    echo """
🎉 Single-Account Infrastructure Deployed Successfully!

📋 Summary:
- Environment: Single-Account
- Region: ${env.AWS_DEFAULT_REGION}
- Jenkins: ${params.DEPLOY_JENKINS ? 'Deployed' : 'Skipped'}
- VPC Peering: ${params.ENABLE_VPC_PEERING ? 'Enabled' : 'Disabled'}

🔗 Access your infrastructure:
- Check the 'access-guide.md' artifact for detailed access information
- Use 'terraform output' to get resource details
                    """
                }
            }
        }
        
        failure {
            script {
                echo "❌ Single-account pipeline failed"
                echo "Check the logs above for error details"
            }
        }
        
        cleanup {
            cleanWs()
        }
    }
}