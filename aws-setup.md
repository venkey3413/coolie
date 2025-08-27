# AWS EC2 Deployment Guide for Coolie Furniture Ecommerce

## Prerequisites

1. **AWS Account** with EC2 access
2. **EC2 Instance** (recommended: t3.medium or larger)
3. **Security Group** configured with proper ports
4. **Domain name** (optional, for SSL)

## Step 1: Launch EC2 Instance

### Instance Configuration
- **AMI**: Ubuntu Server 22.04 LTS
- **Instance Type**: t3.medium (2 vCPU, 4 GB RAM) minimum
- **Storage**: 20 GB GP3 SSD minimum
- **Security Group**: Create new with following rules

### Security Group Rules
```
Type            Protocol    Port Range    Source
SSH             TCP         22            Your IP/0.0.0.0/0
HTTP            TCP         80            0.0.0.0/0
HTTPS           TCP         443           0.0.0.0/0
Custom TCP      TCP         3001          0.0.0.0/0 (Backend API)
Custom TCP      TCP         5432          Your IP (Database - optional)
```

## Step 2: Connect to EC2 Instance

```bash
# Connect via SSH
ssh -i your-key.pem ubuntu@your-ec2-public-ip

# Update system
sudo apt update && sudo apt upgrade -y
```

## Step 3: Install Docker and Docker Compose

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version

# Logout and login again for group changes
exit
```

## Step 4: Clone Your Repository

```bash
# Clone your repository
git clone https://github.com/your-username/coolie-furniture-ecommerce.git
cd coolie-furniture-ecommerce

# Make deploy script executable
chmod +x deploy.sh
```

## Step 5: Configure Environment Variables

```bash
# Copy and edit production environment file
cp .env.production.example .env.production
nano .env.production
```

Update the following variables:
```env
POSTGRES_PASSWORD=your_very_secure_database_password
FRONTEND_URL=http://your-ec2-public-ip
BACKEND_URL=http://your-ec2-public-ip:3001
VITE_API_URL=http://your-ec2-public-ip:3001
JWT_SECRET=your_jwt_secret_key_here_make_it_very_long_and_secure
```

## Step 6: Deploy the Application

```bash
# Run the deployment script
./deploy.sh
```

## Manual Container Management

### Build Individual Images

```bash
# Build PostgreSQL (using official image)
docker pull postgres:15-alpine

# Build Backend
docker build -f backend/Dockerfile.prod -t coolie-backend ./backend

# Build Frontend
docker build -f Dockerfile.frontend.prod -t coolie-frontend .

# Pull Nginx
docker pull nginx:alpine
```

### Start Containers Manually

```bash
# Create network
docker network create coolie-network

# Start PostgreSQL
docker run -d \
  --name coolie-postgres \
  --network coolie-network \
  -e POSTGRES_DB=coolie_db \
  -e POSTGRES_USER=coolie_user \
  -e POSTGRES_PASSWORD=your_password \
  -v postgres_data:/var/lib/postgresql/data \
  -v $(pwd)/database/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -p 5432:5432 \
  postgres:15-alpine

# Start Backend
docker run -d \
  --name coolie-backend \
  --network coolie-network \
  -e NODE_ENV=production \
  -e DATABASE_URL=postgresql://coolie_user:your_password@coolie-postgres:5432/coolie_db \
  -e JWT_SECRET=your_jwt_secret \
  -p 3001:3001 \
  coolie-backend

# Start Frontend
docker run -d \
  --name coolie-frontend \
  --network coolie-network \
  -e VITE_API_URL=http://your-ec2-ip:3001 \
  -p 80:80 \
  coolie-frontend

# Start Nginx (optional, for reverse proxy)
docker run -d \
  --name coolie-nginx \
  --network coolie-network \
  -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf \
  -p 8080:80 \
  nginx:alpine
```

### Container Management Commands

```bash
# View running containers
docker ps

# View all containers
docker ps -a

# View logs
docker logs coolie-backend
docker logs coolie-frontend
docker logs coolie-postgres

# Stop containers
docker stop coolie-frontend coolie-backend coolie-postgres

# Remove containers
docker rm coolie-frontend coolie-backend coolie-postgres

# Remove network
docker network rm coolie-network

# Remove volumes (WARNING: This will delete database data)
docker volume rm postgres_data
```

## Port Configuration

| Service    | Container Port | Host Port | Description |
|------------|----------------|-----------|-------------|
| Frontend   | 80             | 80        | React app   |
| Backend    | 3001           | 3001      | API server  |
| PostgreSQL | 5432           | 5432      | Database    |
| Nginx      | 80             | 8080      | Reverse proxy |

## SSL Configuration (Optional)

### Using Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d your-domain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/key.pem

# Update nginx configuration to use SSL
# Edit nginx/nginx.conf and uncomment HTTPS server block
```

## Monitoring and Maintenance

### Health Checks

```bash
# Check application health
curl http://your-ec2-ip/health
curl http://your-ec2-ip:3001/health

# Check database
docker exec coolie-postgres pg_isready -U coolie_user -d coolie_db
```

### Backup Database

```bash
# Create backup
docker exec coolie-postgres pg_dump -U coolie_user coolie_db > backup.sql

# Restore backup
docker exec -i coolie-postgres psql -U coolie_user coolie_db < backup.sql
```

### Update Application

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build --no-cache
docker-compose -f docker-compose.prod.yml up -d
```

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   sudo lsof -i :80
   sudo kill -9 PID
   ```

2. **Database connection failed**
   ```bash
   docker logs coolie-postgres
   docker exec -it coolie-postgres psql -U coolie_user -d coolie_db
   ```

3. **Frontend not loading**
   ```bash
   docker logs coolie-frontend
   curl -I http://localhost:80
   ```

4. **Backend API errors**
   ```bash
   docker logs coolie-backend
   curl http://localhost:3001/health
   ```

### Performance Optimization

1. **Enable Docker BuildKit**
   ```bash
   export DOCKER_BUILDKIT=1
   ```

2. **Use multi-stage builds** (already implemented in Dockerfiles)

3. **Configure nginx caching** (already configured)

4. **Monitor resource usage**
   ```bash
   docker stats
   htop
   ```

## Security Considerations

1. **Change default passwords** in .env.production
2. **Use strong JWT secrets**
3. **Configure firewall** (ufw)
4. **Regular security updates**
5. **Use SSL certificates** for production
6. **Limit database access** to application only
7. **Regular backups**

## Cost Optimization

1. **Use appropriate instance size**
2. **Configure auto-scaling** (optional)
3. **Use spot instances** for development
4. **Monitor usage** with CloudWatch
5. **Set up billing alerts**