# 🎯 Docker Hands-On: Building & Running Your Application

## Current Status Check

```bash
# View your built image
docker images | grep devops-app
# Output: 
# devops-app  latest  f1b70af8d522  45.6MB  Built 15 min ago

# View running containers
docker ps
# Output:
# devops-app   3000/tcp  Up 15 min  (Healthy)
# devops-nginx 80/tcp    Up 15 min
```

---

## 🏗️ Building Your Docker Image

### Method 1: Build from Dockerfile (What We Did Initially)

```bash
# Step 1: Navigate to project root
cd /Users/ajayreddy/Desktop/devOPS

# Step 2: Build the image
docker build -f docker/Dockerfile -t devops-app:latest .

# Breakdown:
# docker build                    = Build an image
# -f docker/Dockerfile            = Use this Dockerfile
# -t devops-app:latest            = Tag as "devops-app:latest"
# .                               = Build context (current directory)
```

### What Happens During Build

```
Step 1/15 : FROM node:18-alpine AS builder
 ---> 2b8fd9ab8e2b
Step 2/15 : WORKDIR /app
 ---> Using cache
 ---> abc123def456
Step 3/15 : COPY app/package*.json ./
 ---> abc123def457
Step 4/15 : RUN npm ci --omit=dev
 ---> Running in temporary container
 ---> Downloaded 68 npm packages
 ---> abc123def458
...
Step 15/15 : CMD ["node", "server.js"]
 ---> abc123def999
Successfully built f1b70af8d522
Successfully tagged devops-app:latest
```

### View Build Cache

```bash
# See how Docker cached your layers
docker history devops-app:latest

# Output:
# IMAGE         CREATED        CREATED BY                      SIZE
# f1b70af8d522  15 minutes ago /bin/sh -c #(nop) CMD ["node"… 0B
# abc123def999  15 minutes ago /bin/sh -c chmod +x entry.sh   1.23kB
# <missing>     15 minutes ago /bin/sh -c cp -r /app/node_mo… 4.6MB
# <missing>     15 minutes ago /bin/sh -c npm ci --omit=dev    15MB
# <missing>     2 weeks ago    /bin/sh -c #(nop) WORKDIR /app  0B
# 2b8fd9ab8e2b  2 weeks ago    /bin/sh -c npm ci --production  0B
```

---

## 🚀 Running Your Container

### Method 1: Simple Run (One Container)

```bash
# Run your image as a container
docker run --rm -p 3000:3000 devops-app:latest

# Breakdown:
# docker run              = Create and run a container
# --rm                    = Remove container when stopped
# -p 3000:3000           = Port mapping (host:container)
# devops-app:latest      = Which image to run

# Output:
# Server running on http://localhost:3000
# Health check endpoint: http://localhost:3000/health
# Metrics endpoint: http://localhost:3000/metrics
```

### Method 2: Run in Background (Detached)

```bash
# Run detached (don't block terminal)
docker run -d --name my-app -p 3000:3000 devops-app:latest

# View logs
docker logs my-app
docker logs -f my-app  # Follow logs (Ctrl+C to exit)

# Stop container
docker stop my-app

# Remove container
docker rm my-app
```

### Method 3: Run with Environment Variables

```bash
docker run -d \
  -p 3000:3000 \
  -e NODE_ENV=production \
  -e PORT=3000 \
  -e DEBUG=app:* \
  devops-app:latest
```

### Method 4: Run with Volume Mount (Live Development)

```bash
# Mount source code (for development)
docker run -d \
  -p 3000:3000 \
  -v /Users/ajayreddy/Desktop/devOPS/app:/app/src \
  devops-app:latest

# Changes to app/src reflect in running container (if using nodemon)
```

### Method 5: Run with Resource Limits

```bash
docker run -d \
  -p 3000:3000 \
  -m 512m \
  --cpus 0.5 \
  devops-app:latest

# -m 512m              = Max 512 MB RAM
# --cpus 0.5           = Max 0.5 CPU cores (50%)
# Useful for testing behavior under constraints
```

---

## 🐳 Docker Compose (Multiple Services)

### Start Everything

```bash
# Navigate to project
cd /Users/ajayreddy/Desktop/devOPS

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# View status
docker-compose ps

# Output:
# NAME              SERVICE    STATUS    PORTS
# devops-app        app        Up 1 min  0.0.0.0:3000->3000/tcp
# devops-postgres   postgres   Up 1 min  0.0.0.0:5432->5432/tcp
# devops-nginx      nginx      Up 1 min  0.0.0.0:80->80/tcp
```

### Check Service Health

```bash
# App health
curl http://localhost:3000/health
# {
#   "status": "healthy",
#   "timestamp": "2024-01-15T10:30:00.000Z",
#   "uptime": 45.67
# }

# Nginx health
curl -I http://localhost:80/
# HTTP/1.1 200 OK

# Database health (via psql)
docker exec devops-postgres psql -U devops_user -d devops_app -c "SELECT NOW();"
# 2024-01-15 10:30:00
```

### Stop Services

```bash
# Stop all containers (keep them)
docker-compose stop

# Stop and remove containers
docker-compose down

# Remove containers AND volumes (clean slate)
docker-compose down -v

# Stop with rebuilding
docker-compose up -d --build
```

---

## 🔄 Rebuilding Your Image

### Scenario 1: Code Changed

```bash
# 1. Edit your code
# vim app/server-enhanced.js

# 2. Rebuild image (only rebuilds changed layers)
docker build -f docker/Dockerfile -t devops-app:v2 .

# 3. Run new version
docker run -p 3000:3000 devops-app:v2

# 4. Keep old version (can rollback anytime)
# docker run -p 3000:3000 devops-app:latest
```

### Scenario 2: Dependencies Changed

```bash
# 1. Update package.json
# vim app/package.json
# Add: "lodash": "^4.17.21"

# 2. Run npm install (update package-lock.json)
npm install

# 3. Rebuild image (npm ci will use new package-lock.json)
docker build -f docker/Dockerfile -t devops-app:v2 .

# 4. Update docker-compose.yml to use v2
# vim docker-compose.yml
# Change: image: devops-app:v2

# 5. Restart services
docker-compose up -d --build
```

### Scenario 3: Base OS Updated

```bash
# Node:18-alpine got security patch
docker pull node:18-alpine

# Rebuild with fresh base image
docker build --no-cache -f docker/Dockerfile -t devops-app:v2 .
```

### Scenario 4: Full Clean Rebuild

```bash
# Remove old image
docker rmi devops-app:latest

# Remove all containers
docker container prune -f

# Rebuild fresh
docker build -f docker/Dockerfile -t devops-app:latest .

# Start fresh
docker-compose up -d
```

---

## 🔍 Debugging Inside Container

### Execute Command in Running Container

```bash
# Open shell inside container
docker exec -it devops-app /bin/sh

# Inside container shell:
$ node -v
v18.20.8

$ npm -v
9.8.1

$ ls -la
total 56
drwxrwx---  1 nodejs   root     4096 Jan 15 devops-app
lrwxrwxrwx  1 root     root       23 Jan 15 node_modules
-rw-r--r--  1 nodejs   root    2342 Jan 15 package.json
-rw-r--r--  1 nodejs   root   48567 Jan 15 package-lock.json
-rw-r--r--  1 nodejs   root     456 Jan 15 server.js
```

### View Container Details

```bash
# Inspect JSON details
docker inspect devops-app

# Filter specific info
docker inspect devops-app --format='{{json .Config.Env}}' | jq .

# Get IP address
docker inspect devops-app --format='{{.NetworkSettings.IPAddress}}'
# Output: 172.19.0.2

# Get resource limits
docker inspect devops-app --format='{{.HostConfig.Memory}}'
# Output: 0 (no limit)
```

### View Logs

```bash
# Last 100 lines
docker logs --tail 100 devops-app

# With timestamps
docker logs -t devops-app

# Follow live
docker logs -f devops-app

# Filter by time
docker logs --since 5m devops-app

# View timestamp of specific line
docker logs devops-app 2>&1 | grep "Some error"
```

### Resource Monitoring

```bash
# Real-time stats
docker stats devops-app

# Output:
# CONTAINER  CPU %   MEM USAGE / LIMIT   MEM %   NET I/O     BLOCK I/O
# devops-app 0.15%   45.2MiB / 1.944GiB  2.33%   2.3kB / 1.2kB

# Memory only
docker stats --no-stream devops-app --format "table {{.MemUsage}}"
```

---

## 🎯 Common Issues & Solutions

### Issue 1: "Cannot connect to port 3000"

```bash
# Check if container is running
docker ps

# If not running, check why
docker logs devops-app

# If error in logs starting container
docker run -it devops-app:latest /bin/sh
# -it = interactive terminal to see real-time errors

# Check if port is already in use
lsof -i :3000
# Kill process: kill -9 <PID>

# Try different port
docker run -p 3001:3000 devops-app:latest
# Access: http://localhost:3001
```

### Issue 2: "Image build failed"

```bash
# View full build output
docker build -f docker/Dockerfile --progress=plain -t devops-app:latest .

# Common causes:
# 1. npm ci failed → Check network/package.json
# 2. COPY failed → Check paths in Dockerfile
# 3. RUN failed → Debug in shell

# Debug with intermediate image
docker run -it 2b8fd9ab8e2b /bin/sh  # From layer ID
# Manually run each layer step
```

### Issue 3: "Permissions denied"

```bash
# Container runs as non-root user (nodejs)
# If you need root:
docker exec -u root devops-app apt-get install curl

# Or run container as root (not recommended for production)
docker run --user root devops-app:latest
```

### Issue 4: "Out of disk space"

```bash
# Check Docker disk usage
docker system df

# Clean up
docker system prune -a --volumes
# -a                = Remove all unused images
# --volumes         = Remove unused volumes
# CAUTION: Irreversible!

# Remove specific images
docker rmi devops-app:v1 devops-app:v2

# Remove dangling images
docker image prune -f
```

---

## 📦 Tagging & Versioning

### Version Your Images

```bash
# Development build
docker build -t devops-app:dev .

# Feature branch
docker build -t devops-app:feature/auth .

# Release
docker build -t devops-app:1.0.0 .

# Latest (points to current production)
docker tag devops-app:1.0.0 devops-app:latest
```

### Push to Registry

```bash
# Tag for registry
docker tag devops-app:latest ghcr.io/yourusername/devops-app:latest

# Login
docker login ghcr.io

# Push
docker push ghcr.io/yourusername/devops-app:latest

# Pull from another machine
docker pull ghcr.io/yourusername/devops-app:latest
```

---

## 📊 Performance Optimization

### Check Image Size

```bash
# Total size
docker images devops-app

# Breakdown by layer
docker history devops-app:latest

# Save image to file (check compressed size)
docker save devops-app:latest | gzip | wc -c
# If > 1 GB, optimize
```

### Optimize Dockerfile

```dockerfile
# ❌ BAD: 150 MB image
FROM node:18
RUN apt-get update && apt-get install -y python3
COPY . .
RUN npm install

# ✅ GOOD: 45.6 MB image
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
USER nodejs
CMD ["node", "server.js"]
```

---

## 🤝 Sharing Your Image

### Save to File

```bash
# Export image
docker save devops-app:latest -o devops-app.tar

# On another machine:
docker load -i devops-app.tar

# Compression
docker save devops-app:latest | gzip > devops-app.tar.gz
docker load < devops-app.tar.gz
```

### Push to Docker Hub

```bash
# Create account on hub.docker.com

# Login
docker login

# Tag
docker tag devops-app:latest yourname/devops-app:latest

# Push
docker push yourname/devops-app:latest

# Anyone can now run
docker run yourname/devops-app:latest
```

---

## ✅ Checklist: Before Production

```
☐ Image builds without errors
  docker build -t devops-app:latest .

☐ Container starts without errors
  docker run -d devops-app:latest

☐ Health endpoint responds
  curl http://localhost:3000/health

☐ Dependencies are correct
  docker run devops-app:latest npm ls

☐ Non-root user running app
  docker exec <container> whoami  # Should be nodejs

☐ Image is scanned for vulnerabilities
  docker scan devops-app:latest

☐ Image size is reasonable
  docker images devops-app  # Should be < 500MB

☐ All environment variables configured
  docker inspect <container> | jq .[0].Config.Env

☐ Resource limits set (if needed)
  docker run -m 512m --cpus 0.5 ...

☐ Health checks configured
  docker inspect <container> | jq .[0].Config.Healthcheck

☐ Logs are readable
  docker logs <container>

☐ docker-compose.yml synced
  docker-compose config  # Validate YAML
```

---

## 🎓 Learning Resources

```
Docker Concepts:
- Image: Read-only template (like a blueprint)
- Container: Running instance of image (like a house built from blueprint)
- Layer: Step in Dockerfile (cached for speed)
- Registry: Repository of images (Docker Hub, GitHub Container Registry)
- Volume: Persistent storage (survives container removal)
- Network: Communication between containers

Commands to Practice:
1. docker build -t image-name .
2. docker run -p port image-name
3. docker ps / docker ps -a
4. docker logs container-id
5. docker exec -it container-id /bin/sh
6. docker-compose up -d
7. docker-compose logs -f
8. docker stats
9. docker inspect container-id
10. docker rmi image-name
```

---

## 🚀 Next Steps

1. **Modify code and rebuild**
   ```bash
   # Edit app/server-enhanced.js
   docker build -t devops-app:v2 .
   docker run -p 3000:3000 devops-app:v2
   ```

2. **Add more services to docker-compose**
   ```yaml
   redis:
     image: redis:7-alpine
     ports:
       - "6379:6379"
   ```

3. **Push to registry for deployment**
   ```bash
   docker push ghcr.io/user/devops-app:latest
   ```

4. **Deploy to production**
   ```bash
   # Using Kubernetes
   kubectl create deployment devops-app \
     --image=ghcr.io/user/devops-app:latest
   ```

---

**Your application is ready for production deployment! 🎉**
