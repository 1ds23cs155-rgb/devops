# Local Development Guide

Quick start guide for developing and testing your tourism website locally.

## 🚀 Quick Start (5 Minutes)

### 1. Prerequisites Check
```bash
# Check Docker
docker --version
# Docker version 20.10+

# Check Docker Compose
docker-compose --version
# Docker Compose version 1.29+

# If not installed, get Docker Desktop: https://www.docker.com/products/docker-desktop
```

### 2. Navigate to Project
```bash
cd /Users/ajayreddy/Desktop/tourism-devops
```

### 3. Start Services
```bash
# Build and start
docker-compose up -d

# Watch startup
docker-compose logs -f
```

### 4. Access Website
```bash
# Open in browser
open http://localhost

# Or use curl
curl http://localhost
```

### 5. View Status
```bash
# See all running services
docker-compose ps
```

## 📝 Making Changes

### Edit Website Content

#### Method 1: Direct File Editing
```bash
# Edit HTML files directly
vim website/about.html
vim website/destination.html

# Changes are immediately reflected!
# (No rebuild needed - Nginx serves from mounted volume)

# Test in browser
open http://localhost/about.html
```

#### Method 2: Live Reload (Optional)
```bash
# Install live-reload (Node.js required)
npm install -g live-reload

# In one terminal, start live-reload
live-reload website/

# Update your HTML and see changes instantly
```

### Add New Pages
```bash
# Create new HTML file
cat > website/new-page.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>New Page</title>
</head>
<body>
    <h1>New Page</h1>
</body>
</html>
EOF

# Instantly available at:
# http://localhost/new-page.html
```

### Update CSS/Images
```bash
# Add CSS file
cp styles/custom.css website/

# Add images
cp images/tourism.jpg website/

# Update HTML to reference
vim website/index.html
# Add: <link rel="stylesheet" href="custom.css">
# Add: <img src="tourism.jpg" alt="Tourism">

# Changes appear immediately
```

## 🧪 Testing

### Manual Testing
```bash
# Test different pages
curl http://localhost/about.html
curl http://localhost/destination.html

# Test with verbose output
curl -v http://localhost

# Check response headers
curl -I http://localhost

# Test specific path
curl http://localhost/paths/to/resource

# Test health check
curl http://localhost/health
# Should return OK
```

### Performance Testing
```bash
# Using Apache Bench (built-in on macOS)
ab -n 100 -c 10 http://localhost/

# Using hey (install if needed)
brew install hey
hey -n 100 -c 10 http://localhost/

# View response time statistics
# This simulates 100 requests with 10 concurrent clients
```

### Load Testing
```bash
# Scale to 5 instances
docker-compose up -d --scale website=5

# Run performance test
ab -n 1000 -c 50 http://localhost/

# Kill scaled instances
docker-compose down
docker-compose up -d
```

## 🔍 Debugging

### View Container Logs
```bash
# All services
docker-compose logs

# Specific service
docker-compose logs website
docker-compose logs nginx

# Follow logs (live)
docker-compose logs -f website

# Last 50 lines
docker-compose logs --tail=50 website

# Timestamps
docker-compose logs -t website
```

### Check Container Status
```bash
# View all containers
docker-compose ps

# Detailed stats
docker stats

# Inspect specific container
docker inspect tourism-nginx

# Check port mappings
docker ps --format "table {{.Ports}}\t{{.Names}}"
```

### Access Container Shell
```bash
# Shell into website container
docker-compose exec website sh

# Inside container:
# ls /usr/share/nginx/html     # View served files
# cat /etc/nginx/nginx.conf    # View Nginx config

# Exit
exit

# Shell into Nginx container
docker-compose exec nginx sh
```

### Verify Nginx Configuration
```bash
# Test Nginx config
docker-compose exec nginx nginx -t

# Reload Nginx (apply changes)
docker-compose exec nginx nginx -s reload

# View Nginx version
docker-compose exec nginx nginx -v
```

### Monitor Running Services
```bash
# Real-time resource usage
docker stats

# View processes in container
docker-compose exec website ps aux

# Monitor port usage
lsof -i :80
lsof -i :9090

# Check network connectivity
docker-compose exec website ping nginx
docker-compose exec nginx ping website
```

## 🐛 Common Development Issues

### Issue: Website not responding at http://localhost
```bash
# Check if services are running
docker-compose ps

# Restart services
docker-compose restart

# View logs
docker-compose logs nginx

# Try a different port (if 80 in use)
# Edit docker-compose.yml:
# ports:
#   - "8080:80"
# Then use: http://localhost:8080
```

### Issue: Changes to HTML files not appearing
```bash
# Nginx caches responses
# Force browser refresh:
# Chrome: Cmd + Shift + R
# Firefox: Ctrl + Shift + R

# Clear browser cache completely
# Chrome: Settings → Privacy → Clear browsing data

# If still not working, restart Nginx
docker-compose restart nginx
```

### Issue: Port 80 already in use
```bash
# Find what's using port 80
lsof -i :80

# Stop the other service
# Examples:
sudo killall httpd        # Apache
sudo killall nginx        # Nginx
kill -9 <PID>            # Generic

# Or change port in docker-compose.yml
# from: "80:80"
# to:   "8080:80"
```

### Issue: High CPU/Memory usage
```bash
# Check which container is using resources
docker stats

# If website containers consuming too much:
# - Reduce number of replicas
docker-compose up -d --scale website=1

# - Restart to clear memory
docker-compose restart website

# If Prometheus using too much:
# - Disable Prometheus (edit docker-compose.yml)
# - Or increase memory: `mem_limit: 1GB`
```

### Issue: Cannot connect to internet from container
```bash
# Check DNS resolution
docker-compose exec website nslookup google.com

# Check outside connectivity
docker-compose exec website ping google.com

# View network
docker network ls
docker network inspect tourism-network

# Restart network
docker-compose down
docker-compose up -d
```

## 🔄 Development Workflow

### Typical Day Workflow
```bash
# 1. Start work
docker-compose up -d

# 2. Edit website files
vim website/about.html

# 3. Test in browser
open http://localhost/about.html

# 4. View logs for errors
docker-compose logs -f nginx

# 5. Iterate and test

# 6. When satisfied, scale and stress test
docker-compose up -d --scale website=3
ab -n 100 -c 10 http://localhost/

# 7. End of day
docker-compose down
```

### Testing Before Deployment
```bash
# Checklist before deploying to AWS/K8s

# 1. Ensure all pages load
for page in about.html destination.html experience.html; do
    echo "Testing $page..."
    curl -s http://localhost/$page | grep -q "$page" && echo "✓" || echo "✗"
done

# 2. Check performance
ab -n 100 -c 10 http://localhost/

# 3. Scale and test
docker-compose up -d --scale website=5
docker-compose logs

# 4. Verify health endpoint
curl http://localhost/health

# 5. Check images and CSS load
curl -I http://localhost/styles.css
curl -I http://localhost/images/logo.png

# 6. Everything working? Ready to deploy!
docker-compose down
git add .
git commit -m "Tourism website updates"
git push
```

## 📚 Development Tips

### Use Docker Volumes for Live Editing
```bash
# Currently docker-compose.yml has:
volumes:
  - ./website:/usr/share/nginx/html

# This allows live editing without rebuild
# Edit file → Browser refresh → See changes
```

### Disable Compression for Debugging
```bash
# Edit nginx.conf, comment out:
# gzip on;

# Then reload:
docker-compose exec nginx nginx -s reload

# Response bodies now readable:
curl http://localhost | cat
```

### Add Custom Headers for Testing
```bash
# Edit nginx.conf to add:
add_header X-Debug "tourism-website";

# Then check:
curl -I http://localhost/
# See: X-Debug: tourism-website
```

### Monitor Database Queries (Future)
```bash
# If database is added later:
# - Use docker-compose logs for query logs
# - Query profiling in server logs
```

### Use Environment Variables
```bash
# In docker-compose.yml:
environment:
  - LOG_LEVEL=debug
  - CACHE_DISABLED=true

# Inside container:
echo $LOG_LEVEL
```

## 🚢 Deployment Readiness Checklist

Before deploying to production:

- [ ] All HTML files render correctly
- [ ] All links work (test with crawler)
- [ ] Responsive on mobile (test in browser devtools)
- [ ] Images load properly
- [ ] CSS/styling loads correctly
- [ ] No JavaScript errors (check browser console)
- [ ] Health endpoint responds (/health)
- [ ] Performance acceptable under load
- [ ] No sensitive data in HTML files
- [ ] Security headers present
- [ ] Cache headers set correctly

## 📖 Next Steps

### Ready for more extensive testing?
See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for AWS/K8s deployment testing

### Want to understand the architecture better?
See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed system design

### Need to scale or optimize?
1. Edit docker-compose.yml to scale instances: `--scale website=N`
2. Load test with `ab` or `hey`
3. Monitor with Prometheus at http://localhost:9090

### Ready to deploy to production?
```bash
# Push to GitHub
git push origin main

# GitHub Actions automatically:
# - Builds Docker image
# - Scans for vulnerabilities  
# - Deploys to AWS or Kubernetes
```

---

**Happy developing! 🚀**

Questions? Check [README.md](README.md) or [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
