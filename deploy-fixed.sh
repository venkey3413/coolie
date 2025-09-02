#!/bin/bash

# Paradise Resort - Easy Launch Deploy Script
# Fixed version without carriage returns and improved error handling

set -e  # Exit on any error

# Configuration
BUCKET_NAME="paradise-resort-website-$(date +%s)"  # Unique bucket name
REGION="us-east-1"
DISTRIBUTION_ID=""  # Add your CloudFront distribution ID here if needed

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏖️  Paradise Resort - Easy Launch Deploy${NC}"
echo "=================================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
    echo "Install: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Deployment Configuration:${NC}"
echo "   Bucket: $BUCKET_NAME"
echo "   Region: $REGION"
echo ""

# Create bucket
echo -e "${BLUE}🪣 Creating S3 bucket...${NC}"
if aws s3 mb "s3://$BUCKET_NAME" --region "$REGION"; then
    echo -e "${GREEN}✅ Bucket created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create bucket${NC}"
    exit 1
fi

# Configure bucket for static website hosting
echo -e "${BLUE}🌐 Configuring static website hosting...${NC}"
aws s3 website "s3://$BUCKET_NAME" --index-document index.html --error-document error.html

# Set bucket policy for public access
echo -e "${BLUE}🔓 Setting bucket policy for public access...${NC}"
cat > bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOF

aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file://bucket-policy.json
rm bucket-policy.json

# Upload files to S3
echo -e "${BLUE}📤 Uploading files to S3...${NC}"
aws s3 sync . "s3://$BUCKET_NAME" \
    --delete \
    --exclude "*.md" \
    --exclude ".git/*" \
    --exclude "deploy*.sh" \
    --exclude "bucket-policy.json" \
    --exclude "*.DS_Store" \
    --exclude ".env"

# Set proper content types
echo -e "${BLUE}🏷️  Setting content types...${NC}"
aws s3 cp "s3://$BUCKET_NAME/css/style.css" "s3://$BUCKET_NAME/css/style.css" \
    --metadata-directive REPLACE \
    --content-type "text/css" \
    --cache-control "max-age=31536000"

aws s3 cp "s3://$BUCKET_NAME/js/script.js" "s3://$BUCKET_NAME/js/script.js" \
    --metadata-directive REPLACE \
    --content-type "application/javascript" \
    --cache-control "max-age=31536000"

# Invalidate CloudFront cache if distribution ID is provided
if [ ! -z "$DISTRIBUTION_ID" ]; then
    echo -e "${BLUE}🔄 Invalidating CloudFront cache...${NC}"
    aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"
    echo -e "${GREEN}✅ CloudFront cache invalidation initiated${NC}"
fi

# Get website URL
WEBSITE_URL="http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo "=================================================="
echo -e "${BLUE}🌐 Website URL:${NC} $WEBSITE_URL"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Test your website at the URL above"
echo "2. Set up CloudFront for better performance and HTTPS"
echo "3. Configure a custom domain (optional)"
echo ""

# Test website accessibility
echo -e "${BLUE}🔍 Testing website accessibility...${NC}"
sleep 5  # Wait for S3 to propagate
if curl -s --head "$WEBSITE_URL" | head -n 1 | grep -q "200 OK"; then
    echo -e "${GREEN}✅ Website is accessible!${NC}"
    echo -e "${GREEN}🏖️  Paradise Resort is now live!${NC}"
else
    echo -e "${YELLOW}⚠️  Website might take a few minutes to be accessible${NC}"
    echo -e "${BLUE}Please try: $WEBSITE_URL${NC}"
fi