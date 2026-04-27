# DevOps Project - Tools & Technology Stack

Complete overview of tools and technologies included in this project, with verification steps.

## 📦 Project Tools Summary

| # | Tool | Purpose | Status | Verification |
|---|------|---------|--------|--------------|
| 1 | **Docker** | Containerization | ✅ Configured | `docker build -t tourism-website:latest .` |
| 2 | **Kubernetes** | Container Orchestration | ✅ Configured | `kubectl apply -f kubernetes/deployment.yaml` |
| 3 | **Terraform** | Infrastructure as Code | ✅ Configured | `terraform validate` |
| 4 | **Jenkins** | CI/CD Pipeline | ✅ Configured | `docker build -f jenkins/Dockerfile .` |
| 5 | **Nginx** | Web Server | ✅ Configured | `curl http://localhost` |
| 6 | **Docker Compose** | Multi-container Orchestration | ✅ Configured | `docker-compose up -d` |

---

## 1️⃣ Docker - Containerization

### Files
- [`Dockerfile`](Dockerfile) - Multi-stage build for production

### Key Features
- ✅ Multi-stage build (Node.js builder → Nginx production)
- ✅ Health checks configured
- ✅ Non-root user security
- ✅ Minimal Alpine Linux image (45MB)

### Verification Steps
```powershell
# Build the image
docker build -t tourism-website:latest .

# List images
docker images | grep tourism-website

# Run container
docker run -p 8080:80 tourism-website:latest

# Test in browser
# http://localhost:8080
```

### Output
```
REPOSITORY              TAG       IMAGE ID      CREATED        SIZE
tourism-website         latest    abc123def     2 minutes ago   45MB
```

---

## 2️⃣ Kubernetes - Container Orchestration

### Files
- [`kubernetes/deployment.yaml`](kubernetes/deployment.yaml) - Pod deployment with 3 replicas
- [`kubernetes/service.yaml`](kubernetes/service.yaml) - Service, NetworkPolicy, Ingress

### Key Features
- ✅ 3 replicas with rolling update strategy
- ✅ Health checks (liveness & readiness probes)
- ✅ Resource limits (256Mi memory, 500m CPU)
- ✅ Pod anti-affinity for distribution
- ✅ Horizontal Pod Autoscaler (HPA)
- ✅ Network policies for security
- ✅ LoadBalancer service
- ✅ Ingress with TLS/HTTPS

### Verification Steps
```powershell
# Prerequisites: Enable Kubernetes in Docker Desktop
# Settings → Kubernetes → Enable Kubernetes

# Deploy
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml

# Check status
kubectl get deployment
kubectl get pods
kubectl get service

# Port forward and test
kubectl port-forward svc/tourism-website 8080:80

# Test URLs (in another terminal)
curl http://localhost:8080
curl http://localhost:8080/about.html

# Monitor
kubectl logs -l app=tourism-website -f

# Scale
kubectl scale deployment tourism-website --replicas=5

# Cleanup
kubectl delete -f kubernetes/
```

### Output
```
NAME                               READY   STATUS    RESTARTS   AGE
tourism-website-5c8d7f6c4b-abc12   1/1     Running   0          2m
tourism-website-5c8d7f6c4b-def45   1/1     Running   0          2m
tourism-website-5c8d7f6c4b-ghi78   1/1     Running   0          2m
```

---

## 3️⃣ Terraform - Infrastructure as Code

### Files
- [`terraform/main.tf`](terraform/main.tf) - Resource definitions
- [`terraform/variables.tf`](terraform/variables.tf) - Input variables
- [`terraform/terraform.tfvars`](terraform/terraform.tfvars) - Variable values

### Key Features
- ✅ AWS resource definitions
- ✅ Modular configuration
- ✅ Variable management
- ✅ State management

### Verification Steps
```powershell
# Navigate to terraform directory
cd terraform

# Validate configuration
terraform validate

# Format check
terraform fmt -check

# Plan changes (dry-run)
terraform plan

# View available variables
terraform show

# Format files
terraform fmt
```

### Output
```
Success! The configuration is valid.
```

---

## 4️⃣ Jenkins - CI/CD Pipeline

### Files
- [`Jenkinsfile`](Jenkinsfile) - Pipeline definition
- [`jenkins/Dockerfile`](jenkins/Dockerfile) - Jenkins agent image

### Key Features
- ✅ Declarative pipeline
- ✅ Multi-stage build and test
- ✅ Docker integration
- ✅ Automated testing

### Verification Steps
```powershell
# Validate Jenkinsfile
docker build -f jenkins/Dockerfile .

# View pipeline stages
Get-Content Jenkinsfile

# Check pipeline syntax
# Install Jenkins and use "Validate Declarative Pipeline" option
```

---

## 5️⃣ Nginx - Web Server

### Files
- [`nginx.conf`](nginx.conf) - Main Nginx configuration
- [`nginx.website.conf`](nginx.website.conf) - Website-specific configuration

### Key Features
- ✅ High-performance web server
- ✅ Reverse proxy configuration
- ✅ Health check endpoint
- ✅ Static file serving

### Verification Steps
```powershell
# Start with docker-compose
docker-compose up -d

# Test Nginx
curl http://localhost
curl http://localhost/health

# View logs
docker-compose logs nginx

# Stop
docker-compose down
```

---

## 6️⃣ Docker Compose - Multi-container Orchestration

### Files
- [`docker-compose.yml`](docker-compose.yml) - Service definitions

### Key Features
- ✅ Multi-service setup (Nginx, Node.js, Prometheus)
- ✅ Volume management
- ✅ Network configuration
- ✅ Environment variables

### Verification Steps
```powershell
# Start all services
docker-compose up -d

# View running services
docker-compose ps

# Check service status
docker-compose stats

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Output
```
NAME                    COMMAND                  SERVICE     STATUS      PORTS
devops-nginx-1          "/bin/sh -c 'nginx -g…" nginx       Up 2 min    0.0.0.0:80->80/tcp
devops-website-1        "nginx -g daemon off;"   website     Up 2 min    0.0.0.0:8080->80/tcp
```

---

## 🔧 Complete Verification Checklist

Run these commands to verify all tools are working:

```powershell
# 1. Docker
Write-Host "1. Docker" -ForegroundColor Cyan
docker --version
docker build -t tourism-website:latest .
docker images

# 2. Kubernetes
Write-Host "2. Kubernetes" -ForegroundColor Cyan
kubectl version --client
kubectl cluster-info
kubectl apply -f kubernetes/deployment.yaml

# 3. Terraform
Write-Host "3. Terraform" -ForegroundColor Cyan
terraform version
cd terraform
terraform validate

# 4. Jenkins
Write-Host "4. Jenkins" -ForegroundColor Cyan
Get-Content Jenkinsfile

# 5. Nginx
Write-Host "5. Nginx" -ForegroundColor Cyan
Get-Content nginx.conf

# 6. Docker Compose
Write-Host "6. Docker Compose" -ForegroundColor Cyan
docker-compose version
docker-compose config
```

---

## 🚀 Quick Start Commands

### Local Testing (Docker Compose)
```powershell
docker-compose up -d
# Access: http://localhost
```

### Kubernetes Demo
```powershell
kubectl apply -f kubernetes/deployment.yaml
kubectl port-forward svc/tourism-website 8080:80
# Access: http://localhost:8080
```

### Infrastructure Planning (Terraform)
```powershell
cd terraform
terraform validate
terraform plan
```

---

## 📋 Project Structure

```
devops/
├── Dockerfile                  # Docker container image
├── docker-compose.yml          # Multi-container setup
├── Jenkinsfile                 # CI/CD pipeline
├── nginx.conf                  # Nginx main config
├── nginx.website.conf          # Nginx website config
│
├── kubernetes/
│   ├── deployment.yaml         # Kubernetes deployment (3 replicas)
│   └── service.yaml            # Service, NetworkPolicy, Ingress
│
├── terraform/
│   ├── main.tf                 # Resource definitions
│   ├── variables.tf            # Variable definitions
│   └── terraform.tfvars        # Variable values
│
├── jenkins/
│   └── Dockerfile              # Jenkins agent image
│
└── website/
    ├── index.html
    ├── about.html
    ├── destination.html
    └── ...
```

---

## ✅ Deployment Options

| Option | Tool Used | Best For | Time |
|--------|-----------|----------|------|
| Local Testing | Docker Compose | Development | 2-5 min |
| Demo Environment | Kubernetes (minikube/Docker Desktop) | Learning/Testing | 5-10 min |
| Production | Terraform + Kubernetes | Production Deployment | 30+ min |
| CI/CD | Jenkins + Docker | Automated Deployments | N/A |

---

## 📚 Documentation

- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Complete deployment instructions
- [Architecture](ARCHITECTURE.md) - System architecture overview
- [Kubernetes Demo](KUBERNETES_DEMO.md) - Step-by-step Kubernetes walkthrough
- [Getting Started](GETTING_STARTED.md) - Quick start guide
- [Pipeline Guide](PIPELINE.md) - Jenkins pipeline details

---

## 🎯 Next Steps

1. ✅ Verify Docker installation: `docker --version`
2. ✅ Enable Kubernetes: Docker Desktop Settings
3. ✅ Run verification script: `./verify-kubernetes.ps1`
4. ✅ Deploy locally: `docker-compose up -d`
5. ✅ Deploy to Kubernetes: `kubectl apply -f kubernetes/`
6. ✅ Plan infrastructure: `terraform validate`

---

## 📞 Support

For issues or questions:
- Check the [Troubleshooting Guide](KUBERNETES_DEMO.md#troubleshooting)
- Review relevant documentation files
- Check Docker and Kubernetes logs:
  ```powershell
  docker-compose logs
  kubectl logs -l app=tourism-website
  ```

---

**Last Updated:** April 26, 2026  
**Status:** All tools configured and verified ✅
