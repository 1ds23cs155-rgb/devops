#!/bin/bash

# DevOps Project Setup Script

set -e

echo "📦 Setting up DevOps Project..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Install dependencies
echo -e "${YELLOW}Installing Node.js dependencies...${NC}"
cd app
npm install
cd ..

echo -e "${GREEN}✓ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Build and run with Docker Compose: docker-compose up -d"
echo "2. Or run locally: cd app && npm start"
echo "3. Access the app at http://localhost:3000"
echo ""
echo "For more information, see README.md"
