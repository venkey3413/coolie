#!/bin/bash

# EC2 User Data Script - Auto-deploy on instance launch
# Copy this script to EC2 User Data when launching instance

yum update -y
yum install -y httpd git

# Clone repository
cd /tmp
git clone https://github.com/venkey3413/coolie.git
cd coolie

# Copy files to web root
cp -r * /var/www/html/
chown -R apache:apache /var/www/html/
chmod -R 755 /var/www/html/

# Start Apache
systemctl start httpd
systemctl enable httpd

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --reload