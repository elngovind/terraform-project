# Cross-Account IAM Roles and Policies

# Cross-account deployment role for DevOps to access Production
resource "aws_iam_role" "cross_account_deployment" {
  count = var.account_type == "production" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-cross-account-deployment"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.devops_account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = "${var.project_name}-deployment"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-cross-account-deployment"
  }
}

# Policy for cross-account deployment
resource "aws_iam_role_policy" "cross_account_deployment" {
  count = var.account_type == "production" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-deployment-policy"
  role  = aws_iam_role.cross_account_deployment[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "rds:*",
          "secretsmanager:*",
          "acm:*",
          "route53:*",
          "cloudwatch:*",
          "logs:*",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}