output "cross_account_role_arn" {
  description = "ARN of the cross-account deployment role"
  value       = var.account_type == "production" ? aws_iam_role.cross_account_deployment[0].arn : ""
}