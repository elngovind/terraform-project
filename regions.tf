# Region-specific configurations and validations

# Validate that the region is supported
locals {
  supported_regions = [
    "us-east-1",      # N. Virginia
    "us-east-2",      # Ohio
    "us-west-1",      # N. California
    "us-west-2",      # Oregon
    "eu-west-1",      # Ireland
    "eu-west-2",      # London
    "eu-west-3",      # Paris
    "eu-central-1",   # Frankfurt
    "eu-north-1",     # Stockholm
    "ap-southeast-1", # Singapore
    "ap-southeast-2", # Sydney
    "ap-northeast-1", # Tokyo
    "ap-northeast-2", # Seoul
    "ap-south-1",     # Mumbai
    "ca-central-1",   # Canada
    "sa-east-1"       # São Paulo
  ]

  is_supported_region = contains(local.supported_regions, var.aws_region)
}

# Region validation
resource "null_resource" "region_validation" {
  count = local.is_supported_region ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'Error: Region ${var.aws_region} is not in the supported regions list' && exit 1"
  }
}

# Region-specific availability zone count
locals {
  # Some regions have fewer AZs, ensure we have at least 2
  min_azs_required = 2
  available_azs    = length(data.aws_availability_zones.available.names)
  
  # Use minimum of available AZs or 2 (since we only need 2 for this setup)
  azs_to_use = min(local.available_azs, 2)
}

# Validation for minimum AZ requirement
resource "null_resource" "az_validation" {
  count = local.available_azs >= local.min_azs_required ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'Error: Region ${var.aws_region} has only ${local.available_azs} AZs, minimum ${local.min_azs_required} required' && exit 1"
  }
}