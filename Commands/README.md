# Terraform Commands Reference Guide

This comprehensive guide covers all essential Terraform commands for learners, troubleshooting, and daily operations.

## 📁 Directory Structure

```
Commands/
├── README.md                    # This file - Complete command overview
├── basic/
│   ├── initialization.md       # terraform init, version, providers
│   ├── planning-applying.md     # terraform plan, apply, destroy
│   └── validation.md           # terraform validate, fmt
├── advanced/
│   ├── import-export.md        # terraform import, state operations
│   ├── modules.md              # Module-related commands
│   └── functions.md            # Built-in functions and expressions
├── troubleshooting/
│   ├── common-errors.md        # Common error scenarios and fixes
│   ├── debugging.md            # Debug flags and logging
│   └── recovery.md             # State recovery and repair
├── state-management/
│   ├── state-commands.md       # terraform state list, show, mv, rm
│   ├── backend-config.md       # Remote state configuration
│   └── locking.md              # State locking and unlocking
├── workspace/
│   ├── workspace-commands.md   # terraform workspace operations
│   └── multi-environment.md    # Managing multiple environments
└── debugging/
    ├── logging.md              # TF_LOG and debugging
    ├── crash-analysis.md       # Analyzing crash logs
    └── performance.md          # Performance troubleshooting
```

## 🚀 Quick Command Reference

### Essential Daily Commands
```bash
terraform init          # Initialize working directory
terraform plan          # Show execution plan
terraform apply         # Apply changes
terraform destroy       # Destroy infrastructure
terraform validate      # Validate configuration
terraform fmt           # Format configuration files
```

### State Management
```bash
terraform state list    # List resources in state
terraform state show    # Show resource details
terraform state mv      # Move/rename resources
terraform state rm      # Remove resources from state
terraform refresh       # Update state with real infrastructure
```

### Workspace Management
```bash
terraform workspace list     # List workspaces
terraform workspace new      # Create new workspace
terraform workspace select   # Switch workspace
terraform workspace delete   # Delete workspace
```

### Troubleshooting
```bash
terraform plan -detailed-exitcode    # Get detailed exit codes
terraform apply -auto-approve         # Apply without confirmation
terraform destroy -auto-approve       # Destroy without confirmation
terraform force-unlock LOCK_ID        # Force unlock state
terraform taint RESOURCE              # Mark resource for recreation
terraform untaint RESOURCE            # Remove taint from resource
```

## 📚 Learning Path

### **Beginner Level** (Start Here)
1. [Basic Initialization](basic/initialization.md) - `terraform init`, `version`
2. [Planning and Applying](basic/planning-applying.md) - `plan`, `apply`, `destroy`
3. [Validation](basic/validation.md) - `validate`, `fmt`

### **Intermediate Level**
4. [State Management](state-management/state-commands.md) - State operations
5. [Workspace Management](workspace/workspace-commands.md) - Multi-environment
6. [Import/Export](advanced/import-export.md) - Bringing existing resources

### **Advanced Level**
7. [Troubleshooting](troubleshooting/common-errors.md) - Error resolution
8. [Debugging](debugging/logging.md) - Advanced debugging
9. [Performance](debugging/performance.md) - Optimization

## 🔧 Command Categories

### 1. **Initialization & Setup**
- `terraform init` - Initialize working directory
- `terraform version` - Show Terraform version
- `terraform providers` - Show provider requirements

### 2. **Planning & Execution**
- `terraform plan` - Create execution plan
- `terraform apply` - Apply changes
- `terraform destroy` - Destroy infrastructure

### 3. **Validation & Formatting**
- `terraform validate` - Validate configuration
- `terraform fmt` - Format configuration files
- `terraform console` - Interactive console

### 4. **State Management**
- `terraform state` - State management commands
- `terraform refresh` - Update state file
- `terraform import` - Import existing resources

### 5. **Workspace Management**
- `terraform workspace` - Workspace operations
- Environment isolation and management

### 6. **Debugging & Troubleshooting**
- `terraform show` - Show current state
- `terraform output` - Show output values
- `terraform graph` - Generate dependency graph

## 🆘 Emergency Commands

### When Things Go Wrong
```bash
# State is locked
terraform force-unlock LOCK_ID

# Configuration drift detected
terraform refresh
terraform plan

# Resource needs recreation
terraform taint aws_instance.example
terraform apply

# Remove resource from management
terraform state rm aws_instance.example

# Import existing resource
terraform import aws_instance.example i-1234567890abcdef0

# Recover from crash
terraform show
terraform state list
```

### Quick Fixes
```bash
# Fix formatting issues
terraform fmt -recursive

# Validate all configurations
terraform validate

# Check for unused variables
terraform plan -detailed-exitcode

# Force provider re-initialization
terraform init -upgrade

# Clear cached plugins
rm -rf .terraform/
terraform init
```

## 🎯 Common Workflows

### **New Project Setup**
```bash
# 1. Initialize project
terraform init

# 2. Validate configuration
terraform validate

# 3. Format code
terraform fmt

# 4. Plan deployment
terraform plan

# 5. Apply changes
terraform apply
```

### **Daily Development**
```bash
# 1. Pull latest changes
git pull

# 2. Check current state
terraform plan

# 3. Apply if needed
terraform apply

# 4. Verify outputs
terraform output
```

### **Troubleshooting Workflow**
```bash
# 1. Check state
terraform state list

# 2. Validate config
terraform validate

# 3. Plan with details
terraform plan -detailed-exitcode

# 4. Check logs
export TF_LOG=DEBUG
terraform apply

# 5. Analyze issues
terraform show
```

## 📖 Detailed Guides

Each subdirectory contains detailed explanations, examples, and troubleshooting steps:

- **[Basic Commands](basic/)** - Essential commands for beginners
- **[Advanced Commands](advanced/)** - Complex operations and imports
- **[Troubleshooting](troubleshooting/)** - Error resolution and debugging
- **[State Management](state-management/)** - State file operations
- **[Workspace Management](workspace/)** - Multi-environment workflows
- **[Debugging](debugging/)** - Advanced debugging techniques

## 🔗 Quick Links

- [Common Errors & Solutions](troubleshooting/common-errors.md)
- [State Recovery Guide](troubleshooting/recovery.md)
- [Debug Logging Setup](debugging/logging.md)
- [Performance Optimization](debugging/performance.md)
- [Multi-Environment Setup](workspace/multi-environment.md)

## 💡 Pro Tips

1. **Always run `terraform plan` before `apply`**
2. **Use workspaces for environment isolation**
3. **Enable debug logging for troubleshooting**
4. **Keep state files secure and backed up**
5. **Use version constraints for providers**
6. **Format code regularly with `terraform fmt`**
7. **Validate configurations before committing**
8. **Use `terraform taint` for problematic resources**

---

**Need Help?** Check the specific command guides in each subdirectory for detailed explanations and examples.