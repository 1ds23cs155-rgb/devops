# Tourism Website - Enterprise DevOps Deployment

Deploy your tourism website using Docker, Kubernetes, AWS, and GitHub Actions CI/CD.

## 📋 Project Structure

```
.
├── website/                    # Your HTML files
│   ├── index.html
│   ├── about.html
│   ├── destination.html
│   └── ... (8 HTML pages)
├── Dockerfile                  # Container image
├── nginx.conf                  # Web server config
├── nginx.website.conf          # Website container static-server config
├── docker-compose.yml          # Local orchestration
├── kubernetes/
│   ├── deployment.yaml         # K8s deployment
│   └── service.yaml            # K8s service & ingress
├── terraform/
│   ├── main.tf                 # AWS infrastructure
│   └── variables.tf            # Terraform variables
├── monitoring/
│   └── prometheus.yml          # Metrics config
├── Jenkinsfile                 # Jenkins pipeline
└── .github/workflows/
    └── ci-cd.yml               # GitHub Actions pipeline

_Legacy:_ The earlier Node/Postgres demo project was archived at `legacy-devops/`.
```

## 🚀 Quick Start

### 1. Local Development (Docker Compose)

```bash
# Start all services
docker-compose up -d --build

# View running services
docker-compose ps

# Access website
open http://localhost:8080

# View metrics
open http://localhost:8090

# Jenkins UI
open http://localhost:8088

# Stop services
docker-compose down
```

### 2. Scale Locally

```bash
# Scale to 5 instances
docker-compose up -d --scale website=5

# View all instances
docker-compose ps

# Load balancer (Nginx) automatically distributes traffic
```

### 3. Check Health

```bash
# Health endpoint
curl http://localhost:8080/health

# Access HTML files
curl http://localhost:8080/about.html
curl http://localhost:8080/destination.html
```

## ☁️ Deploy to AWS

### Prerequisites
- AWS Account
- AWS CLI installed
- AWS credentials configured

### Steps

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review infrastructure plan
terraform plan

# Deploy to AWS
terraform apply

# Get the load balancer URL
terraform output website_url

# Access your website on AWS!
```

### Features
- Auto-scaling (2-10 instances)
- Application Load Balancer
- Container orchestration (ECS Fargate)
- CloudWatch logging
- Health checks

## ⚙️ Deploy to Kubernetes

### Prerequisites
- Kubernetes cluster (local or cloud)
- kubectl CLI
- kubeconfig configured

### Steps

```bash
# Build Docker image
docker build -t tourism-website:latest .

# Push to registry (if using cloud K8s)
docker tag tourism-website:latest your-registry/tourism-website:latest
docker push your-registry/tourism-website:latest

# Deploy to Kubernetes
kubectl apply -f kubernetes/

# View deployment
kubectl get deployments
kubectl get pods
kubectl get services

# Port forward to access locally
kubectl port-forward service/tourism-website 8080:80

# Access at http://localhost:8080
```

### Features
- 3+ replicas
- Auto-scaling (2-10 pods)
- Rolling updates (zero downtime)
- Health checks (liveness & readiness)
- Security policies
- Load balancing

## 🤖 GitHub Actions CI/CD

### Setup

1. Push code to GitHub
2. Add repository secrets:
   ```
   REGISTRY_USERNAME: your-docker-hub-username
   REGISTRY_PASSWORD: your-docker-hub-token
   ```

3. GitHub Actions automatically:
   - Builds Docker image
   - Scans for vulnerabilities
   - Deploys to staging (on develop branch)
   - Deploys to production (on main branch)

### Trigger Deployment
```bash
# Edit website files
git add .
git commit -m "Update tourism website"
git push origin main

# GitHub Actions automatically deploys!
```

## 🧰 Jenkins CI/CD (Optional)

This project also includes a Jenkins pipeline definition in `Jenkinsfile`.

### Run Jenkins locally

```bash
docker-compose up -d jenkins
```

### First-time Jenkins setup

```bash
docker exec tourism-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Then open `http://localhost:8088`, complete setup, and create a Pipeline job that points to this repository and uses the root `Jenkinsfile`.

### What Jenkins does now

- Checks out the repo from GitHub
- Builds the tourism website Docker image
- Runs a smoke test against the container
- Deploys to Kubernetes on `main` or `master`

### Jenkins credentials and settings

- Git credential: `Username with password`
- Username: your GitHub username
- Password: your GitHub Personal Access Token
- ID: `github-token`

### GitHub webhook trigger

Add this webhook in your GitHub repo settings:

- Payload URL: `http://YOUR_JENKINS_URL/github-webhook/`
- Content type: `application/json`
- Events: `Just the push event`

### Kubernetes deploy from Jenkins

Jenkins now has access to:

- Docker CLI for image build and smoke tests
- kubectl for `kubectl apply -f kubernetes/`
- Your local kubeconfig mounted from `/Users/ajayreddy/.kube`

If you want to test the deploy stage locally, make sure Docker Desktop Kubernetes is running and `kubectl get nodes` works on your Mac.

## 📊 Monitoring

### Local Monitoring
```bash
# Prometheus dashboard
open http://localhost:9090

# View metrics
http://localhost:9090/graph

# Query examples:
# up{job="prometheus"}
# rate(nginx_requests_total[5m])
```

### Docker Stats
```bash
# Real-time container stats
docker stats

# Specific containers
docker stats tourism-nginx website
```

### Kubernetes Monitoring
```bash
# Pod metrics
kubectl top pods

# Node metrics
kubectl top nodes

# Set up Prometheus (optional)
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd.yaml
```

## 🔧 Configuration

### Environment Variables
```bash
# In docker-compose.yml or Kubernetes:
NODE_ENV=production
LOG_LEVEL=info
```

### Nginx Configuration
Edit `nginx.conf` to:
- Modify cache headers
- Add security headers
- Configure compression
- Set rate limiting

### Terraform Variables
Edit `terraform/variables.tf` to:
- Change AWS region
- Modify instance count
- Adjust resource limits
- Update container image

## 🛡️ Security Features

```
✅ Non-root container execution
✅ Read-only root filesystem (Kubernetes)
✅ Security headers in Nginx
✅ Health checks monitoring
✅ Resource limits enforced
✅ Network policies (Kubernetes)
✅ Vulnerability scanning (GitHub Actions)
```

## 📈 Scaling

### Docker Compose
```bash
# Scale to N instances
docker-compose up -d --scale website=N

# Nginx load balancer auto-discovers instances
```

### Kubernetes
```bash
# Manual scaling
kubectl scale deployment tourism-website --replicas=5

# Auto-scaling already configured (2-10 pods)
# Scales based on CPU (70%) and memory (80%)
```

### AWS
```bash
# Auto-scaling configured via Terraform
# Scales 2-10 ECS tasks
# Based on CPU and memory metrics
```

## 🧹 Cleanup

### Docker
```bash
# Stop services
docker-compose down

# Remove images
docker rmi tourism-website:latest

# Clean up all
docker system prune -a --volumes
```

### Kubernetes
```bash
# Delete deployment
kubectl delete -f kubernetes/

# Delete namespace
kubectl delete namespace tourism-website
```

### AWS
```bash
# Destroy infrastructure
cd terraform
terraform destroy

# Confirm deletion
# Type: yes
```

## 📝 Usage Examples

### Access your website

**Local:**
```
http://localhost/
http://localhost/about.html
http://localhost/destination.html
```

**AWS:**
```
http://your-load-balancer-dns.com/
http://your-load-balancer-dns.com/about.html
```

**Kubernetes:**
```
kubectl port-forward service/tourism-website 8080:80
http://localhost:8080/
```

### Check health
```bash
# All deployment methods
curl http://<your-website>/health
```

### View logs
```bash
# Docker
docker-compose logs -f website

# Kubernetes
kubectl logs -f deployment/tourism-website

# AWS
aws logs tail /ecs/tourism-website --follow
```

## 🚨 Troubleshooting

### Website not loading
```bash
# Check if containers are running
docker-compose ps

# Check logs
docker-compose logs website

# Check Nginx config
docker exec tourism-nginx nginx -t
```

### Health check failing
```bash
# Manually test health endpoint
curl -v http://localhost/health

# Check file permissions
docker exec tourism-nginx ls -la /usr/share/nginx/html
```

### High latency or errors
```bash
# View container stats
docker stats

# Check Nginx access logs
docker logs tourism-nginx

# View error logs
docker exec tourism-nginx tail -f /var/log/nginx/error.log
```

## 📚 Learn More

- [Docker Documentation](https://docs.docker.com)
- [Kubernetes Documentation](https://kubernetes.io/docs)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws)
- [Nginx Documentation](https://nginx.org/en/docs)

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review logs using kubectl/docker commands
3. Check GitHub Actions workflow status
4. Verify AWS CloudFormation events (if using Terraform)

## 📄 License

Your tourism website deployment project.

---

**Your tourism website is now ready for enterprise-grade deployment! 🚀**
