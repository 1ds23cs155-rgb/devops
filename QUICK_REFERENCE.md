# Quick Reference - Command Cheatsheet

Quick lookup for common commands across all deployment methods.

## 🖥️ Local Development (Docker Compose)

### Start & Stop
```bash
# Start services
docker-compose up -d

# Start with logs visible
docker-compose up

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Restart services
docker-compose restart

# Restart specific service
docker-compose restart website
docker-compose restart nginx
```

### View Status
```bash
# List running containers
docker-compose ps

# View logs
docker-compose logs

# Follow logs (live)
docker-compose logs -f

# Last N lines
docker-compose logs --tail=50

# Specific service logs
docker-compose logs -f website
docker-compose logs -f nginx
```

### Scale Locally
```bash
# Scale to N instances
docker-compose up -d --scale website=N

# Scale to 5
docker-compose up -d --scale website=5

# Scale to 1 (default)
docker-compose up -d --scale website=1
```

### Docker Image
```bash
# Build image
docker build -t tourism-website:latest .

# Build with no cache
docker build --no-cache -t tourism-website:latest .

# View images
docker images | grep tourism

# Remove image
docker rmi tourism-website:latest

# Tag image for registry
docker tag tourism-website:latest username/tourism-website:latest
docker push username/tourism-website:latest
```

### Container Access
```bash
# Shell into container
docker-compose exec website sh
docker-compose exec nginx sh

# Run command in container
docker-compose exec website ls -la
docker-compose exec nginx nginx -t

# View container processes
docker stats

# Inspect container
docker inspect <container-id>
```

### Testing
```bash
# Test webpage
curl http://localhost
curl http://localhost/about.html
curl http://localhost/health

# Verbose output
curl -v http://localhost

# Show headers only
curl -I http://localhost

# Performance test (100 requests, 10 concurrent)
ab -n 100 -c 10 http://localhost/
```

## ☁️ AWS Deployment (Terraform)

### Initialize & Plan
```bash
cd terraform

# Initialize Terraform
terraform init

# Format files
terraform fmt

# Validate configuration
terraform validate

# View plan (what will be created)
terraform plan

# Save plan to file
terraform plan -out=tfplan
```

### Deploy & Manage
```bash
# Deploy infrastructure
terraform apply

# Deploy specific plan
terraform apply tfplan

# Deploy without prompt
terraform apply -auto-approve

# Destroy all infrastructure
terraform destroy

# Destroy specific resource
terraform destroy -target=aws_ecs_service.tourism_website
```

### View Information
```bash
# List all resources
terraform state list

# Show resource details
terraform state show aws_ecs_service.tourism_website

# View outputs
terraform output

# Get specific output
terraform output website_url

# View raw output (useful for scripting)
terraform output -raw website_url
```

### Debugging
```bash
# Enable debug logging
TF_LOG=DEBUG terraform apply

# Save debug logs to file
TF_LOG=DEBUG TF_LOG_PATH=terraform.log terraform apply

# View AWS resources directly
aws ecs list-clusters --region us-east-1
aws ecs list-tasks --cluster tourism-website --region us-east-1
aws ecs describe-tasks --cluster tourism-website --tasks <task-arn> --region us-east-1
```

### Update Deployment
```bash
# Build new image
docker build -t tourism-website:latest .

# Push to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/tourism-website:latest

# Force new deployment
aws ecs update-service \
  --cluster tourism-website \
  --service tourism-website-service \
  --force-new-deployment \
  --region us-east-1
```

### View Logs
```bash
# View recent logs
aws logs tail /ecs/tourism-website --region us-east-1

# Follow logs (live)
aws logs tail /ecs/tourism-website --follow --region us-east-1

# View specific time range
aws logs filter-log-events \
  --log-group-name /ecs/tourism-website \
  --start-time 1000 \
  --region us-east-1
```

## ⚙️ Kubernetes (kubectl)

### Deploy & Cleanup
```bash
# Deploy all manifests
kubectl apply -f kubernetes/

# Deploy specific file
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Delete deployment
kubectl delete -f kubernetes/

# Delete specific resource
kubectl delete deployment tourism-website
kubectl delete service tourism-website
```

### View Resources
```bash
# List deployments
kubectl get deployments

# List pods
kubectl get pods

# List services
kubectl get services

# List all resources
kubectl get all

# View with details
kubectl get pods -o wide

# Watch in real-time
kubectl get pods -w
```

### Inspect & Debug
```bash
# Describe pod
kubectl describe pod <pod-name>

# View pod details
kubectl get pod <pod-name> -o yaml

# View logs
kubectl logs deployment/tourism-website

# Follow logs (live)
kubectl logs -f deployment/tourism-website

# Logs from specific pod
kubectl logs -f <pod-name>

# Previous logs (for crashed pods)
kubectl logs --previous <pod-name>
```

### Access & Port Forward
```bash
# Port forward to service
kubectl port-forward service/tourism-website 8080:80

# Port forward to pod
kubectl port-forward <pod-name> 8080:80

# Access forwarded port
curl http://localhost:8080
open http://localhost:8080
```

### Scale & Update
```bash
# Manual scale
kubectl scale deployment tourism-website --replicas=5

# Edit deployment
kubectl edit deployment tourism-website

# Rollout restart (redeploy)
kubectl rollout restart deployment/tourism-website

# Rollout status
kubectl rollout status deployment/tourism-website

# Rollout history
kubectl rollout history deployment/tourism-website

# Rollback to previous
kubectl rollout undo deployment/tourism-website
```

### Auto-Scaling
```bash
# View HPA (Horizontal Pod Autoscaler)
kubectl get hpa

# View HPA details
kubectl describe hpa tourism-website

# View pod metrics
kubectl top pods

# View node metrics
kubectl top nodes
```

### Container Access
```bash
# Shell into pod
kubectl exec -it <pod-name> -- sh

# Run command in pod
kubectl exec <pod-name> -- ls -la

# Copy from pod
kubectl cp <pod-name>:/path/to/file ./local-file

# Copy to pod
kubectl cp ./file <pod-name>:/path/to/file
```

## 🤖 GitHub Actions (CI/CD)

### View Workflow
```bash
# View workflow runs
gh run list

# View specific run
gh run view <run-id>

# View job logs
gh run view <run-id> --log

# Watch workflow (live)
gh run watch
```

### Manual Triggers
```bash
# Push to main (triggers production deploy)
git push origin main

# Push to develop (triggers staging deploy)
git push origin develop

# Create tag (optional trigger)
git tag v1.0.0
git push origin v1.0.0
```

### Manage Secrets
```bash
# Add secret
gh secret set SECRET_NAME --body "secret-value"

# List secrets
gh secret list

# Remove secret
gh secret delete SECRET_NAME
```

## 📊 Monitoring Commands

### Local (Prometheus)
```bash
# Access dashboard
open http://localhost:9090

# Query metrics
# In Prometheus UI:
# - Query: up
# - Query: nginx_requests_total
# - Query: rate(nginx_requests_total[5m])
```

### AWS (CloudWatch)
```bash
# View log groups
aws logs describe-log-groups --region us-east-1

# View log streams
aws logs describe-log-streams \
  --log-group-name /ecs/tourism-website \
  --region us-east-1

# Search logs
aws logs filter-log-events \
  --log-group-name /ecs/tourism-website \
  --filter-pattern "ERROR" \
  --region us-east-1
```

### Kubernetes (Prometheus)
```bash
# View pod metrics
kubectl top pods

# View node metrics
kubectl top nodes

# Describe HPA metrics
kubectl get hpa
kubectl describe hpa tourism-website
```

## 🧪 Testing Commands

### Functional Testing
```bash
# Test homepage
curl http://localhost
curl http://localhost/index.html

# Test all pages
for page in about destination experience; do
  curl -s http://localhost/$page.html > /dev/null && echo "✓ $page" || echo "✗ $page"
done

# Test health endpoint
curl http://localhost/health
```

### Performance Testing
```bash
# Benchmark (100 requests, 10 concurrent)
ab -n 100 -c 10 http://localhost/

# Extended benchmark (1000 requests, 50 concurrent)
ab -n 1000 -c 50 http://localhost/

# Show response times
ab -n 100 -c 10 -g results.tsv http://localhost/
```

### Load Testing
```bash
# Using hey tool
brew install hey  # if not installed

# Basic load test
hey http://localhost/

# Custom load test (1000 requests, 20 concurrent)
hey -n 1000 -c 20 http://localhost/

# Show latency percentiles
hey -n 100 http://localhost/
```

## 🔧 Maintenance Commands

### Cleanup
```bash
# Remove all Docker containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Complete cleanup
docker system prune -a --volumes
```

### Logs & Diagnostics
```bash
# Check disk usage
du -sh /Users/ajayreddy/Desktop/tourism-devops

# Find large files
find /Users/ajayreddy/Desktop/tourism-devops -type f -size +100M

# Check open ports
lsof -i

# Network diagnostics
netstat -an | grep LISTEN
```

### Git Commands
```bash
# Check status
git status

# View changes
git diff

# Stage changes
git add .

# Commit
git commit -m "Update website"

# Push to remote
git push origin main

# Pull latest
git pull origin main

# View history
git log --oneline -10
```

## 🚀 Complete Deployment Workflow

### From Start to Production

```bash
# 1. Local Testing
cd /Users/ajayreddy/Desktop/tourism-devops
docker-compose up -d
curl http://localhost
docker-compose down

# 2. Build Image
docker build -t tourism-website:latest .

# 3. Push to GitHub
git add .
git commit -m "Tourism website DevOps setup"
git push origin main

# 4. GitHub Actions CI/CD
# (Automatic: build → scan → deploy)

# 5. Verify AWS Deployment
terraform output website_url
curl $(terraform output -raw website_url)

# 6. OR Deploy to Kubernetes
kubectl apply -f kubernetes/
kubectl get pods
kubectl port-forward service/tourism-website 8080:80
curl http://localhost:8080

# 7. Monitor
open http://localhost:9090  # Prometheus (local)
# or
aws logs tail /ecs/tourism-website --follow  # AWS logs
```

## 📋 Decision Matrix

Choose the right deployment:

```
Need quick local test?
→ docker-compose up -d

Need production AWS deployment?
→ cd terraform && terraform apply

Need enterprise Kubernetes?
→ kubectl apply -f kubernetes/

Need fully automated CI/CD?
→ git push || github actions handles it
```

---

**Pro Tip:** Bookmark this page for quick reference during deployment!

For detailed information, see:
- [README.md](README.md) - Overview
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Step-by-step
- [ARCHITECTURE.md](ARCHITECTURE.md) - Design details  
- [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md) - Dev setup
