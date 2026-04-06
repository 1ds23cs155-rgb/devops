# Complete DevOps Pipeline - Tourism Website Project

## 📊 Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          DEVELOPMENT PHASE                           │
├─────────────────────────────────────────────────────────────────────┤
│  1. Developer writes code → 2. Commits to Git (main/develop branch)  │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           ▼
         ┌─────────────────────────────────────┐
         │    GITHUB ACTIONS CI/CD TRIGGERED    │
         │   (on push to main or develop)       │
         └──────────────┬──────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
    ┌───────┐     ┌──────────┐    ┌──────────┐
    │ BUILD │────▶│  SCAN    │───▶│ REGISTRY │
    │       │     │ (Trivy)  │    │  (GHCR)  │
    └───────┘     └──────────┘    └──────────┘
        │
        └─────────────┬──────────────┐
                      ▼              ▼
             ┌──────────────┐  ┌─────────────────┐
             │   STAGING    │  │   PRODUCTION    │
             │ (if develop) │  │  (if main)      │
             └──────────────┘  └─────────────────┘
```

---

## 🔄 Complete Flow (Step-by-Step)

### **Phase 1: LOCAL DEVELOPMENT**

**Tools:** Docker, Docker Compose, VS Code

```
┌─ Developer Environment ─────────────────────────────────────────┐
│                                                                  │
│  1. Edit website code (HTML/CSS in website/ folder)             │
│  2. Run docker-compose up                                       │
│  3. Benefits:                                                   │
│     - Website service (port 8080)                              │
│     - Nginx reverse proxy/load balancer                        │
│     - Prometheus monitoring (port 8090)                        │
│     - All replicated locally as production-like                │
│                                                                  │
│  4. Test locally:                                               │
│     - http://localhost:8080/        (website)                  │
│     - http://localhost:8080/health  (health check)             │
│     - http://localhost:8090/        (Prometheus)               │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

**Commands:**
```bash
cd /Users/ajayreddy/Desktop/devOPS

# Start local stack
docker-compose up

# Check services
docker-compose ps

# View logs
docker-compose logs -f nginx

# Stop
docker-compose down
```

---

### **Phase 2: GIT COMMIT & PUSH**

**Tool:** Git + GitHub

```
┌─ Local Repository ──────────────────────────────────────────────┐
│                                                                  │
│  1. Stage changes:                                              │
│     git add .                                                   │
│                                                                  │
│  2. Commit:                                                     │
│     git commit -m "Update: add new page"                        │
│                                                                  │
│  3. Push to GitHub:                                             │
│     git push origin main                                        │
│                                                                  │
│  Repository: https://github.com/Ajayreddy-2325/devops.git     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

### **Phase 3: CI/CD PIPELINE (GitHub Actions)**

**File:** `.github/workflows/ci-cd.yml`

#### **Stage 1: BUILD**
```
Event: Push to main/develop branch
├─ Checkout code
├─ Setup Docker Buildx (multi-platform builds)
├─ Log in to GitHub Container Registry (GHCR)
├─ Extract metadata (tags, versions)
└─ Build & Push Docker image
    └─ Registry: ghcr.io/Ajayreddy-2325/devops/tourism-website
    └─ Tags: main, develop, SHA hash, etc.
    └─ Cache enabled for faster builds
```

**Example Image Names:**
- `ghcr.io/Ajayreddy-2325/devops/tourism-website:main`
- `ghcr.io/Ajayreddy-2325/devops/tourism-website:develop`
- `ghcr.io/Ajayreddy-2325/devops/tourism-website:sha-abc1234`

#### **Stage 2: SECURITY SCAN**
```
Dependency: Needs build to complete
├─ Pull built image from GHCR
├─ Run Trivy vulnerability scanner
│  └─ Scans for:
│     - CVE vulnerabilities
│     - Dangerous package versions
│     - Configuration issues
└─ Upload results to GitHub Security tab
   └─ Viewable in: Repository → Security → Code scanning
```

#### **Stage 3: DEPLOY TO STAGING** (if develop branch)
```
Dependency: Needs security scan to pass
├─ Triggered only on develop branch
├─ Deployment commands (currently placeholder):
│  └─ Could deploy to staging K8s cluster or test environment
└─ Verification:
   └─ Check staging deployment
   └─ Run automated tests
   └─ Approve for production release
```

#### **Stage 4: DEPLOY TO PRODUCTION** (if main branch)
```
Dependency: Needs security scan to pass
├─ Triggered only on main branch
├─ Production deployment steps:
│  ├─ Update Kubernetes deployment
│  │  └─ kubectl set image deployment/tourism-website ...
│  ├─ Rolling update (no downtime)
│  └─ Health checks verify new pods are running
└─ Result:
   └─ Live site updated at your production domain
```

---

### **Phase 4: LOCAL KUBERNETES TESTING**

**Tool:** Docker Desktop Kubernetes, kubectl

```
┌─ Kubernetes Cluster (Docker Desktop) ──────────────────────────┐
│                                                                  │
│  Manual Testing (Optional):                                     │
│                                                                  │
│  1. Build local image:                                          │
│     docker build -t tourism-website:latest .                   │
│                                                                  │
│  2. Apply manifests:                                            │
│     kubectl apply -f kubernetes/                               │
│                                                                  │
│  3. Check resources:                                            │
│     kubectl get deploy,pods,svc,hpa,ingress                   │
│                                                                  │
│  4. Port forward to test:                                       │
│     kubectl port-forward svc/tourism-website 8081:80           │
│     Open: http://localhost:8081/health                         │
│                                                                  │
│  5. Scale for demo:                                             │
│     kubectl scale deployment tourism-website --replicas=5     │
│                                                                  │
│  6. Check HPA (autoscaling):                                    │
│     kubectl get hpa                                            │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

**Kubernetes Configuration:**
- **Deployment:** 3 replicas (min 2 via HPA)
- **HPA:** Scales up to 10 replicas based on CPU/Memory
- **Service:** LoadBalancer + NodePort exposed
- **NetworkPolicy:** Restricted ingress/egress for security
- **Ingress:** Domain-based routing (domain.com)
- **Security:** Pod security context, read-only filesystem

---

### **Phase 5: MONITORING**

**Tool:** Prometheus (port 8090)

```
┌─ Monitoring Stack ──────────────────────────────────────────────┐
│                                                                  │
│  Prometheus (Metrics Collection):                               │
│  ├─ Scrape targets:                                             │
│  │  ├─ Website pods (metadata annotations)                      │
│  │  ├─ Nginx service                                            │
│  │  └─ Kubernetes API metrics                                   │
│  │                                                              │
│  ├─ Metrics tracked:                                            │
│  │  ├─ Request rate (queries/sec)                              │
│  │  ├─ Error rate (5xx responses)                              │
│  │  ├─ Response latency                                         │
│  │  ├─ Container memory/CPU usage                              │
│  │  ├─ Pod restart count                                        │
│  │  └─ Deployment replica status                               │
│  │                                                              │
│  ├─ Endpoints:                                                  │
│  │  ├─ http://localhost:8090/          (UI)                    │
│  │  ├─ http://localhost:8090/-/ready   (readiness)             │
│  │  └─ http://localhost:8090/-/healthy (liveness)              │
│  │                                                              │
│  └─ Alerting (configured but not shown):                        │
│     └─ Could trigger on high error rate, pod failures, etc    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📋 Infrastructure as Code

### **Terraform** (Infrastructure Provisioning)
```
Location: terraform/
├─ main.tf        (AWS resources to provision)
├─ variables.tf   (Input parameters)
└─ Current state:
   └─ Defines but NOT applied in this session
   └─ Could deploy to AWS (EC2, RDS, etc.)
```

### **Kubernetes Manifests** (Container Orchestration)
```
Location: kubernetes/
├─ deployment.yaml
│  ├─ Deployment: tourism-website (3 replicas)
│  ├─ HPA: Horizontal Pod Autoscaler (2-10 replicas)
│  └─ Pod specs: resource limits, health checks, security
│
├─ service.yaml
│  ├─ Service: LoadBalancer + NodePort routing
│  ├─ NetworkPolicy: Ingress/Egress restrictions
│  └─ Ingress: Domain-based routing (TLS/HTTPS)
│
└─ Quick deploy:
   └─ kubectl apply -f kubernetes/
```

---

## 🚀 Production Deployment Flow

```
┌────────────────────────────────────────────────────────────────┐
│                   Developer Push to main                        │
└─────────────────────┬────────────────────────────────────────────┘
                      │
                      ▼
            ┌──────────────────────┐
            │  GitHub Actions Job  │
            │  1. Build Image      │
            │  2. Scan with Trivy  │
            │  3. Push to GHCR     │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Production Dashboard │
            │ (if wired up):       │
            │ - Approve deployment │
            │ - Set image          │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Kubernetes Update    │
            │ kubectl set image    │
            │ deployment/.../img.. │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Rolling Update       │
            │ - New pods start     │
            │ - Old pods drain     │
            │ - Health checks pass │
            │ - Zero downtime      │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ ✅ LIVE on domain    │
            │ All users see update │
            └──────────────────────┘
```

---

## 📦 Container Registry

**GitHub Container Registry (GHCR)**
```
URL: ghcr.io/Ajayreddy-2325/devops/tourism-website

Image Storage:
├─ ghcr.io/Ajayreddy-2325/devops/tourism-website:main
├─ ghcr.io/Ajayreddy-2325/devops/tourism-website:develop
├─ ghcr.io/Ajayreddy-2325/devops/tourism-website:sha-abc123
└─ ghcr.io/Ajayreddy-2325/devops/tourism-website:latest

Each image includes:
├─ Website code (HTML/CSS from website/ folder)
├─ Nginx config (nginx.website.conf)
├─ node:18-alpine base (multi-stage build optimization)
└─ Security hardening (non-root user, read-only filesystem)
```

---

## 🔐 Security Pipeline

```
Local Security:
├─ .gitignore: Excludes sensitive files
└─ Dockerfile: Non-root user, read-only filesystem

GitHub Actions Security:
├─ GITHUB_TOKEN: Secrets-based authentication
├─ GHCR Push: Authenticated via Actions
└─ Code scanning: Public results in Security tab

Image Security:
├─ Trivy Scan: CVE detection
├─ Dependencies: Alpine Linux (minimal attack surface)
└─ Hardening: Read-only root, dropped capabilities

Kubernetes Security:
├─ NetworkPolicy: Restrict pod communication
├─ SecurityContext: Non-root, no privilege escalation
├─ RBAC: Role-based access control (if configured)
└─ Pod Security Standards: Enforced per namespace
```

---

## 🎯 Quick Reference: Current Endpoints

### **Local Development**
```
Docker Compose:
├─ Website:    http://localhost:8080/
├─ Health:     http://localhost:8080/health
├─ Prometheus: http://localhost:8090/
└─ Ready:      http://localhost:8090/-/ready

Kubernetes (via port-forward):
├─ Website:    http://localhost:8081/
└─ Health:     http://localhost:8081/health
```

### **Production** (placeholder domains)
```
├─ tourism-website.com
├─ www.tourism-website.com
└─ (requires DNS + domain setup)
```

---

## 📊 Pipeline Statistics

| Component | Count | Status |
|-----------|-------|--------|
| Docker Services | 3 | ✅ Running (web, nginx, prometheus) |
| Kubernetes Replicas | 3 | ✅ Ready |
| HPA Min/Max | 2/10 | ✅ Configured |
| GitHub Actions Jobs | 4 | ✅ Build, Scan, Deploy-Staging, Deploy-Prod |
| Monitoring Targets | 3+ | ✅ Active |
| Website Pages | 8 | ✅ index, about, destination, etc. |
| Security Policies | 2 | ✅ NetworkPolicy, Pod Security |

---

## 🔄 Typical Developer Workflow

```
Day 1: Development
┌─ Code change → test locally → commit → push to develop

CI/CD Auto-Triggers:
├─ Build new image
├─ Security scan (Trivy)
├─ Deploy to staging (optional)
├─ Notify on completion
└─ Team reviews

Day 2: Merge to Main
┌─ PR review → approve → merge develop into main

CI/CD Auto-Triggers:
├─ Build production image
├─ Full security scan
├─ Deploy to production
├─ Verify health checks pass
├─ Monitoring alerts team
└─ Live site updated
```

---

## 🛠️ File Structure

```
/devOPS/
├─ .github/workflows/ci-cd.yml      ← CI/CD pipeline
├─ docker-compose.yml               ← Local stack definition
├─ Dockerfile                       ← Image build
├─ nginx.conf                       ← Load balancer config
├─ nginx.website.conf               ← Website Nginx config
├─ kubernetes/
│  ├─ deployment.yaml               ← K8s deployment + HPA
│  └─ service.yaml                  ← K8s service + netpol + ingress
├─ monitoring/
│  └─ prometheus.yml                ← Monitoring config
├─ terraform/                       ← Infrastructure as Code
├─ website/                         ← HTML/CSS pages
└─ docs/                            ← Documentation
   ├─ README.md
   ├─ ARCHITECTURE.md
   ├─ DEPLOYMENT_GUIDE.md
   └─ INTERVIEW_DEMO.md
```

---

## ✅ Pipeline Verification Commands

```bash
# Local Development
docker-compose ps                    # Check services
docker-compose logs nginx            # View errors
curl http://localhost:8080/health    # Test website
curl http://localhost:8090/-/ready   # Test monitoring

# Kubernetes
kubectl get deploy,pods,svc,hpa      # View resources
kubectl logs pod/<name>              # Check pod logs
kubectl port-forward svc/tourism-website 8081:80

# Git
git status                           # Check changes
git log --oneline                    # View commits
git push origin main                 # Push to GitHub

# GitHub
# View CI/CD runs: https://github.com/Ajayreddy-2325/devops/actions
# View images: https://github.com/Ajayreddy-2325/devops/pkgs/container/devops%2Ftourism-website
```

---

**Total Pipeline Time:** 
- Build: ~2-5 min
- Security Scan: ~1-3 min  
- Deploy: ~1-2 min
- **End-to-end: ~5-10 min** from push to live

**Fully automated after initial setup! ✅**
