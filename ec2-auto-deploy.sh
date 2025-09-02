#!/bin/bash

# Paradise Resort - Complete Auto Deploy with Database
# Use this as EC2 User Data

apt update -y
apt install -y nginx git

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Clone and setup
cd /var/www
git clone https://github.com/venkey3413/coolie.git
cd coolie
npm install

# Setup nginx proxy
cat > /etc/nginx/sites-available/resort << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

ln -s /etc/nginx/sites-available/resort /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
systemctl restart nginx

# Install PM2 for process management
npm install -g pm2

# Start app with PM2
pm2 start server.js --name "paradise-resort"
pm2 startup
pm2 save

echo "✅ Paradise Resort deployed with database!"
echo "🌐 Access: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"