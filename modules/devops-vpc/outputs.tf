output "devops_vpc_id" {
  description = "ID of the DevOps VPC"
  value       = aws_vpc.devops.id
}

output "devops_vpc_cidr_block" {
  description = "CIDR block of the DevOps VPC"
  value       = aws_vpc.devops.cidr_block
}

output "devops_web_subnet_ids" {
  description = "IDs of the DevOps web subnets"
  value       = aws_subnet.devops_web[*].id
}

output "devops_app_subnet_ids" {
  description = "IDs of the DevOps app subnets"
  value       = aws_subnet.devops_app[*].id
}