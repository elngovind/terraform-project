output "workspace_name" {
  description = "Current workspace name"
  value       = terraform.workspace
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.workspace_bucket.bucket
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.workspace_instance.id
}

output "instance_type" {
  description = "EC2 instance type"
  value       = aws_instance.workspace_instance.instance_type
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.workspace_sg.id
}

output "environment_summary" {
  description = "Environment summary"
  value = {
    workspace     = terraform.workspace
    instance_type = aws_instance.workspace_instance.instance_type
    bucket_name   = aws_s3_bucket.workspace_bucket.bucket
    region        = var.aws_region
  }
}