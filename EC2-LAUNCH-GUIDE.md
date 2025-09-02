# 🚀 EC2 Launch Guide - Paradise Resort

## Method 1: Auto-Deploy (Easiest)

### Step 1: Launch EC2 Instance
1. Go to AWS Console → EC2 → Launch Instance
2. Choose **Amazon Linux 2**
3. Instance type: **t2.micro** (free tier)
4. In **Advanced Details** → **User data**, paste:
```bash
#!/bin/bash
yum update -y
yum install -y httpd git
cd /tmp
git clone https://github.com/venkey3413/coolie.git
cd coolie
cp -r * /var/www/html/
chown -R apache:apache /var/www/html/
chmod -R 755 /var/www/html/
systemctl start httpd
systemctl enable httpd
```

### Step 2: Configure Security Group
- **HTTP (80)**: 0.0.0.0/0
- **SSH (22)**: Your IP only

### Step 3: Launch & Access
- Launch instance
- Wait 2-3 minutes
- Visit: `http://YOUR-EC2-PUBLIC-IP`

## Method 2: Manual Deploy

### Step 1: SSH to EC2
```bash
ssh -i your-key.pem ec2-user@YOUR-EC2-IP
```

### Step 2: Upload & Run
```bash
# Upload files via SCP or clone repo
git clone https://github.com/venkey3413/coolie.git
cd coolie

# Run deployment script
chmod +x deploy-ec2.sh
./deploy-ec2.sh
```

## Method 3: Docker (Advanced)

### Create Dockerfile
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
```

### Deploy
```bash
# On EC2
sudo yum install -y docker
sudo systemctl start docker
sudo docker build -t paradise-resort .
sudo docker run -d -p 80:80 paradise-resort
```

## 💰 Cost Estimate
- **t2.micro**: Free tier (750 hours/month)
- **Data transfer**: ~$0.09/GB
- **Storage**: ~$0.10/GB/month

## 🔧 Troubleshooting
- **Can't access website**: Check Security Group (port 80)
- **Permission denied**: Run with `sudo`
- **Apache not starting**: Check logs: `sudo journalctl -u httpd`

## 📊 Monitoring
```bash
# Check Apache status
sudo systemctl status httpd

# View logs
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log
```