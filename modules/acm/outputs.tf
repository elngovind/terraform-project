output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.enable_acm ? aws_acm_certificate.main[0].arn : ""
}

output "certificate_status" {
  description = "Status of the ACM certificate"
  value       = var.enable_acm ? aws_acm_certificate.main[0].status : ""
}

output "domain_name" {
  description = "Domain name of the certificate"
  value       = var.enable_acm ? aws_acm_certificate.main[0].domain_name : ""
}

output "domain_validation_options" {
  description = "Domain validation options for manual DNS validation"
  value       = var.enable_acm ? aws_acm_certificate.main[0].domain_validation_options : []
}