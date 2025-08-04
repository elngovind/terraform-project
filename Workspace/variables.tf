variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "workspace-demo"
}

variable "instance_types" {
  description = "Instance types per workspace"
  type        = map(string)
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

variable "security_rules" {
  description = "Security group rules per workspace"
  type = map(list(object({
    port        = number
    cidr_blocks = list(string)
  })))
  default = {
    dev = [
      {
        port        = 22
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        port        = 80
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    staging = [
      {
        port        = 22
        cidr_blocks = ["10.0.0.0/8"]
      },
      {
        port        = 80
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
    prod = [
      {
        port        = 22
        cidr_blocks = ["10.0.0.0/8"]
      },
      {
        port        = 80
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        port        = 443
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}