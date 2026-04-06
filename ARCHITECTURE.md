# Architecture Overview

Enterprise-grade DevOps architecture for deploying a static website with production features.

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Users / Internet                      │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
        ┌────────────────────────────────┐
        │   Load Balancer / Ingress      │
        │  (AWS ALB / Nginx / K8s)       │
        └────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │ Instance│    │Instance │    │Instance │
    │   (1)   │    │   (2)   │    │   (3)   │
    └─────────┘    └─────────┘    └─────────┘
        │                │                │
        └────────────────┼────────────────┘
                         │
                         ▼
        ┌────────────────────────────────┐
        │      Monitoring & Logging      │
        │   (Prometheus / CloudWatch)    │
        └────────────────────────────────┘
```

## 📦 Component Breakdown

### 1. **Web Servers (Nginx)**

**Role**: Serve static HTML/CSS content

**Configuration**:
```nginx
- Listen on port 80 (HTTP)
- Serve files from /usr/share/nginx/html/
- GZIP compression for text/CSS/JS
- 30-day cache for static assets
- Security headers (X-Frame-Options, CSP, etc.)
- Rate limiting (10 req/s default, 20 burst)
- Health check endpoint (/health)
```

**Deployment**:
- Multiple replicas (3+)
- Stateless (no sticky sessions needed for static content)
- Fast startup (< 500ms)
- 45.6MB per container

### 2. **Load Balancer**

**Local (Docker Compose)**:
```
Nginx upstream module
- Distributed to 3 website instances
- Round-robin algorithm
```

**AWS**:
```
Application Load Balancer (ALB)
- Layer 7 (application layer)
- Health checks every 30s
- Connection draining (300s)
- Cross-zone load balancing
- Sticky sessions optional
```

**Kubernetes**:
```
Service type: LoadBalancer
- Distributes to pods
- Internal DNS: tourism-website.default.svc.cluster.local
- Optional ingress controller for TLS/domains
```

### 3. **Auto-Scaling**

**Docker Compose**: Manual scaling
```bash
docker-compose up --scale website=N
```

**AWS**: Auto Scaling Group
```
- Min: 2 instances
- Max: 10 instances
- Triggers:
  - CPU > 70%
  - Memory > 80%
- Scale up: 1 instance
- Scale down: 1 instance
```

**Kubernetes**: Horizontal Pod Autoscaler (HPA)
```
- Min replicas: 2
- Max replicas: 10
- Metrics:
  - CPU target: 70%
  - Memory target: 80%
- Decision frequency: 30s
```

### 4. **Monitoring & Logging**

**Prometheus** (Metrics):
```
- Scrapes Nginx metrics every 30s
- Stores time-series data
- Query language (PromQL)
- 15-day retention (default)
- Dashboard at :9090
```

**AWS CloudWatch** (Logs):
```
- Log group: /ecs/tourism-website
- Log stream per task
- 7-day retention
- Searchable and filterable
```

**Kubernetes** (Logs):
```
- Container logs via kubectl
- Optional ELK stack for centralized logging
- Prometheus for metrics
```

## 🔄 Deployment Workflows

### Local Development Flow
```
1. Source Code (HTML/CSS)
   ↓
2. Docker Build
   - Multi-stage build
   - Optimized for size
   ↓
3. docker-compose up
   - Starts website containers
   - Starts Nginx load balancer
   - Starts Prometheus monitoring
   ↓
4. Access at http://localhost
   - Load balancer distributes traffic
   - Nginx serves static files
   - Prometheus collects metrics
```

### AWS Production Flow
```
1. Source Code (GitHub)
   ↓
2. CI/CD Pipeline (GitHub Actions)
   - Build Docker image
   - Push to AWS ECR
   - Scan for vulnerabilities
   ↓
3. Terraform Infrastructure
   - Creates VPC, subnets
   - Creates ALB (load balancer)
   - Creates ECS cluster
   ↓
4. ECS Deployment
   - Pulls image from ECR
   - Launches tasks (2-10)
   - Registers with ALB
   ↓
5. Auto-Scaling
   - Monitors CPU/Memory
   - Scales up on demand
   - Scales down when idle
   ↓
6. CloudWatch Monitoring
   - Logs all requests
   - Collects metrics
   - Alerts on failures
```

### Kubernetes Flow
```
1. Source Code
   ↓
2. Docker Build & Push
   - Build image
   - Push to registry
   ↓
3. kubectl apply
   - Creates deployment (3 replicas)
   - Creates service (LoadBalancer)
   - Enables HPA (2-10 pods)
   ↓
4. Kubernetes Controller
   - Manages pod lifecycle
   - Monitors health
   - Restarts failed pods
   ↓
5. Auto-Scaling
   - Monitors pod metrics
   - Scales pods based on CPU/Memory
   ↓
6. Access via
   - External LoadBalancer IP
   - NodePort
   - Ingress (with TLS)
```

## 🛡️ Security Architecture

### Container Level
```
Security Features:
├── Non-root user (UID 101)
├── Read-only root filesystem (K8s)
├── No privilege escalation
├── Limited capabilities
└── Resource limits enforced
```

### Network Level
```
Security Features:
├── Network policies (K8s)
│   ├── Ingress from ingress-nginx
│   └── Egress for DNS/HTTP/HTTPS
├── Security groups (AWS)
│   ├── ALB security group (port 80 from :0/0)
│   └── Instance security group (from ALB only)
└── Firewall rules (K8s + AWS)
```

### Application Level
```
Security Headers:
├── X-Frame-Options: DENY
├── X-Content-Type-Options: nosniff
├── X-XSS-Protection: 1; mode=block
├── Strict-Transport-Security (if HTTPS)
├── Content-Security-Policy
└── Rate limiting (10 req/s)
```

### CI/CD Level
```
Security Scanning:
├── Trivy: CVE scanning in images
├── SAST: Static code analysis (optional)
├── Secret scanning: Prevent credential leaks
└── Supply chain verification
```

## 📊 Performance Architecture

### Caching Strategy
```
Level 1: Browser Cache
├── CSS: 30 days
├── JS: 30 days
├── Images: 30 days
└── HTML: No cache (always fresh)

Level 2: CDN Cache (Optional)
├── Global edge locations
├── Automatic cache invalidation
└── DDoS protection

Level 3: Nginx Cache (Optional)
├── Reverse proxy caching
├── Compression enabled
└── Conditional requests support
```

### Content Delivery
```
Optimization techniques:
├── GZIP compression (css, js, json)
└── Minification (manually or via pipeline)
├── Image optimization (external)
├── Lazy loading (if applicable)
└── CDN acceleration (Cloudflare, CloudFront)
```

### Response Times
```
Expected performance:
├── Static HTML: < 50ms
├── With load balancing: < 100ms
├── With monitoring: < 150ms
├── End-to-end (user → AWS → ALB → ECS): < 200ms
└── With TLS: add 50-100ms
```

## 🔧 Configuration Management

### Environment-Specific

**Local Development**
```yaml
Services: website, nginx, prometheus
Replicas: 1-5
Cache: Disabled for development
Logging: Verbose
```

**AWS Production**
```yaml
ECS Tasks: 2-10 (auto-scaling)
ALB Health checks: Every 30s
Cache: Enabled
Logging: CloudWatch (7 days)
```

**Kubernetes**
```yaml
Pods: 2-10 (HPA enabled)
Health checks: Liveness & Readiness
Cache: Enabled
Metrics: Prometheus
```

## 📈 Scalability Model

### Horizontal Scaling (Recommended)
```
Add more instances/pods:
- Load balancer distributes traffic
- Each instance independent
- Easy to scale up/down
- Stateless design enables this
```

### Vertical Scaling (Not Recommended for this project)
```
Increase instance resources:
- More CPU per instance
- More RAM per instance
- Limited by infrastructure
- More expensive
- Usually not needed for static content
```

### Data Persistence
```
Not needed for static website:
- All content is HTML files
- No database required
- No state to persist
- Can use read-only filesystem
```

## 🌐 Network Architecture

### DNS & Routing
```
Domain → DNS → Load Balancer → Route to Instance
         Provider   (AWS ALB)     (Round-robin)
                    or K8s
                    or Nginx
```

### Ports

**Local**
```
80  → Nginx load balancer
9090 → Prometheus (optional)
```

**AWS**
```
80  → ALB (public)
80  → ECS containers (private)
```

**Kubernetes**
```
80  → Service (LoadBalancer)
8080 → Service (NodePort, if using)
443 → Ingress (if TLS enabled)
```

## 🔐 Disaster Recovery

### Backup Strategy
```
Code:
├── Version controlled (GitHub)
├── Automated backups (GitHub)
└── Multiple branches (main, develop)

Configuration:
├── Infrastructure as Code (Terraform)
├── Container registry backups
└── Configuration files in Git

Data:
├── Static files (no data loss concern)
└── Logs in CloudWatch/K8s
```

### Recovery Procedures

**Local**
```bash
# Rebuild from source
docker-compose down
docker-compose up --build
```

**AWS**
```bash
# Redeploy via Terraform
terraform destroy
terraform apply
```

**Kubernetes**
```bash
# Redeploy
kubectl delete -f kubernetes/
kubectl apply -f kubernetes/
```

## 📋 Maintenance Windows

```
Recommended: During low traffic hours
Strategy: Rolling updates (zero downtime)

Procedure:
1. Update code/config
2. Rebuild Docker image
3. Push new version
4. Update deployment (rolling update)
5. Verify health checks
6. Monitor metrics
```

## 🎯 Choosing the Right Deployment

| Factor | Local | AWS | K8s |
|--------|-------|-----|-----|
| Development | ✓✓✓ | ✗ | ✗ |
| Testing | ✓✓ | ✓ | ✓ |
| Production | ✗ | ✓✓✓ | ✓✓✓ |
| Cost | Free | $$ | $$$$ |
| Scaling | Manual | Auto | Auto |
| Reliability | Medium | High | Very High |

## 📚 Technology Stack Brief

| Component | Technology | Version | Role |
|-----------|-----------|---------|------|
| Web Server | Nginx | Alpine | Static file serving |
| Container | Docker | Latest | Containerization |
| Orchestration (Local) | Docker Compose | v3 | Service orchestration |
| Orchestration (Cloud) | Kubernetes | 1.24+ | Pod orchestration |
| Infrastructure | Terraform | 1.0+ | AWS provisioning |
| CI/CD | GitHub Actions | Latest | Automation |
| Monitoring | Prometheus | 2.30+ | Metrics collection |
| Container Registry | AWS ECR | - | Image storage |
| Load Balancer | ALB/Nginx/K8s Svc | - | Traffic distribution |
| Logging | CloudWatch/kubectl | - | Log aggregation |

---

**This architecture provides a production-ready, scalable, and maintainable deployment for your tourism website.**

Questions? See DEPLOYMENT_GUIDE.md or README.md
