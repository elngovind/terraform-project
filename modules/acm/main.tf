# ACM Certificate
resource "aws_acm_certificate" "main" {
  count = var.enable_acm ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-certificate"
  }
}

# Route53 Zone (if you want to manage DNS with Terraform)
data "aws_route53_zone" "main" {
  count = var.enable_acm && var.create_route53_records ? 1 : 0

  name         = var.domain_name
  private_zone = false
}

# Route53 records for ACM validation
resource "aws_route53_record" "acm_validation" {
  for_each = var.enable_acm && var.create_route53_records ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main[0].zone_id
}

# ACM Certificate validation
resource "aws_acm_certificate_validation" "main" {
  count = var.enable_acm && var.create_route53_records ? 1 : 0

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}

# Route53 record for ALB
resource "aws_route53_record" "alb" {
  count = var.enable_acm && var.create_route53_records && var.alb_dns_name != "" ? 1 : 0

  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}