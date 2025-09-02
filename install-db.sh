#!/bin/bash

# Install Node.js and database dependencies on Ubuntu EC2

echo "🗄️  Installing Database Backend..."

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install dependencies
npm install

# Start server
echo "✅ Installation complete!"
echo "🚀 Starting server..."
npm start