# 🚀 Scaling Quick Reference - Commands & Examples

## Current Setup
```bash
✅ 3 App Instances (devops-app-1, devops-app-2, devops-app-3)
✅ Nginx Load Balancer (port 80)
✅ PostgreSQL Database (shared by all)
✅ Prometheus Monitoring (port 9090)

Access Points:
  • Apps: http://localhost/ (via Nginx load balancer)
  • Database: localhost:5432
  • Monitoring: http://localhost:9090
  • API Docs: http://localhost/api/docs
  • Health: http://localhost/health
```

---

## 📋 Essential Commands

### View Instances
```bash
# List all running services
docker-compose ps

# List only app instances
docker-compose ps app

# Show detailed info for one instance
docker inspect devops-app-1
```

### Check Logs
```bash
# All app instances combined
docker-compose logs -f app

# Follow all services
docker-compose logs -f

# Single instance
docker logs -f devops-app-1

# Last 100 lines
docker logs --tail 100 devops-app-1

# With timestamps
docker logs -t devops-app-1
```

### Monitor Resources
```bash
# Real-time stats
docker stats

# Just app instances
docker stats devops-app-1 devops-app-2 devops-app-3

# One-time snapshot
docker stats --no-stream

# Get specific metric
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Test Endpoints
```bash
# Health check (through load balancer)
curl http://localhost/health

# API info
curl http://localhost/api/info

# API documentation
curl -s http://localhost/api/docs | head -20

# Direct test with response time
time curl -o /dev/null -s http://localhost/
```

### Execute Commands in Container
```bash
# Open shell in app-1
docker exec -it devops-app-1 /bin/sh

# Run command in app-1
docker exec devops-app-1 npm list

# Check versions
docker exec devops-app-1 node -v
docker exec devops-app-1 npm -v

# Inside shell, you can:
cd /app
ls -la
node -e "console.log('Hello')"
exit
```

---

## 🔄 Scaling Operations

### Scale Up (Add More Instances)
```bash
# Scale to 5 instances
docker-compose up -d --scale app=5

# Scale to 10 instances
docker-compose up -d --scale app=10

# No downtime! New instances added while old ones run.
```

### Scale Down (Remove Instances)
```bash
# Scale from 10 to 3 instances
docker-compose up -d --scale app=3

# Scale to 1 instance
docker-compose up -d --scale app=1

# Graceful shutdown of extra instances
```

### Restart All Instances
```bash
# Restart app service (all instances)
docker-compose restart app

# Force restart (kill + start)
docker-compose restart -t 0 app
```

### Restart Individual Instance
```bash
# Restart specific instance
docker restart devops-app-1

# Stop specific instance
docker stop devops-app-1

# Start specific instance
docker start devops-app-1
```

---

## 🧪 Load Balancing Tests

### Simple Round-Robin Test
```bash
# Send 9 requests
for i in {1..9}; do
  echo "Request $i:"
  curl -s http://localhost/ | jq '.uptime'
  sleep 0.2
done

# Each instance should handle ~3 requests
```

### Concurrent Load Test (if you have `ab` installed)
```bash
# 100 requests with 10 concurrent connections
ab -n 100 -c 10 http://localhost/

# 1000 requests with 50 concurrent
ab -n 1000 -c 50 http://localhost/

# Output shows:
# - Requests per second
# - Failed requests
# - Response times (min, max, mean)
```

### Sustained Load Test
```bash
# Keep sending requests for 30 seconds
for i in {1..300}; do 
  curl -s http://localhost/ > /dev/null 2>&1 &
  sleep 0.1
done

# In another terminal:
docker stats devops-app-1 devops-app-2 devops-app-3
# Watch CPU/memory increase then stabilize
```

### Latency Test
```bash
# Measure response time
time curl -s http://localhost/ > /dev/null

# Average of 10 requests
for i in {1..10}; do time curl -s http://localhost/ > /dev/null 2>&1; done
```

---

## 🚨 Failure Scenarios

### Simulate Instance Failure
```bash
# Stop one instance
docker stop devops-app-1

# Try accessing application - still works!
curl http://localhost/health

# Check how many instances remain
docker-compose ps

# Kill another instance
docker stop devops-app-2

# Still partially working (1/3 capacity)!
curl http://localhost/

# Recover
docker-compose up -d --scale app=3
```

### View Instance Events
```bash
# See what's happening in real-time
docker events --filter type=container
# Shows: create, start, die, stop events
```

---

## 📊 Performance Testing

### Get Baseline (Single Instance)
```bash
# Scale to 1
docker-compose up -d --scale app=1

# Test
ab -n 100 -c 5 http://localhost/
# Note: Requests/sec value
```

### Get Results (Multiple Instances)
```bash
# Scale to 5
docker-compose up -d --scale app=5

# Same test
ab -n 100 -c 5 http://localhost/
# Compare: Requests/sec should be higher!
```

### Monitor During Load
```bash
# Terminal 1: Start sustained load
for i in {1..1000}; do curl -s http://localhost/ > /dev/null 2>&1 &; sleep 0.1; done

# Terminal 2: Watch stats
docker stats devops-app-1 devops-app-2 devops-app-3

# Terminal 3: Check logs
docker-compose logs -f app | tail -20
```

---

## 🔍 Debugging

### Check Health of Each Instance Individually
```bash
# Via direct container ports (usually not exposed)
# Or via Nginx
curl http://localhost/health | jq '.status'

# Check specific instance details
docker exec devops-app-1 curl -s http://localhost:3000/health | jq .
```

### View Nginx Configuration
```bash
# Check what Nginx is using
cat /configs/nginx.conf

# Or view inside nginx container
docker exec devops-nginx cat /etc/nginx/nginx.conf
```

### Verify Docker DNS
```bash
# Inside app container, resolve service name
docker exec devops-app-1 nslookup app

# Shows: app resolves to multiple IPs (one per instance)
# Example output:
# Name:   app
# Address: 172.19.0.2
# Address: 172.19.0.3
# Address: 172.19.0.4
```

### Check Network Connectivity
```bash
# From app-1, can it reach Postgres?
docker exec devops-app-1 nc -zv postgres 5432

# From app-1, can it reach other apps?
docker exec devops-app-1 nc -zv app 3000
```

---

## 📈 Monitoring & Metrics

### Prometheus Metrics
```bash
# Access Prometheus
# http://localhost:9090

# View scraped targets
curl http://localhost:9090/api/v1/targets

# Query metrics
curl 'http://localhost:9090/api/v1/query?query=up'
```

### View Application Metrics
```bash
# App exposes metrics on /metrics endpoint
curl http://localhost/metrics | head -20

# Shows:
# - Request count
# - Response times
# - Errors
# - Uptime
# - Node.js metrics (memory, GC, etc.)
```

### Access Prometheus Dashboard
```
http://localhost:9090

Features:
- Graph: Plot metrics over time
- Alerts: View firing alerts
- Status → Targets: See what's being scraped
- Status → Configuration: View prometheus.yml
```

---

## 🛠️ Maintenance

### Update/Rebuild Images
```bash
# Edit code
vim app/server-enhanced.js

# Rebuild image
docker-compose build app

# Restart with new image
docker-compose up -d app
```

### Database Management
```bash
# Connect to database
docker exec -it devops-postgres psql -U devops_user -d devops_app

# Inside psql:
postgres=# \dt              # list tables
postgres=# SELECT * FROM    # query
postgres=# \q               # quit
```

### View Environment Variables
```bash
# Check what env vars are set
docker exec devops-app-1 env | sort

# Or inspect container
docker inspect devops-app-1 | grep -A 20 '"Env"'
```

### Check Disk Usage
```bash
# How much space are Docker images/containers using?
docker system df

# Output:
# Images:    45.6 MB
# Containers: ~200 MB
# Volumes:    variable
```

---

## 🧹 Cleanup

### Stop All Services
```bash
docker-compose stop
# Containers preserved, can restart
```

### Stop and Remove
```bash
docker-compose down
# Containers removed, volumes kept
```

### Complete Cleanup
```bash
# Remove everything (containers + volumes)
docker-compose down -v

# Remove unused images
docker image prune -a

# Clean all unused resources
docker system prune -a --volumes
```

### Remove Specific Container
```bash
# Stop first
docker stop devops-app-1

# Then remove
docker rm devops-app-1

# Or force remove
docker rm -f devops-app-1
```

---

## 📚 Useful Aliases (Optional)

Add to your `~/.zshrc` or `~/.bash_profile`:

```bash
# Scaling
alias scale-up='docker-compose up -d --scale app=5'
alias scale-down='docker-compose up -d --scale app=1'
alias scale-3='docker-compose up -d --scale app=3'

# Viewing
alias dps='docker-compose ps'
alias dlogs='docker-compose logs -f app'
alias dstats='docker stats'

# Testing
alias health='curl -s http://localhost/health | jq .'
alias load-test='ab -n 100 -c 10 http://localhost/'

# Cleanup
alias dclean='docker system prune -a --volumes -f'
```

Then use:
```bash
scale-up        # Scale to 5 instances
scale-3         # Scale to 3 instances
health          # Quick health check
load-test       # Run load test
dps             # List services
dlogs           # Follow logs
dstats          # Stats
```

---

## 🎯 Your Next Steps

### Option 1: Test Scaling
```bash
docker-compose up -d --scale app=5
# Watch it scale up
docker-compose ps
# Now scale down
docker-compose up -d --scale app=1
```

### Option 2: Load Testing
```bash
# If you have Apache Bench
ab -n 1000 -c 100 http://localhost/
```

### Option 3: Kubernetes
```bash
# Apply K8s manifests
kubectl apply -f kubernetes/

# Auto-scales 2-10 instances based on load
```

### Option 4: Cloud Deployment
```bash
# Push to registry
docker tag devops-app:latest your-registry/devops-app:latest
docker push your-registry/devops-app:latest

# Deploy to AWS/Azure/GCP with auto-scaling
```

---

## 🎓 Key Takeaways

```
✅ Horizontal Scaling: Easy - one command to scale up/down
✅ Load Balancing: Automatic via Nginx
✅ No Downtime: Scale while running
✅ Redundancy: One instance fails, others handle requests
✅ Monitoring: Prometheus collects metrics
✅ Cost Effective: Pay only for what you use

Scale from 1 → 3 → 10 → 100+ instances on demand!
```

---

**Your scaled application is ready for production! 🚀**
