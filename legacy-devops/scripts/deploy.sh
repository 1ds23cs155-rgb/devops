#!/bin/bash

# DevOps Deployment Script
# This script handles building and deploying the application

set -e  # Exit on error

echo "🚀 Starting DevOps Deployment Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variables
APP_NAME="devops-app"
DOCKER_IMAGE="devops-app:latest"
CONTAINER_PORT="3000"
HOST_PORT="${PORT:-3000}"

# Function to print colored output
print_status() {
  echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
  echo -e "${RED}[✗]${NC} $1"
}

print_info() {
  echo -e "${YELLOW}[i]${NC} $1"
}

# Check Docker installation
if ! command -v docker &> /dev/null; then
  print_error "Docker is not installed. Please install Docker first."
  exit 1
fi

print_status "Docker is installed"

# Stop existing container
print_info "Stopping existing container..."
docker stop $APP_NAME 2>/dev/null || true
docker rm $APP_NAME 2>/dev/null || true

# Build Docker image
print_info "Building Docker image: $DOCKER_IMAGE"
docker build -f docker/Dockerfile -t $DOCKER_IMAGE .

if [ $? -eq 0 ]; then
  print_status "Docker image built successfully"
else
  print_error "Failed to build Docker image"
  exit 1
fi

# Run container
print_info "Starting container..."
docker run -d \
  --name $APP_NAME \
  -p $HOST_PORT:$CONTAINER_PORT \
  -e NODE_ENV=production \
  --restart unless-stopped \
  $DOCKER_IMAGE

if [ $? -eq 0 ]; then
  print_status "Container started successfully"
else
  print_error "Failed to start container"
  exit 1
fi

# Wait for container to be healthy
print_info "Waiting for container to be healthy..."
sleep 5

# Check health
if curl -f http://localhost:$HOST_PORT/health > /dev/null 2>&1; then
  print_status "Application is healthy!"
  echo ""
  echo -e "${GREEN}=== Deployment Successful ===${NC}"
  echo "Application URL: http://localhost:$HOST_PORT"
  echo "Health Check: http://localhost:$HOST_PORT/health"
else
  print_error "Application health check failed"
  docker logs $APP_NAME
  exit 1
fi
