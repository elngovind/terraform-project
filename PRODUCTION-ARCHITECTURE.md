# Production Architecture Guide

## Multi-Account Strategy

### Account Structure
```
├── Production Account (123456789012)
│   └── Production VPC (10.0.0.0/16)
│       ├── Web Subnets (10.0.1.0/24, 10.0.2.0/24)
│       ├── App Subnets (10.0.11.0/24, 10.0.12.0/24)
│       └── DB Subnets (10.0.21.0/24, 10.0.22.0/24)
│
├── DevOps Account (987654321098)
│   └── DevOps VPC (10.100.0.0/16)
│       ├── Jenkins Subnet (10.100.1.0/24)
│       ├── Monitoring Subnet (10.100.2.0/24)
│       └── Tools Subnet (10.100.3.0/24)
│
└── Development Account (456789012345)
    └── Dev VPC (10.10.0.0/16)
        ├── Dev Web Subnets
        ├── Dev App Subnets
        └── Dev DB Subnets
```

### VPC Peering Strategy
- DevOps VPC peers with Production VPC
- DevOps VPC peers with Development VPC
- Cross-account IAM roles for deployment access

## Deployment Strategy

### 1. DevOps Account Setup
```bash
# Deploy DevOps infrastructure first
terraform workspace new devops
terraform apply -var-file="terraform-configs/accounts/devops.tfvars"
```

### 2. Production Account Setup
```bash
# Deploy Production infrastructure
terraform workspace new production
terraform apply -var-file="terraform-configs/accounts/production.tfvars"
```

### 3. Cross-Account Connectivity
```bash
# Setup VPC peering and cross-account roles
terraform apply -var-file="terraform-configs/accounts/cross-account.tfvars"
```