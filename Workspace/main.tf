terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = terraform.workspace
      ManagedBy   = "Terraform"
    }
  }
}

# S3 bucket with workspace-specific naming
resource "aws_s3_bucket" "workspace_bucket" {
  bucket = "${var.project_name}-${terraform.workspace}-bucket-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "workspace_bucket_versioning" {
  bucket = aws_s3_bucket.workspace_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# EC2 instance with workspace-specific configuration
resource "aws_instance" "workspace_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_types[terraform.workspace]
  
  tags = {
    Name = "${var.project_name}-${terraform.workspace}-instance"
  }
  
  user_data = templatefile("${path.module}/user_data.sh", {
    environment = terraform.workspace
  })
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security group with workspace-specific rules
resource "aws_security_group" "workspace_sg" {
  name_prefix = "${var.project_name}-${terraform.workspace}-"
  description = "Security group for ${terraform.workspace} environment"
  
  dynamic "ingress" {
    for_each = var.security_rules[terraform.workspace]
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}