# Terraform Initialization Commands

## Overview
Initialization commands are the first step in any Terraform workflow. These commands set up your working directory and prepare it for infrastructure management.

## Core Commands

### `terraform init`
**Purpose**: Initialize a Terraform working directory

**Syntax**:
```bash
terraform init [options]
```

**What it does**:
1. Downloads and installs provider plugins
2. Initializes backend configuration
3. Downloads modules from registry
4. Creates `.terraform` directory

**Step-by-step Example**:
```bash
# 1. Navigate to your Terraform project
cd /path/to/terraform/project

# 2. Initialize the directory
terraform init

# Expected output:
# Initializing the backend...
# Initializing provider plugins...
# - Finding latest version of hashicorp/aws...
# - Installing hashicorp/aws v5.31.0...
# Terraform has been successfully initialized!
```

**Common Options**:
```bash
# Upgrade providers to latest versions
terraform init -upgrade

# Reconfigure backend
terraform init -reconfigure

# Skip backend initialization
terraform init -backend=false

# Copy existing state
terraform init -migrate-state

# Force copy without prompting
terraform init -force-copy
```

**Troubleshooting**:
```bash
# If init fails, try:
rm -rf .terraform/
terraform init

# For network issues:
terraform init -plugin-dir=/path/to/plugins

# For backend issues:
terraform init -reconfigure
```

---

### `terraform version`
**Purpose**: Display Terraform version information

**Syntax**:
```bash
terraform version
```

**Example Output**:
```bash
$ terraform version
Terraform v1.9.0
on darwin_amd64
+ provider registry.terraform.io/hashicorp/aws v5.31.0
+ provider registry.terraform.io/hashicorp/random v3.4.3
```

**Detailed Version Info**:
```bash
# Show version in JSON format
terraform version -json

# Example JSON output:
{
  "terraform_version": "1.9.0",
  "platform": "darwin_amd64",
  "provider_selections": {
    "registry.terraform.io/hashicorp/aws": "5.31.0"
  }
}
```

---

### `terraform providers`
**Purpose**: Show provider requirements and versions

**Syntax**:
```bash
terraform providers [subcommand]
```

**Examples**:
```bash
# List required providers
terraform providers

# Show provider dependency tree
terraform providers schema

# Lock provider versions
terraform providers lock

# Mirror providers locally
terraform providers mirror /path/to/mirror
```

**Sample Output**:
```bash
$ terraform providers

Providers required by configuration:
.
├── provider[registry.terraform.io/hashicorp/aws] ~> 5.0
├── provider[registry.terraform.io/hashicorp/random]
└── module.networking
    └── provider[registry.terraform.io/hashicorp/aws]
```

---

## Initialization Workflow

### Step 1: Project Setup
```bash
# Create project directory
mkdir my-terraform-project
cd my-terraform-project

# Create main configuration file
cat > main.tf << EOF
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
EOF
```

### Step 2: Initialize
```bash
# Initialize the project
terraform init

# Verify initialization
ls -la .terraform/
# Should show:
# .terraform/
# ├── providers/
# └── terraform.tfstate
```

### Step 3: Verify Setup
```bash
# Check Terraform version
terraform version

# Verify providers
terraform providers

# Validate configuration
terraform validate
```

---

## Common Initialization Scenarios

### New Project
```bash
# 1. Create and enter directory
mkdir new-project && cd new-project

# 2. Create basic configuration
echo 'terraform { required_version = ">= 1.9.0" }' > main.tf

# 3. Initialize
terraform init
```

### Existing Project
```bash
# 1. Clone repository
git clone https://github.com/example/terraform-project.git
cd terraform-project

# 2. Initialize
terraform init

# 3. Select workspace if needed
terraform workspace select production
```

### With Remote Backend
```bash
# 1. Configure backend in main.tf
cat >> main.tf << EOF
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
EOF

# 2. Initialize with backend
terraform init
```

### Module Development
```bash
# 1. Create module structure
mkdir -p modules/vpc/{variables.tf,main.tf,outputs.tf}

# 2. Initialize root module
terraform init

# 3. Initialize after adding modules
terraform get
terraform init
```

---

## Troubleshooting Initialization

### Common Errors and Solutions

#### Error: "Failed to install provider"
```bash
# Problem: Network connectivity or provider not found
# Solution:
terraform init -upgrade
# or
rm -rf .terraform/
terraform init
```

#### Error: "Backend configuration changed"
```bash
# Problem: Backend settings modified
# Solution:
terraform init -reconfigure
# or
terraform init -migrate-state
```

#### Error: "Module not found"
```bash
# Problem: Module source incorrect or inaccessible
# Solution:
terraform get
terraform init
```

#### Error: "Provider version constraint"
```bash
# Problem: Version conflicts
# Solution: Update version constraints in terraform block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
}
```

### Debug Initialization
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform init

# Check specific issues
terraform init -get=false  # Skip module download
terraform init -backend=false  # Skip backend init
```

---

## Best Practices

### 1. Version Constraints
```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### 2. Lock File Management
```bash
# Commit .terraform.lock.hcl to version control
git add .terraform.lock.hcl
git commit -m "Add provider lock file"

# Update lock file when needed
terraform providers lock -platform=linux_amd64 -platform=darwin_amd64
```

### 3. Clean Initialization
```bash
# Always clean before major changes
rm -rf .terraform/
rm .terraform.lock.hcl
terraform init
```

### 4. Automated Initialization
```bash
#!/bin/bash
# init.sh - Automated initialization script

set -e

echo "Cleaning previous initialization..."
rm -rf .terraform/

echo "Initializing Terraform..."
terraform init -input=false

echo "Validating configuration..."
terraform validate

echo "Initialization complete!"
```

---

## Next Steps

After successful initialization:
1. **[Validation](validation.md)** - Validate your configuration
2. **[Planning](planning-applying.md)** - Create execution plans
3. **[State Management](../state-management/state-commands.md)** - Manage infrastructure state

## Quick Reference

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `terraform init` | Initialize directory | First time, after config changes |
| `terraform init -upgrade` | Upgrade providers | Update to latest versions |
| `terraform init -reconfigure` | Reconfigure backend | Backend settings changed |
| `terraform version` | Show version | Verify installation |
| `terraform providers` | List providers | Check dependencies |