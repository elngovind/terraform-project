#!/bin/bash

# Update system
yum update -y

# Install Java 11 (required for Jenkins)
yum install -y java-11-amazon-corretto-headless

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins

# Install Git
yum install -y git

# Install Docker
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -a -G docker jenkins

# Install Terraform
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install -y terraform

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
yum install -y unzip
unzip awscliv2.zip
./aws/install

# Install kubectl (region-agnostic)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/jenkins/jenkins.log",
                        "log_group_name": "/aws/ec2/${project_name}-${environment}-jenkins",
                        "log_stream_name": "jenkins.log"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Wait for Jenkins to start and get initial admin password
sleep 60

# Create a simple script to display Jenkins info
cat <<EOF > /home/ec2-user/jenkins-info.sh
#!/bin/bash
echo "==================================="
echo "Jenkins Server Information"
echo "==================================="
echo "Jenkins URL: http://\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "==================================="
echo "Installed Tools:"
echo "- Java: \$(java -version 2>&1 | head -n 1)"
echo "- Jenkins: \$(jenkins --version 2>/dev/null || echo \"Jenkins installed\")"
echo "- Docker: \$(docker --version)"
echo "- Terraform: \$(terraform version | head -n 1)"
echo "- AWS CLI: \$(aws --version)"
echo "- kubectl: \$(kubectl version --client --short 2>/dev/null || echo \"kubectl installed\")"
echo "==================================="
EOF

chmod +x /home/ec2-user/jenkins-info.sh
chown ec2-user:ec2-user /home/ec2-user/jenkins-info.sh

# Run the info script
/home/ec2-user/jenkins-info.sh > /home/ec2-user/jenkins-setup-info.txt

# Create Jenkins pipeline examples directory
mkdir -p /var/lib/jenkins/pipeline-examples
chown jenkins:jenkins /var/lib/jenkins/pipeline-examples

# Create a sample Terraform pipeline
cat <<'EOF' > /var/lib/jenkins/pipeline-examples/terraform-pipeline.groovy
pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_VAR_environment = "\${env.BRANCH_NAME == \"main\" ? \"prod\" : \"dev\"}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }
        
        stage('Terraform Apply') {
            when {
                branch \"main\"
            }
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
EOF

chown jenkins:jenkins /var/lib/jenkins/pipeline-examples/terraform-pipeline.groovy

echo "Jenkins installation completed!" >> /var/log/jenkins-install.log