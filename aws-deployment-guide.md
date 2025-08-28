# AWS S3 Static Website Deployment Guide

## Overview
This guide will help you deploy your Paradise Resort booking website to AWS S3 as a static website with CloudFront CDN for optimal performance.

## Prerequisites
- AWS Account
- AWS CLI installed and configured
- Domain name (optional, for custom domain)

## Step 1: Create S3 Bucket

### Using AWS Console:
1. Go to AWS S3 Console
2. Click "Create bucket"
3. Choose a unique bucket name (e.g., `paradise-resort-website`)
4. Select your preferred region
5. Uncheck "Block all public access"
6. Acknowledge the warning about public access
7. Click "Create bucket"

### Using AWS CLI:
```bash
# Create bucket
aws s3 mb s3://paradise-resort-website --region us-east-1

# Configure bucket for static website hosting
aws s3 website s3://paradise-resort-website --index-document index.html --error-document error.html
```

## Step 2: Configure Bucket for Static Website Hosting

### Using AWS Console:
1. Select your bucket
2. Go to "Properties" tab
3. Scroll to "Static website hosting"
4. Click "Edit"
5. Enable static website hosting
6. Set index document: `index.html`
7. Set error document: `error.html` (optional)
8. Save changes

## Step 3: Set Bucket Policy for Public Access

Add this bucket policy to allow public read access:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::paradise-resort-website/*"
        }
    ]
}
```

### Using AWS Console:
1. Go to "Permissions" tab
2. Click "Bucket Policy"
3. Paste the policy above (replace bucket name)
4. Save changes

## Step 4: Upload Website Files

### Using AWS Console:
1. Go to "Objects" tab
2. Click "Upload"
3. Add all your website files:
   - `index.html`
   - `css/style.css`
   - `js/script.js`
   - Any additional assets
4. Click "Upload"

### Using AWS CLI:
```bash
# Upload all files
aws s3 sync . s3://paradise-resort-website --exclude "*.md" --exclude ".git/*"

# Set proper content types
aws s3 cp css/style.css s3://paradise-resort-website/css/style.css --content-type "text/css"
aws s3 cp js/script.js s3://paradise-resort-website/js/script.js --content-type "application/javascript"
```

## Step 5: Test Your Website

Your website will be available at:
`http://paradise-resort-website.s3-website-us-east-1.amazonaws.com`

Replace `paradise-resort-website` with your bucket name and `us-east-1` with your region.

## Step 6: Set Up CloudFront CDN (Recommended)

### Benefits:
- Global content delivery
- HTTPS support
- Better performance
- Custom domain support

### Setup:
1. Go to CloudFront Console
2. Click "Create Distribution"
3. Configure:
   - Origin Domain: Your S3 website endpoint
   - Viewer Protocol Policy: Redirect HTTP to HTTPS
   - Allowed HTTP Methods: GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
   - Cache Policy: Managed-CachingOptimized
4. Create distribution
5. Wait for deployment (15-20 minutes)

## Step 7: Custom Domain (Optional)

### Requirements:
- Domain registered in Route 53 or external registrar
- SSL certificate from AWS Certificate Manager

### Steps:
1. Request SSL certificate in Certificate Manager
2. Add custom domain to CloudFront distribution
3. Update DNS records to point to CloudFront

## Step 8: Automated Deployment Script

Create `deploy.sh` for easy deployment:

```bash
#!/bin/bash

BUCKET_NAME="paradise-resort-website"
DISTRIBUTION_ID="YOUR_CLOUDFRONT_DISTRIBUTION_ID"

echo "Deploying to S3..."
aws s3 sync . s3://$BUCKET_NAME --delete --exclude "*.md" --exclude ".git/*" --exclude "deploy.sh"

echo "Setting content types..."
aws s3 cp css/style.css s3://$BUCKET_NAME/css/style.css --content-type "text/css"
aws s3 cp js/script.js s3://$BUCKET_NAME/js/script.js --content-type "application/javascript"

echo "Invalidating CloudFront cache..."
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"

echo "Deployment complete!"
echo "Website URL: https://your-domain.com"
```

Make it executable:
```bash
chmod +x deploy.sh
```

## Step 9: Environment-Specific Configurations

### Production Optimizations:
1. **Compress files**: Enable gzip compression in CloudFront
2. **Cache headers**: Set appropriate cache headers for static assets
3. **Security headers**: Add security headers via CloudFront functions
4. **Monitoring**: Set up CloudWatch monitoring

### Security Best Practices:
1. Use HTTPS only
2. Implement Content Security Policy
3. Add security headers
4. Regular security audits

## Step 10: Monitoring and Analytics

### CloudWatch Metrics:
- Monitor S3 requests
- Track CloudFront performance
- Set up alarms for errors

### Google Analytics:
Add Google Analytics to track website usage:

```html
<!-- Add to <head> section of index.html -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## Costs Estimation

### S3 Costs:
- Storage: ~$0.023 per GB/month
- Requests: ~$0.0004 per 1,000 requests

### CloudFront Costs:
- Data transfer: ~$0.085 per GB (first 10TB)
- Requests: ~$0.0075 per 10,000 requests

### Estimated Monthly Cost:
For a typical resort website: **$5-20/month**

## Troubleshooting

### Common Issues:
1. **403 Forbidden**: Check bucket policy and public access settings
2. **404 Not Found**: Verify file paths and index document setting
3. **CSS/JS not loading**: Check content-type headers
4. **CloudFront not updating**: Create cache invalidation

### Debug Commands:
```bash
# Check bucket policy
aws s3api get-bucket-policy --bucket paradise-resort-website

# List bucket contents
aws s3 ls s3://paradise-resort-website --recursive

# Check website configuration
aws s3api get-bucket-website --bucket paradise-resort-website
```

## Maintenance

### Regular Tasks:
1. Update website content
2. Monitor performance metrics
3. Review security settings
4. Update SSL certificates (auto-renewal with ACM)
5. Backup website files

### Updates:
```bash
# Quick update
./deploy.sh

# Manual sync
aws s3 sync . s3://paradise-resort-website --delete
```

## Support

For issues or questions:
1. Check AWS documentation
2. Review CloudWatch logs
3. Contact AWS support
4. Community forums

---

**Your Paradise Resort website is now live on AWS S3 with global CDN delivery!**