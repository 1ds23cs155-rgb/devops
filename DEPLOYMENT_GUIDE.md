# Deployment Guide - Step by Step

Complete guide for deploying your tourism website to different environments.

## 📍 Option 1: Local Deployment (Recommended for Testing)

### Prerequisites
- Docker Desktop installed
- 4GB RAM available
- Terminal/Command line access

### Step-by-Step

#### 1. Build Docker Image
```bash
cd /Users/ajayreddy/Desktop/tourism-devops

# Build the image
docker build -t tourism-website:latest .

# Verify build
docker images | grep tourism-website
```

Expected output:
```
REPOSITORY           TAG       IMAGE ID     CREATED       SIZE
tourism-website      latest    abc123def    2 minutes ago  45.6MB
```

#### 2. Start Local Environment
```bash
# Start all services
docker-compose up -d

# Watch the startup
docker-compose logs -f
```

Expected output:
```
tourism-nginx | [...] listening on 0.0.0.0:80
website   | [...] health check passed
prometheus | [...] started
```

#### 3. Test Website
```bash
# Test main page
curl http://localhost

# Test specific pages
curl http://localhost/about.html
curl http://localhost/destination.html

# View in browser
open http://localhost

# Check health
curl http://localhost/health
```

#### 4. Scale Locally (Optional)
```bash
# Scale to 5 instances
docker-compose up -d --scale website=5

# View instances
docker-compose ps
```

#### 5. Monitor
```bash
# View Prometheus dashboard
open http://localhost:9090

# Check container stats
docker stats

# View logs
docker-compose logs -f website
```

#### 6. Stop Services
```bash
# Stop all services
docker-compose down

# Clean up volumes
docker-compose down -v
```

---

## ☁️ Option 2: AWS Deployment (Production)

### Prerequisites
- AWS Account with access
- AWS CLI installed: `aws --version`
- AWS credentials configured: `aws configure`
- Terraform installed: `terraform --version`

### Step-by-Step

#### 1. Build and Push Docker Image
```bash
# Build image with AWS ECR tag
docker build -t tourism-website:latest .

# Get AWS Account ID and create ECR repository
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=us-east-1

# Create ECR repo
aws ecr create-repository \
  --repository-name tourism-website \
  --region $AWS_REGION

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Tag and push image
docker tag tourism-website:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/tourism-website:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/tourism-website:latest
```

#### 2. Update Terraform Variables
```bash
cd /Users/ajayreddy/Desktop/tourism-devops/terraform

# Edit terraform/variables.tf or create terraform.tfvars
cat > terraform.tfvars << EOF
aws_region      = "us-east-1"
container_image = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/tourism-website:latest"
EOF
```

#### 3. Initialize Terraform
```bash
terraform init
```

Expected output:
```
Terraform has been successfully configured!
```

#### 4. Plan Infrastructure
```bash
terraform plan
```

Review the output. Expected resources:
- VPC with subnets
- Application Load Balancer
- ECS Cluster
- ECS Service (3 tasks)
- Auto Scaling Group (2-10 tasks)
- CloudWatch Logs
- IAM Roles

#### 5. Deploy Infrastructure
```bash
terraform apply
```

When prompted:
```
Do you want to perform these actions?
> yes
```

Expected output:
```
Apply complete! Resources: 25 created

Outputs:
website_url = http://your-alb-dns.us-east-1.elb.amazonaws.com
```

#### 6. Access Your Website
```bash
# Get the load balancer URL
ALB_URL=$(terraform output -raw website_url)

# Test website
curl $ALB_URL
curl $ALB_URL/about.html

# View in browser
open $ALB_URL
```

#### 7. Monitor AWS Deployment
```bash
# View ECS cluster
aws ecs list-clusters --region us-east-1

# View running tasks
aws ecs list-tasks \
  --cluster tourism-website \
  --service-name tourism-website-service \
  --region us-east-1

# View CloudWatch logs
aws logs tail /ecs/tourism-website --follow --region us-east-1
```

#### 8. Destroy AWS Resources (When Done)
```bash
# Remove infrastructure
terraform destroy

# Confirm
> yes
```

---

## ⚙️ Option 3: Kubernetes Deployment

### Prerequisites
- Kubernetes cluster running
- kubectl installed: `kubectl --version`
- kubeconfig configured: `kubectl cluster-info`
- Docker image available (or registry access)

### Step-by-Step

#### 1. Build Docker Image
```bash
# Build image
docker build -t tourism-website:latest .

# If using Docker Hub
docker tag tourism-website:latest your-username/tourism-website:latest
docker push your-username/tourism-website:latest
```

Or use local image with Minikube:
```bash
# For local Minikube
eval $(minikube docker-env)
docker build -t tourism-website:latest .
```

#### 2. Update Kubernetes Manifests
```bash
cd /Users/ajayreddy/Desktop/tourism-devops/kubernetes

# Edit deployment.yaml to use your image
sed -i '' 's|image: tourism-website:latest|image: your-username/tourism-website:latest|' deployment.yaml
```

#### 3. Deploy to Kubernetes
```bash
# Create deployment
kubectl apply -f deployment.yaml

# Create service and networking
kubectl apply -f service.yaml

# Verify deployment
kubectl get deployments
kubectl get pods
kubectl get services
```

Expected output:
```
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
tourism-website      3/3     3            3           2m

NAME                           READY   STATUS    RESTARTS   AGE
tourism-website-5f7c8b9d6-xxx  1/1     Running   0          2m
tourism-website-5f7c8b9d6-yyy  1/1     Running   0          1m
tourism-website-5f7c8b9d6-zzz  1/1     Running   0          1m
```

#### 4. Port Forward to Access
```bash
# Forward port
kubectl port-forward service/tourism-website 8080:80

# In another terminal, test
curl http://localhost:8080
open http://localhost:8080
```

#### 5. Scale Deployment
```bash
# Manual scale
kubectl scale deployment tourism-website --replicas=5

# View pods
kubectl get pods
```

#### 6. Monitor Deployment
```bash
# View pod logs
kubectl logs -f deployment/tourism-website

# Real-time stats
kubectl top pods

# Describe pod
kubectl describe pod <pod-name>

# View auto-scaling status
kubectl get hpa
```

Expected HPA output:
```
NAME                REFERENCE                    TARGETS      MINPODS  MAXPODS  REPLICAS  AGE
tourism-website     Deployment/tourism-website   45%/70%       2        10       3         5m
```

#### 7. Update Website
```bash
# Edit HTML files
vim website/about.html

# Rebuild image
docker build -t tourism-website:latest .

# Push to registry (if needed)
docker push your-username/tourism-website:latest

# Trigger rolling update
kubectl rollout restart deployment/tourism-website

# Monitor rollout
kubectl rollout status deployment/tourism-website
```

#### 8. Cleanup
```bash
# Delete deployment
kubectl delete -f kubernetes/

# Or individually
kubectl delete deployment tourism-website
kubectl delete service tourism-website
```

---

## 🤖 Option 4: GitHub Actions CI/CD

### Prerequisites
- GitHub repository created
- Code pushed to GitHub
- Docker Hub account (or GitHub Container Registry)

### Step-by-Step

#### 1. Create GitHub Repository
```bash
cd /Users/ajayreddy/Desktop/tourism-devops

# Initialize git
git init

# Add remote
git remote add origin https://github.com/1ds23cs155-rgb/devops.git

# Create main branch
git checkout -b main
```

#### 2. Add GitHub Secrets
```bash
# Go to: GitHub → Settings → Secrets and variables → Actions

# Add secrets:
REGISTRY_USERNAME = your-docker-hub-username
REGISTRY_PASSWORD = your-docker-hub-token

# For AWS (if deploying to AWS):
AWS_ACCESS_KEY_ID = your-aws-access-key
AWS_SECRET_ACCESS_KEY = your-aws-secret-key
AWS_REGION = us-east-1

# For Kubernetes (if deploying to K8s):
KUBE_CONFIG = your-kubeconfig-base64
```

#### 3. Commit and Push Code
```bash
# Add all files
git add .

# Commit
git commit -m "Initial DevOps setup for tourism website"

# Push to main (triggers production deployment)
git push origin main
```

#### 4. Monitor CI/CD Pipeline
```bash
# Go to: GitHub → Actions → Click latest workflow

# View workflow status:
# ✓ Build (2 min)
# ✓ Security Scan (1 min)
# ✓ Deploy Production (3 min)
```

#### 5. Subsequent Deployments
```bash
# Edit website files
vim website/about.html

# Create feature branch
git checkout -b feature/update-content

# Commit
git add .
git commit -m "Update about page"

# Push to develop (triggers staging deployment)
git push origin feature/update-content

# Create pull request and merge to main (triggers production)
```

#### 6. Track Deployments
```bash
# GitHub Actions → Deployments
# See deployment history and status
```

---

## 📊 Comparison: All 4 Deployment Options

| Aspect | Local | AWS | Kubernetes | CI/CD |
|--------|-------|-----|-----------|-------|
| Setup Time | 5 min | 15 min | 10 min | 10 min |
| Cost | Free | $$ | Variable | Free |
| Scaling | Manual | Auto | Auto | Auto |
| Best For | Development | Production | Enterprise | Automation |
| Effort | Easiest | Medium | Hard | Easy |

---

## 🛢️ Upgrading Your Website

All deployment options support seamless updates:

### Local Development
```bash
# Edit files
vim website/about.html

# Rebuild
docker-compose up -d

# Changes live immediately
```

### AWS
```bash
# Update image
docker build -t tourism-website:latest .
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/tourism-website:latest

# Force new deployment
aws ecs update-service --cluster tourism-website \
  --service tourism-website-service --force-new-deployment \
  --region us-east-1
```

### Kubernetes
```bash
# Update image
docker build -t tourism-website:latest .
docker push your-username/tourism-website:latest

# Trigger update
kubectl rollout restart deployment/tourism-website

# Monitor
kubectl rollout status deployment/tourism-website
```

### CI/CD
```bash
# Edit files
vim website/about.html

# Commit and push
git add .
git commit -m "Update website"
git push origin main

# GitHub Actions automatically deploys!
```

---

## ⚠️ Common Issues and Solutions

### Issue: "Connection refused" when accessing website
**Solution:**
```bash
# Check if services are running
docker-compose ps

# Restart services
docker-compose restart

# Check logs
docker-compose logs website
```

### Issue: "Port 80 already in use"
**Solution:**
```bash
# Find process using port 80
lsof -i :80

# Stop other services
sudo kill -9 <PID>

# Or change port in docker-compose.yml
# ports:
#   - "8080:80"  # Use 8080 instead
```

### Issue: Health check failing
**Solution:**
```bash
# Test health endpoint manually
curl http://localhost/health

# Check file permissions
docker exec tourism-nginx ls -la /usr/share/nginx/html

# Rebuild image
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Issue: Out of disk space with Docker
**Solution:**
```bash
# Clean up Docker
docker system prune -a --volumes

# Remove old images
docker rmi $(docker images -q)
```

---

## ✅ Verification Checklist

Before considering your deployment complete:

- [ ] Website accessible at designated URL
- [ ] All HTML pages loading correctly
- [ ] Health check endpoint responding
- [ ] Load balancer distributing traffic
- [ ] Auto-scaling triggered under load
- [ ] Logs visible in monitoring dashboard
- [ ] No error messages in logs
- [ ] Website responsive on mobile/desktop
- [ ] CSS and images loading properly
- [ ] Performance acceptable (< 500ms)

---

**Your tourism website is deployed! 🎉**

Need help? Check the README.md or troubleshooting section above.
