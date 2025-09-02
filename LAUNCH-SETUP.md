# 🚀 Paradise Resort - Complete Launch Setup

## 🗄️ **New Database Features**
- SQLite database for bookings & transactions
- Contact form data storage
- REST API backend
- Real-time data persistence

## 📋 **EC2 Ubuntu Launch (With Database)**

### **Auto-Deploy Script:**
```bash
#!/bin/bash
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

# Start app
npm start &
```

### **Manual Setup:**
```bash
# SSH to EC2
ssh -i your-key.pem ubuntu@YOUR-EC2-IP

# Clone repo
git clone https://github.com/venkey3413/coolie.git
cd coolie

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install dependencies
npm install

# Start server
npm start
```

### **Security Group:**
- **HTTP (80)**: 0.0.0.0/0
- **Custom TCP (3000)**: 0.0.0.0/0
- **SSH (22)**: Your IP

## 🌐 **Access Points:**
- **Website**: `http://YOUR-EC2-IP`
- **API**: `http://YOUR-EC2-IP:3000/api/bookings`

## 📊 **Database Tables:**
- `bookings` - Reservation data
- `transactions` - Payment records
- `contacts` - Contact submissions

## 🔧 **Management:**
```bash
# View bookings
curl http://YOUR-EC2-IP:3000/api/bookings

# Check database
sqlite3 resort.db "SELECT * FROM bookings;"

# Server logs
pm2 logs (if using PM2)
```

## 💰 **Cost:**
- **t2.micro**: FREE tier
- **Storage**: ~$1/month
- **Data transfer**: ~$0.09/GB

**Total**: ~$1-5/month