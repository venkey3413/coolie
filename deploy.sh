#!/bin/bash

# Paradise Resort - AWS S3 Deployment Script
# Make sure to configure your AWS CLI before running this script

# Configuration
BUCKET_NAME="paradise-resort-website"
REGION="us-east-1"
DISTRIBUTION_ID=""  # Add your CloudFront distribution ID here

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏖️  Paradise Resort - AWS S3 Deployment${NC}"
echo "=================================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
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

# Create bucket if it doesn't exist
echo -e "${BLUE}🪣 Checking if bucket exists...${NC}"
if ! aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    echo -e "${GREEN}✅ Bucket exists${NC}"
else
    echo -e "${YELLOW}⚠️  Bucket doesn't exist. Creating...${NC}"
    aws s3 mb "s3://$BUCKET_NAME" --region $REGION
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Bucket created successfully${NC}"
    else
        echo -e "${RED}❌ Failed to create bucket${NC}"
        exit 1
    fi
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

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json
rm bucket-policy.json

# Upload files to S3
echo -e "${BLUE}📤 Uploading files to S3...${NC}"
aws s3 sync . "s3://$BUCKET_NAME" \
    --delete \
    --exclude "*.md" \
    --exclude ".git/*" \
    --exclude "deploy.sh" \
    --exclude "bucket-policy.json" \
    --exclude "*.DS_Store"

# Set proper content types
echo -e "${BLUE}🏷️  Setting content types...${NC}"
aws s3 cp css/style.css "s3://$BUCKET_NAME/css/style.css" --content-type "text/css"
aws s3 cp js/script.js "s3://$BUCKET_NAME/js/script.js" --content-type "application/javascript"

# Set cache control headers
echo -e "${BLUE}⏰ Setting cache control headers...${NC}"
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
    aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
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
echo "4. Set up monitoring and analytics"
echo ""
echo -e "${BLUE}💡 Pro Tips:${NC}"
echo "• Use CloudFront for global CDN and HTTPS support"
echo "• Set up Route 53 for custom domain management"
echo "• Enable CloudWatch monitoring for performance insights"
echo "• Consider using AWS Certificate Manager for SSL certificates"
echo ""

# Check if website is accessible
echo -e "${BLUE}🔍 Testing website accessibility...${NC}"
if curl -s --head "$WEBSITE_URL" | head -n 1 | grep -q "200 OK"; then
    echo -e "${GREEN}✅ Website is accessible!${NC}"
else
    echo -e "${YELLOW}⚠️  Website might take a few minutes to be accessible${NC}"
fi

echo ""
echo -e "${GREEN}🏖️  Paradise Resort is now live on AWS S3!${NC}"