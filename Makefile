# Terraform Makefile for easy command execution

.PHONY: help init plan apply destroy clean validate format check

# Default environment and region
ENV ?= dev
REGION ?= us-east-1

# Help target
help: ## Show this help message
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup and initialization
setup: ## Run the setup script
	@./setup.sh

init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@terraform init

# Planning and validation
validate: ## Validate Terraform configuration
	@echo "Validating configuration..."
	@terraform validate

format: ## Format Terraform files
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive

plan: ## Create Terraform plan
	@echo "Creating plan for $(ENV) environment..."
	@terraform plan -var-file="environments/$(ENV).tfvars" -out=tfplan-$(ENV)

plan-dev: ## Create plan for development environment
	@$(MAKE) plan ENV=dev

plan-prod: ## Create plan for production environment
	@$(MAKE) plan ENV=prod

# Deployment
apply: ## Apply Terraform plan
	@echo "Applying plan for $(ENV) environment..."
	@terraform apply tfplan-$(ENV)

apply-dev: ## Apply development environment
	@$(MAKE) apply ENV=dev

apply-prod: ## Apply production environment
	@$(MAKE) apply ENV=prod

# Quick deploy (plan + apply)
deploy: plan apply ## Plan and apply in one command

deploy-dev: plan-dev apply-dev ## Deploy development environment

deploy-prod: plan-prod apply-prod ## Deploy production environment

# Region-specific deployments
plan-region: ## Create plan for specific region (usage: make plan-region REGION=us-west-2)
	@echo "Creating plan for $(REGION) region..."
	@terraform plan -var-file="environments/regions/$(REGION).tfvars" -out=tfplan-$(REGION)

apply-region: ## Apply plan for specific region
	@echo "Applying plan for $(REGION) region..."
	@terraform apply tfplan-$(REGION)

deploy-region: plan-region apply-region ## Deploy to specific region

destroy-region: ## Destroy infrastructure in specific region
	@echo "Destroying $(REGION) region infrastructure..."
	@terraform destroy -var-file="environments/regions/$(REGION).tfvars"

# Account-specific deployments
plan-devops: ## Create plan for DevOps account
	@echo "Creating plan for DevOps account..."
	@terraform workspace select devops || terraform workspace new devops
	@terraform plan -var-file="environments/accounts/devops.tfvars" -out=tfplan-devops

plan-production: ## Create plan for Production account
	@echo "Creating plan for Production account..."
	@terraform workspace select production || terraform workspace new production
	@terraform plan -var-file="environments/accounts/production.tfvars" -out=tfplan-production

plan-development: ## Create plan for Development account
	@echo "Creating plan for Development account..."
	@terraform workspace select development || terraform workspace new development
	@terraform plan -var-file="environments/accounts/development.tfvars" -out=tfplan-development

deploy-devops: plan-devops ## Deploy DevOps account
	@terraform apply tfplan-devops

deploy-production: plan-production ## Deploy Production account
	@echo "⚠️  DEPLOYING TO PRODUCTION ⚠️"
	@read -p "Are you sure? (yes/no): " confirm && [ "$$confirm" = "yes" ]
	@terraform apply tfplan-production

deploy-development: plan-development ## Deploy Development account
	@terraform apply tfplan-development

deploy-all-accounts: ## Deploy all accounts in sequence
	@./deploy-production.sh

# Single-account deployment
plan-single-account: ## Create plan for single-account deployment
	@echo "Creating plan for single-account deployment..."
	@terraform plan -var-file="environments/accounts/single-account.tfvars" -out=tfplan-single-account

deploy-single-account: plan-single-account ## Deploy single-account with separate VPCs
	@echo "Deploying single-account infrastructure with separate VPCs..."
	@terraform apply tfplan-single-account

# Destruction
destroy: ## Destroy infrastructure
	@echo "Destroying $(ENV) environment..."
	@terraform destroy -var-file="environments/$(ENV).tfvars"

destroy-dev: ## Destroy development environment
	@$(MAKE) destroy ENV=dev

destroy-prod: ## Destroy production environment
	@$(MAKE) destroy ENV=prod

# Information
output: ## Show Terraform outputs
	@terraform output

state: ## List Terraform state
	@terraform state list

show: ## Show current state
	@terraform show

# Maintenance
clean: ## Clean temporary files
	@echo "Cleaning temporary files..."
	@rm -f tfplan-*
	@rm -f *.tfplan
	@rm -f crash.log

refresh: ## Refresh Terraform state
	@terraform refresh -var-file="environments/$(ENV).tfvars"

# Security and compliance
check: validate format ## Run validation and formatting checks

# Documentation
docs: ## Generate documentation (requires terraform-docs)
	@if command -v terraform-docs >/dev/null 2>&1; then \
		echo "Generating documentation..."; \
		terraform-docs markdown table --output-file README-modules.md modules/; \
	else \
		echo "terraform-docs not installed. Install with: brew install terraform-docs"; \
	fi

# Advanced operations
import: ## Import existing resource (usage: make import RESOURCE=aws_instance.example ID=i-1234567890abcdef0)
	@terraform import $(RESOURCE) $(ID)

taint: ## Taint a resource for recreation (usage: make taint RESOURCE=aws_instance.example)
	@terraform taint $(RESOURCE)

untaint: ## Remove taint from a resource (usage: make untaint RESOURCE=aws_instance.example)
	@terraform untaint $(RESOURCE)

# Environment management
switch-workspace: ## Switch Terraform workspace (usage: make switch-workspace WORKSPACE=prod)
	@terraform workspace select $(WORKSPACE) || terraform workspace new $(WORKSPACE)

list-workspaces: ## List all Terraform workspaces
	@terraform workspace list

# Cost estimation (requires infracost)
cost: ## Estimate infrastructure costs
	@if command -v infracost >/dev/null 2>&1; then \
		echo "Estimating costs..."; \
		infracost breakdown --path .; \
	else \
		echo "infracost not installed. Install from: https://www.infracost.io/docs/"; \
	fi