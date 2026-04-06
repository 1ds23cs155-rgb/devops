# 🎬 Quick Start: Rebuild & Deploy Your Image

## ⚡ 60-Second Quick Build

```bash
# Navigate to project
cd /Users/ajayreddy/Desktop/devOPS

# Build the image
docker build -f docker/Dockerfile -t devops-app:latest .

# Run the container
docker run -d -p 3000:3000 devops-app:latest

# Test it
curl http://localhost:3000/health | jq .

# View logs
docker logs -f devops-app
```

---

## 📝 Rebuild With Code Changes

### Step 1: Make a Code Change

```bash
# Open the server file
vim app/server-enhanced.js

# Find this section (around line 45-50):
app.get('/', (req, res) => {
  res.json({
    message: 'DevOps Application',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

# Change message to:
app.get('/', (req, res) => {
  res.json({
    message: 'DevOps Application - Updated Version',
    version: '1.0.1',
    timestamp: new Date().toISOString()
  });
});

# Save and exit (Vim: Esc, :wq, Enter)
```

### Step 2: Rebuild Image

```bash
# Rebuild with new tag
docker build -f docker/Dockerfile -t devops-app:v1.0.1 .

# View build progress:
# Step 1/15 : FROM node:18-alpine AS builder
# Step 2/15 : WORKDIR /app
# ...
# Successfully tagged devops-app:v1.0.1
```

### Step 3: Run New Version

```bash
# Stop old container
docker stop $(docker ps -q --filter "ancestor=devops-app:latest")

# Run new container
docker run -d -p 3000:3000 --name app-v1 devops-app:v1.0.1

# Test new version
curl http://localhost:3000 | jq .
# {
#   "message": "DevOps Application - Updated Version",
#   "version": "1.0.1",
#   "timestamp": "2024-01-15T10:30:00.000Z"
# }
```

### Step 4: Tag as Latest

```bash
# Tag v1.0.1 as latest
docker tag devops-app:v1.0.1 devops-app:latest

# Now both point to same image
docker images devops-app

# OUTPUT:
# REPOSITORY  TAG       IMAGE ID      SIZE
# devops-app  latest    abc123def456  45.6MB
# devops-app  v1.0.1    abc123def456  45.6MB
```

---

## 🔄 Using Docker Compose to Rebuild

### Method 1: Rebuild and Restart

```bash
# Rebuild image and start services
docker-compose up -d --build

# Check status
docker-compose ps

# Follow logs
docker-compose logs -f app
```

### Method 2: Rebuild Specific Service

```bash
# Rebuild only 'app' service
docker-compose build app

# Restart only app service
docker-compose up -d app
```

### Method 3: Force Rebuild (No Cache)

```bash
# Rebuild from scratch
docker-compose build --no-cache app

# Useful when:
# - Package versions changed
# - npm registry was inconsistent
# - You want fresh OS/dependency updates
```

---

## 📊 Compare Image Versions

### View Your Built Images

```bash
# List all images
docker images devops-app

# OUTPUT:
# REPOSITORY  TAG       IMAGE ID      CREATED       SIZE
# devops-app  latest    abc123def456  2 minutes ago  45.6MB
# devops-app  v1.0.1    abc123def456  2 minutes ago  45.6MB
# devops-app  v1.0.0    xyz789abc123  15 min ago     45.6MB
# devops-app  dev       old456xyz789  1 hour ago     45.6MB
```

### Compare Layers

```bash
# View layers in v1.0.0
docker history devops-app:v1.0.0

# OUTPUT:
# IMAGE         CREATED        CREATED BY                           SIZE
# xyz789abc123  15 min ago     /bin/sh -c #(nop) CMD ["node"...    0B
# old456xyz789  15 min ago     /bin/sh -c chmod +x entry.sh        1.23kB
# ...
```

### View Detailed Info

```bash
# Full JSON details
docker inspect devops-app:latest

# Just the config
docker inspect devops-app:latest --format='{{json .Config}}' | jq .

# Just the environment
docker inspect devops-app:latest --format='{{range .Config.Env}}{{.}}{{println}}{{end}}'
```

---

## 🔄 Rollback to Previous Version

### Scenario: New Version Has a Bug

```bash
# Current broken version
docker run -d -p 3000:3000 devops-app:v1.0.1

# Test - oh no, broken!
curl http://localhost:3000
# {"error": "Something went wrong"}

# Quick rollback
docker stop $(docker ps -q)
docker run -d -p 3000:3000 devops-app:v1.0.0

# Test - working again!
curl http://localhost:3000
# {"message": "DevOps Application", "version": "1.0.0"}
```

### Rollback in Docker Compose

```bash
# Revert to previous version
vim docker-compose.yml
# Change:
# image: devops-app:v1.0.0  (old)
# To:
# image: devops-app:v1.0.0  (old)

# Restart
docker-compose up -d
```

---

## 🚀 Scale Your Application

### Run Multiple Copies

```bash
# Run 3 copies of app
docker run -d -p 3000:3000 devops-app:latest
docker run -d -p 3001:3000 devops-app:latest
docker run -d -p 3002:3000 devops-app:latest

# Now you have load distribution:
# Port 3000 → Container 1
# Port 3001 → Container 2
# Port 3002 → Container 3

# Use Nginx to load balance (already in docker-compose)
docker-compose up -d
# Nginx on port 80 will distribute traffic

# Test load balancing
for i in {1..10}; do curl http://localhost | jq '.container'; done
# Will show requests going to different containers
```

### Scale with Docker Compose

```bash
# Scale app service to 3 instances
docker-compose up -d --scale app=3

# Check status
docker-compose ps

# OUTPUT:
# NAME              SERVICE  UP
# devops-app_app_1  app      Up
# devops-app_app_2  app      Up
# devops-app_app_3  app      Up
```

---

## 📦 Save & Share Your Image

### Export to File

```bash
# Save exact image snapshot
docker save devops-app:latest -o devops-app-latest.tar

# Compressed version (smaller)
docker save devops-app:latest | gzip > devops-app-latest.tar.gz

# Size comparison
ls -lh devops-app-latest*
# -rw-r--r--  185M devops-app-latest.tar
# -rw-r--r--   45M devops-app-latest.tar.gz
```

### Load on Another Machine

```bash
# On new machine:
docker load < devops-app-latest.tar

# Verify
docker images devops-app
# Will see devops-app:latest

# Run it
docker run -d -p 3000:3000 devops-app:latest
```

### Push to Docker Hub

```bash
# Create account on hub.docker.com

# Login
docker login

# Tag with your username
docker tag devops-app:latest your-username/devops-app:latest

# Push
docker push your-username/devops-app:latest

# Anyone in the world can now run it:
# docker run your-username/devops-app:latest

# And pull updates:
# docker pull your-username/devops-app:latest
```

---

## 🔍 Debug Your Image Build

### See What's Inside

```bash
# Create container (don't run it)
docker create devops-app:latest

# Connect to shell
docker run -it devops-app:latest /bin/sh

# Inside container, explore:
$ ls -la                        # See files
$ npm ls                        # See npm packages
$ node -v && npm -v             # Check versions
$ cat /etc/os-release           # See OS
$ whoami                        # See user (nodejs)
$ cat /etc/passwd               # See all users
$ exit                          # Exit
```

### Inspect Intermediate Layers

```bash
# During build, if it fails, note the image ID
# docker build -f docker/Dockerfile ...
# Step 5/15 : RUN npm ci --omit=dev
#  ---> Running in 12345abcdef
# (Container 12345abcdef will be saved if it errors)

# Jump into that layer
docker run -it 12345abcdef /bin/sh

# Manually run the next step to debug
# This helps find where build fails
```

---

## ✅ Pre-Deployment Checklist

```bash
# 1. Build succeeds
docker build -f docker/Dockerfile -t devops-app:latest .
# ✓ Built successfully

# 2. Image runs
docker run -d devops-app:latest
# ✓ Container started

# 3. Health checks pass
curl http://localhost:3000/health
# ✓ Responds with healthy status

# 4. API works
curl http://localhost:3000
# ✓ Returns expected JSON

# 5. No vulnerabilities
docker scan devops-app:latest
# ✓ No critical CVEs

# 6. Size is reasonable
docker images devops-app
# ✓ Size < 500MB (ours is 45.6MB)

# 7. Version is tagged
docker tag devops-app:latest devops-app:1.0.0
docker images devops-app
# ✓ Multiple tags for version tracking

# 8. docker-compose.yml valid
docker-compose config
# ✓ No YAML errors

# 9. All services start
docker-compose up -d
docker-compose ps
# ✓ All services healthy

# 10. Cleanup test containers
docker container prune -f
# ✓ Old containers removed
```

---

## 🎯 Common Workflows

### Workflow 1: Daily Development

```bash
# 1. Edit code
vim app/server-enhanced.js

# 2. Rebuild for testing
docker build -f docker/Dockerfile -t devops-app:dev .

# 3. Run locally
docker run -p 3000:3000 devops-app:dev

# 4. Test
curl http://localhost:3000

# 5. Use docker-compose for full stack
docker-compose up -d --build
docker-compose logs -f
```

### Workflow 2: Feature Branch

```bash
# 1. Create feature branch
git checkout -b feature/auth

# 2. Make changes
vim app/server-enhanced.js

# 3. Build feature image
docker build -t devops-app:feature-auth .

# 4. Test feature
docker run -p 3000:3000 devops-app:feature-auth

# 5. Push for review
docker tag devops-app:feature-auth ghcr.io/user/devops-app:feature-auth
docker push ghcr.io/user/devops-app:feature-auth

# 6. After merge, tag main
docker build -t devops-app:main .
docker tag devops-app:main devops-app:latest
```

### Workflow 3: Production Release

```bash
# 1. Run tests
npm test

# 2. Build release image
docker build -t devops-app:1.0.0 .

# 3. Tag as latest
docker tag devops-app:1.0.0 devops-app:latest

# 4. Push to registry
docker tag devops-app:1.0.0 ghcr.io/user/devops-app:1.0.0
docker tag devops-app:1.0.0 ghcr.io/user/devops-app:latest
docker push ghcr.io/user/devops-app:1.0.0
docker push ghcr.io/user/devops-app:latest

# 5. Deploy
docker pull ghcr.io/user/devops-app:latest
docker run -d -p 3000:3000 ghcr.io/user/devops-app:latest
```

---

## 📈 Performance Tips

### Speed Up Builds

```bash
# ✅ Good: Only relevant files (use .dockerignore)
cat > .dockerignore << 'EOF'
node_modules
.git
.env
coverage
dist
.next
EOF

# ✅ Good: Layer ordering (stable first)
COPY package*.json ./      # Stable, rarely changes
RUN npm ci --omit=dev      # Changes if package.json changes
COPY app/ ./               # Changes frequently

# ❌ Bad: Everything at once
COPY . .
RUN npm install
```

### Reduce Image Size

```bash
# ✅ Multi-stage build (we already do this)
# Removes build tools from final image
# Result: 45.6MB instead of 200MB

# ✅ Alpine base (we already do this)
# alpine = 5.8MB vs ubuntu = 77MB

# ✅ Production deps only (we already do this)
# npm ci --omit=dev
# Removes test packages (jest, mocha, etc.)

# ✅ Chain RUN commands
RUN apt-get update && apt-get install -y curl && apt-get clean
# vs separate commands (creates larger layers)
```

---

## 🆘 Troubleshooting

### Build Fails

```bash
# See full output
docker build --progress=plain -f docker/Dockerfile .

# Common errors:
# - npm install fails: Check network, package.json syntax
# - COPY fails: Check paths are relative to Dockerfile
# - RUN fails: Test command locally first

# Debug by running intermediate layer:
docker run -it node:18-alpine /bin/sh
# Test npm install locally
npm install
```

### Container Crashes

```bash
# Check logs
docker logs <container>

# Common causes:
# - Server crashed: Check SIGTERM handling
# - Missing env vars: Set in docker-compose.yml
# - Port already in use: Use different port
# - Health check failing: Check health endpoint
```

### No Internet in Container

```bash
# Check DNS
docker run -it devops-app:latest nslookup google.com

# Check routes
docker run -it devops-app:latest netstat -rn

# Usually fixed by:
docker system prune -a    # Reset Docker
colima restart            # On macOS (if using Colima)
```

---

## ✨ Your DevOps Flow

```
1. Develop Locally
   ↓
2. Test locally with docker-compose
   ↓
3. Build image (automated by CI/CD)
   ↓
4. Push to registry (ghcr.io)
   ↓
5. Deploy to production (Kubernetes/ECS)
   ↓
6. Monitor and collect metrics
   ↓
7. If bug found: Fix code → Go to step 2
   ↓
8. If all good: Tag as release ✅
```

---

**You're ready to build, deploy, and scale! 🚀**
