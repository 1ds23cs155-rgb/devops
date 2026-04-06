# Complete Setup Guide

## Prerequisites

### Required Software
- **Docker**: [Download](https://www.docker.com/products/docker-desktop)
- **Docker Compose**: Usually included with Docker Desktop
- **Git**: [Download](https://git-scm.com)
- **Node.js** (optional, for local development): [Download](https://nodejs.org)

### Verify Installation

```bash
# Check Docker
docker --version
# Expected: Docker version 20.10+

# Check Docker Compose
docker-compose --version
# Expected: Docker Compose version 1.29+

# Check Git
git --version
# Expected: git version 2.30+
```

## Step 1: Initial Setup

### Clone or Navigate to Project

```bash
cd /Users/ajayreddy/Desktop/devOPS
```

### Create Environment File (Optional)

```bash
cat > .env << EOF
NODE_ENV=production
PORT=3000
EOF
```

## Step 2: Build and Run with Docker Compose

### Start Services

```bash
# Start in background
docker-compose up -d

# Or start with live logs
docker-compose up

# (Press Ctrl+C to stop if running in foreground)
```

### Verify Services

```bash
# List running containers
docker-compose ps

# Expected output:
# NAME          STATUS       PORTS
# devops-app    Up (healthy) 0.0.0.0:3000->3000/tcp
# devops-nginx  Up           0.0.0.0:80->80/tcp
```

### Check Application Health

```bash
# Health check endpoint
curl http://localhost:3000/health

# Expected: {"status":"healthy",...}
```

## Step 3: Access the Application

Open your browser and visit:

| URL | Purpose |
|-----|---------|
| http://localhost | Nginx proxy (recommended) |
| http://localhost:3000 | Direct app access |
| http://localhost:3000/health | Health check |
| http://localhost:3000/api/info | API information |

## Step 4: Using the Deployment Script

### Make Script Executable

```bash
chmod +x scripts/deploy.sh
```

### Run Deployment

```bash
./scripts/deploy.sh

# This will:
# 1. Stop any existing containers
# 2. Build a fresh Docker image
# 3. Start a new container
# 4. Verify application health
```

### Troubleshoot Deployment

```bash
# View deployment logs
docker logs devops-app

# Check specific errors
docker-compose logs app
```

## Step 5: Local Development (Optional)

### Setup Local Environment

```bash
# Install Node.js dependencies
cd app
npm install
cd ..
```

### Run Locally

```bash
# From the app directory
cd app
npm start

# Access at http://localhost:3000
```

### Stop Local Server

```bash
# Press Ctrl+C
```

## Managing Docker Containers

### View Logs

```bash
# Live logs for main app
docker-compose logs -f app

# View last 100 lines
docker-compose logs --tail=100 app

# View nginx logs
docker-compose logs nginx
```

### Stop Services

```bash
# Stop but keep containers
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove everything (volumes too)
docker-compose down -v
```

### Restart Services

```bash
# Restart specific service
docker-compose restart app

# Restart all services
docker-compose restart
```

### Access Container Shell

```bash
# Connect to app container
docker-compose exec app sh

# Inside container, you can run commands
# Example: curl http://localhost:3000/health
# Type 'exit' to leave

# Or for bash (also works in Alpine)
docker-compose exec app /bin/sh
```

### Rebuild Image

```bash
# Rebuild without cache
docker-compose build --no-cache

# Rebuild and restart
docker-compose up -d --build
```

## GitHub Setup (CI/CD)

### 1. Push to GitHub

```bash
# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial DevOps project setup"

# Add remote (replace with your repo)
git remote add origin https://github.com/USERNAME/devops.git

# Push to main branch
git branch -M main
git push -u origin main
```

### 2. Configure GitHub Secrets (Optional)

If using private Docker registry:

1. Go to **Repository Settings** → **Secrets and variables** → **Actions**
2. Add secrets needed for deployment

### 3. Monitor CI/CD Pipeline

1. Go to **Actions** tab in your GitHub repository
2. View workflow runs and logs
3. Check build status for each commit

## Troubleshooting

### Issue: Port 3000 Already in Use

**Solution 1**: Change port in docker-compose.yml
```yaml
ports:
  - "3001:3000"  # Use 3001 instead
```

**Solution 2**: Kill process using port
```bash
# macOS/Linux
lsof -i :3000
kill -9 <PID>

# Or stop Docker Compose
docker-compose down
```

### Issue: Docker Image Build Fails

```bash
# Clear all images and containers
docker system prune -a

# Rebuild from scratch
docker-compose build --no-cache

# Restart
docker-compose up -d
```

### Issue: Connection Refused

```bash
# Ensure all services are running
docker-compose ps

# If not running:
docker-compose up -d

# Wait a few seconds for startup
sleep 5

# Try health check
curl http://localhost:3000/health
```

### Issue: Cannot Write to Volume

```bash
# Fix permissions
sudo chown -R $(id -u):$(id -g) .

# Or rebuild volumes
docker-compose down -v
docker-compose up -d
```

### Issue: Out of Disk Space

```bash
# Clean up Docker resources
docker system prune -a --volumes

# View disk usage
docker system df
```

## Performance Optimization

### Limit CPU/Memory (Optional)

Edit `docker-compose.yml`:
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### View Resource Usage

```bash
# Real-time statistics
docker stats

# Detailed info
docker inspect devops-app
```

## Next Steps

1. ✅ Verify application is running
2. 📝 Familiarize yourself with the codebase
3. 🔧 Modify `app/server.js` for your needs
4. 📦 Push to GitHub to trigger CI/CD
5. 🚀 Configure deployment for production

## Documentation

- [README.md](../README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design
- [CI/CD Setup](.github/workflows/ci-cd.yml) - Pipeline details

---

**Need Help?**
- Check Docker documentation: https://docs.docker.com
- Review GitHub Actions docs: https://github.com/features/actions
- Ask your instructor or team lead

