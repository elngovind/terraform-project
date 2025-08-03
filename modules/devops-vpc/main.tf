# DevOps VPC for Single-Account Deployment

# DevOps VPC
resource "aws_vpc" "devops" {
  cidr_block           = var.devops_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.environment}-devops-vpc"
    Type = "DevOps"
  }
}

# Internet Gateway for DevOps VPC
resource "aws_internet_gateway" "devops" {
  vpc_id = aws_vpc.devops.id

  tags = {
    Name = "${var.project_name}-${var.environment}-devops-igw"
  }
}

# DevOps Public Subnets
resource "aws_subnet" "devops_web" {
  count = length(var.devops_web_subnet_cidrs)

  vpc_id                  = aws_vpc.devops.id
  cidr_block              = var.devops_web_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-devops-web-subnet-${count.index + 1}"
    Type = "Public"
    Tier = "DevOps-Web"
  }
}

# DevOps Private Subnets (App)
resource "aws_subnet" "devops_app" {
  count = length(var.devops_app_subnet_cidrs)

  vpc_id            = aws_vpc.devops.id
  cidr_block        = var.devops_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = {
    Name = "${var.project_name}-${var.environment}-devops-app-subnet-${count.index + 1}"
    Type = "Private"
    Tier = "DevOps-App"
  }
}

# Route Tables for DevOps VPC
resource "aws_route_table" "devops_public" {
  vpc_id = aws_vpc.devops.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-devops-public-rt"
  }
}

resource "aws_route_table" "devops_private" {
  vpc_id = aws_vpc.devops.id

  tags = {
    Name = "${var.project_name}-${var.environment}-devops-private-rt"
  }
}

# Route Table Associations
resource "aws_route_table_association" "devops_web" {
  count = length(aws_subnet.devops_web)
  subnet_id      = aws_subnet.devops_web[count.index].id
  route_table_id = aws_route_table.devops_public.id
}

resource "aws_route_table_association" "devops_app" {
  count = length(aws_subnet.devops_app)
  subnet_id      = aws_subnet.devops_app[count.index].id
  route_table_id = aws_route_table.devops_private.id
}

data "aws_availability_zones" "available" {
  state = "available"
}