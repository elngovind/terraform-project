#!/bin/bash
yum update -y
yum install -y httpd

# Create environment-specific content
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Workspace Demo</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .environment { color: #007acc; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Welcome to Terraform Workspace Demo</h1>
        <p>Environment: <span class="environment">${environment}</span></p>
        <p>Instance deployed via Terraform workspace: <strong>${environment}</strong></p>
        <p>Timestamp: $(date)</p>
    </div>
</body>
</html>
EOF

systemctl start httpd
systemctl enable httpd