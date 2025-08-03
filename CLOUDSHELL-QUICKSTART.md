# AWS CloudShell Quick Start

## 🚀 5-Minute Setup in CloudShell

### Step 1: Launch CloudShell
1. Login to **AWS Console**
2. Click **CloudShell icon** (terminal icon in top navigation)
3. Wait for initialization (1-2 minutes)

### Step 2: One-Command Setup
```bash
# Download and run setup script
curl -s https://raw.githubusercontent.com/elngovind/terraform-project/main/cloudshell-setup.sh | bash
```

### Step 3: Configure Your Project
```bash
# Navigate to project
cd terraform-project

# Quick configuration
./quick-setup.sh
```

### Step 4: Deploy Infrastructure
```bash
# Single-account deployment (recommended for first-time)
make deploy-single-account

# Multi-account deployment (advanced)
./deploy-production.sh
```

### Step 5: Access Your Resources
```bash
# Get deployment information
terraform output

# Access Jenkins (if deployed)
echo "Jenkins URL: $(terraform output -raw jenkins_url)"

# Access Application
echo "App URL: http://$(terraform output -raw alb_dns_name)"
```

## CloudShell Benefits

✅ **No Local Setup Required** - Everything runs in AWS  
✅ **Pre-configured AWS CLI** - Already authenticated  
✅ **Persistent Storage** - Files saved between sessions  
✅ **Free to Use** - No additional charges  
✅ **Latest Tools** - Always up-to-date AWS tools  

## CloudShell Limitations

⚠️ **Session Timeout** - 20 minutes of inactivity  
⚠️ **Storage Limit** - 1GB persistent storage  
⚠️ **Region Specific** - Files stored per region  
⚠️ **No Root Access** - Limited system modifications  

## Troubleshooting in CloudShell

### Issue: Terraform Not Found
```bash
# Reinstall Terraform
wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
unzip terraform_1.9.8_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Issue: Session Timeout
```bash
# Keep session active
while true; do echo "keeping alive"; sleep 300; done &

# Save work frequently
git add . && git commit -m "checkpoint"
```

### Issue: Storage Full
```bash
# Check storage usage
df -h

# Clean up
rm -rf .terraform/
rm *.zip
```

## Next Steps

After successful deployment:
1. **Bookmark Jenkins URL** for future access
2. **Save terraform outputs** to a file
3. **Configure DNS** if using custom domain
4. **Set up monitoring** and alerts
5. **Plan backup strategy**

## Cleanup

```bash
# Destroy resources when done
terraform destroy -auto-approve

# Clean up files
cd .. && rm -rf terraform-project
```