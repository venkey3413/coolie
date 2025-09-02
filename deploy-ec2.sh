#!/bin/bash

# Paradise Resort - EC2 Deployment Script
# Easy launch on AWS EC2

set -e

echo "🏖️  Paradise Resort - EC2 Deployment"
echo "===================================="

# Update system
sudo yum update -y

# Install Apache
sudo yum install -y httpd

# Start Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Copy website files
sudo cp -r * /var/www/html/
sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

# Configure Apache for SPA
sudo tee /etc/httpd/conf.d/paradise-resort.conf > /dev/null <<EOF
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
    DirectoryIndex index.html
</Directory>

<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
</IfModule>
EOF

# Restart Apache
sudo systemctl restart httpd

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "✅ Deployment Complete!"
echo "🌐 Website URL: http://$PUBLIC_IP"
echo ""
echo "📝 Security Group Requirements:"
echo "   - Port 80 (HTTP) - 0.0.0.0/0"
echo "   - Port 22 (SSH) - Your IP"