# Get latest Amazon Linux 2 AMI (works in all regions)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.jenkins_instance_type
  subnet_id              = var.web_subnet_ids[0]  # Deploy in first public subnet
  vpc_security_group_ids = [var.jenkins_security_group_id]
  iam_instance_profile   = var.ec2_instance_profile_name

  user_data = base64encode(templatefile("${path.module}/jenkins_user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins"
    Type = "Jenkins"
  }
}

# Elastic IP for Jenkins (optional but recommended)
resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-eip"
  }
}

# CloudWatch Log Group for Jenkins
resource "aws_cloudwatch_log_group" "jenkins" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}-jenkins"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-logs"
  }
}