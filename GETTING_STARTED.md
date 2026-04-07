# 🚀 Getting Started (5 Minutes)

The fastest way to see your tourism website running with DevOps deployment.

## ⠀Choose Your Path

### 🎯 Path 1: Test Locally (Recommended First Step)
**Time: 5 minutes | Best for: Quick testing and development**

```bash
# Step 1: Start services
cd /Users/ajayreddy/Desktop/tourism-devops
docker-compose up -d

# Step 2: Open in browser
open http://localhost

# Success! Your website is running locally with:
# - Load balancer (port 80)
# - 3 website instances
```

**What's happening?**
- Docker pulls images and starts 3 website instances
- Nginx load balancer distributes traffic across all 3
- Your HTML files are served from `/website` folder

**Want to scale?**
```bash
# Scale to 5 instances
docker-compose up -d --scale website=5

# Scale back down
docker-compose up -d --scale website=1

# Stop all services
docker-compose down
```

**Next:** Edit files in `website/` folder and refresh browser to see changes!

---

### ⚙️ Path 2: Deploy to Kubernetes (Enterprise)
**Time: 10 minutes | Best for: Kubernetes clusters**

#### Prerequisites
```bash
# Check if kubectl is configured
kubectl cluster-info

# If fails, set up kubeconfig or use minikube
# For Minikube: minikube start
```

#### Deployment Steps
```bash
# Step 1: Deploy to Kubernetes
cd /Users/ajayreddy/Desktop/tourism-devops
kubectl apply -f kubernetes/

# Step 2: Wait for pods to start
kubectl get pods
# Status should show "Running"

# Step 3: Access your website
kubectl port-forward service/tourism-website 8080:80

# Step 4: Open in browser
open http://localhost:8080
```

**What's happening?**
- Kubernetes creates:
  - Deployment with 3 replicas
  - Service with load balancing
  - Auto-scaling (2-10 pods based on CPU)
  - Health checks for reliability

**Monitor Kubernetes:**
```bash
# View pods
kubectl get pods -w

# View service
kubectl get service tourism-website

# View auto-scaling status
kubectl get hpa

# View logs
kubectl logs -f deployment/tourism-website
```

**Cleanup:**
```bash
# Remove deployment
kubectl delete -f kubernetes/
```

---

### 🤖 Path 4: GitHub Actions (Fully Automated)
**Time: 10 minutes (+ waiting for Actions) | Best for: Automated deployments**

#### Setup Steps
```bash
# Step 1: Create GitHub repository
# (Go to github.com/new)

# Step 2: Initialize git and push code
cd /Users/ajayreddy/Desktop/tourism-devops
git init
git remote add origin https://github.com/YOUR-USERNAME/tourism-devops.git
git add .
git commit -m "Initial tourism website DevOps setup"
git push origin main

# Step 3: Add secrets (for Docker Hub or AWS)
# Go to GitHub → Settings → Secrets
# Add: REGISTRY_USERNAME, REGISTRY_PASSWORD

# Step 4: GitHub Actions automatically:
# - Builds Docker image
# - Scans for vulnerabilities
# - Deploys to AWS or Kubernetes
```

**Monitor deployment:**
```bash
# Go to GitHub → Actions tab
# See deployment status and logs
```

**Update your website:**
```bash
# Edit HTML files
vim website/about.html

# Commit and push
git add .
git commit -m "Update about page"
git push origin main

# GitHub Actions automatically deploys! ✨
```

---

## 📊 Quick Comparison

| Factor | Local | AWS | Kubernetes | CI/CD |
|--------|-------|-----|-----------|-------|
| Setup Time | 2 min | 10 min | 5 min | 10 min |
| Cost | Free | $$ | Variable | Free |
| Maintenance | Manual | AWS | Manual | Automatic |
| Best For | Development | Production | Enterprise | Everything |
| Scaling | Manual | Auto | Auto | Auto |

---

## ✅ Verification Checklist

After choosing your path, verify it worked:

- [ ] Website loads in browser (shows your HTML)
- [ ] All pages accessible:
  - [ ] /about.html
  - [ ] /destination.html
  - [ ] /experience.html
- [ ] Health check responds:
  ```bash
  curl http://localhost/health  # or AWS/K8s URL
  # Should return: OK or 200 status
  ```
- [ ] Performance acceptable:
  ```bash
  # Should respond within 200ms
  time curl http://localhost
  ```

---

## 🔄 Common Next Steps

### After Local Testing
```bash
# Scale to test load balancing
docker-compose up -d --scale website=5

# Run performance test
ab -n 100 -c 10 http://localhost/

# Stop and edit files
docker-compose down
vim website/about.html
docker-compose up -d
```

### After AWS Deployment
```bash
# Make updates
vim website/about.html

# Rebuild image
docker build -t tourism-website:latest .

# Push to AWS ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/tourism-website:latest

# Force AWS redeploy
aws ecs update-service --cluster tourism-website \
  --service tourism-website-service \
  --force-new-deployment
```

### After Kubernetes Deployment
```bash
# Update and redeploy
kubectl rollout restart deployment/tourism-website

# Monitor rollout
kubectl rollout status deployment/tourism-website

# Scale manually
kubectl scale deployment tourism-website --replicas=5
```

---

## 🆘 Common Issues

### Issue: "Port 80 already in use"
```bash
# Solution: Stop other services
lsof -i :80
kill -9 <PID>

# Or use different port in docker-compose.yml
# Change: "80:80" to "8080:80"
```

### Issue: "Website shows 502 Bad Gateway"
```bash
# Nginx can't reach website containers
# Solution: Restart services
docker-compose restart

# Check logs
docker-compose logs nginx
```

### Issue: "Docker images not found"
```bash
# Need to build image first
docker build -t tourism-website:latest .

# Then restart
docker-compose restart
```

### Issue: "Terraform apply fails"
```bash
# AWS credentials not configured
aws configure
# Enter your AWS Access Key and Secret Key

# Try again
terraform apply
```

### Issue: "kubectl can't connect to cluster"
```bash
# Kubernetes cluster not running or configured
kubectl cluster-info

# If using Minikube, start it
minikube start

# Then try kubectl commands again
```

---

## 📚 Next Steps by Path

### After Local Testing: [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md)
- How to edit files
- How to debug issues
- How to test performance
- How to scale locally

### After AWS Deployment: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#option-2-aws-deployment-production)
- How to update website
- How to monitor AWS
- How to scale auto-scaling

### After Kubernetes: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#option-3-kubernetes-deployment)
- How to manage Kubernetes
- How to scale pods
- How to view metrics

### After CI/CD Setup: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#option-4-github-actions-cicd)
- How to use GitHub Actions
- How to configure secrets
- How to monitor deployments

---

## 💡 Pro Tips

```bash
# Tip 1: Use aliases for common commands
alias tourstart='cd /Users/ajayreddy/Desktop/tourism-devops && docker-compose up -d'
alias tourstop='cd /Users/ajayreddy/Desktop/tourism-devops && docker-compose down'

# Tip 2: Watch services in real-time
watch -n 1 'docker-compose ps'

# Tip 3: Test multiple pages at once
for page in about destination experience; do
  curl -s http://localhost/$page.html | head -1
done

# Tip 4: Monitor while development
docker stats &
watch 'curl -s http://localhost | wc -c'
```

---

## 🎯 Common Workflows

### Workflow 1: Update Website Content
```bash
# 1. Edit HTML
vim website/about.html

# 2. View changes locally
open http://localhost/about.html

# 3. If using CI/CD:
git add .
git commit -m "Update about page"
git push
```

### Workflow 2: Test Scalability
```bash
# 1. Start with 1 instance
docker-compose up -d --scale website=1

# 2. Measure performance
ab -n 100 -c 10 http://localhost/

# 3. Scale to 5 instances
docker-compose up -d --scale website=5

# 4. Compare performance
ab -n 100 -c 10 http://localhost/

# 5. Note the improvement!
```

### Workflow 3: Production Deployment
```bash
# 1. Test locally
docker-compose up -d
# ... test everything ...
docker-compose down

# 2. Deploy to AWS
cd terraform
terraform apply

# 3. Verify it works
open $(terraform output -raw website_url)

# 4. Monitor
aws logs tail /ecs/tourism-website --follow
```

---

## 🎉 You're Ready!

Your tourism website is production-ready with enterprise-grade DevOps!

### What you have:
- ✅ 3+ deployable instances
- ✅ Load balancing across instances
- ✅ Auto-scaling (2-10 instances)
- ✅ Health monitoring
- ✅ Security & rate limiting
- ✅ Automated CI/CD
- ✅ Multiple deployment options

### Pick your first deployment:
1. **Testing?** → Follow Path 1 (Local)
2. **Production?** → Follow Path 2 (AWS)
3. **Enterprise?** → Follow Path 3 (Kubernetes)
4. **Automation?** → Follow Path 4 (CI/CD)

---

## 📞 Quick Links

- **Full Documentation:** [README.md](README.md)
- **Understanding Architecture:** [ARCHITECTURE.md](ARCHITECTURE.md)
- **Detailed Guides:** [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- **Local Development:** [LOCAL_DEVELOPMENT.md](LOCAL_DEVELOPMENT.md)
- **Command Reference:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- **Documentation Index:** [INDEX.md](INDEX.md)

---

**Choose a path above and start deploying! 🚀**

The quickest way to get running:
```bash
docker-compose up -d && open http://localhost
```

Happy deploying! 🎉
