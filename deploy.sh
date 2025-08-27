#!/bin/bash

# Coolie Furniture Ecommerce - AWS EC2 Deployment Script

set -e

echo "🚀 Starting Coolie deployment on AWS EC2..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p uploads
mkdir -p nginx/ssl
mkdir -p database

# Set permissions
chmod +x deploy.sh

# Load environment variables
if [ -f .env.production ]; then
    print_status "Loading production environment variables..."
    export $(cat .env.production | grep -v '^#' | xargs)
else
    print_warning ".env.production file not found. Please create it with your configuration."
    exit 1
fi

# Build and start containers
print_status "Building Docker images..."
docker-compose -f docker-compose.prod.yml build --no-cache

print_status "Starting containers..."
docker-compose -f docker-compose.prod.yml up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 30

# Check if services are running
print_status "Checking service status..."
docker-compose -f docker-compose.prod.yml ps

# Test database connection
print_status "Testing database connection..."
docker-compose -f docker-compose.prod.yml exec postgres pg_isready -U coolie_user -d coolie_db

# Test backend health
print_status "Testing backend health..."
curl -f http://localhost:3001/health || print_warning "Backend health check failed"

# Test frontend
print_status "Testing frontend..."
curl -f http://localhost:80 || print_warning "Frontend health check failed"

print_status "🎉 Deployment completed successfully!"
print_status "Frontend: http://$(curl -s ifconfig.me):80"
print_status "Backend API: http://$(curl -s ifconfig.me):3001"
print_status "Database: PostgreSQL running on port 5432"

echo ""
print_status "To view logs:"
echo "docker-compose -f docker-compose.prod.yml logs -f"
echo ""
print_status "To stop services:"
echo "docker-compose -f docker-compose.prod.yml down"
echo ""
print_status "To restart services:"
echo "docker-compose -f docker-compose.prod.yml restart"