# Advanced DevOps Project - Implementation Guide

## 📊 Project Enhancements

This guide covers all the enterprise-grade features added to make your DevOps project production-ready.

---

## 1. 🧪 Unit Testing & Code Quality

### Running Tests

```bash
# Install dependencies
cd app && npm install

# Run all tests with coverage
npm test

# Watch mode (re-run tests on file changes)
npm run test:watch

# CI/CD mode
npm run test:ci
```

### Test Coverage

- **Location**: `tests/server.test.js`
- **Framework**: Jest + Supertest
- **Coverage Target**: 70% (configurable in `jest.config.js`)
- **Tests Include**:
  - HTTP endpoint testing
  - Response validation
  - Status code verification
  - Error handling

### Code Quality & Linting

```bash
# Run linter
npm run lint

# Fix linting issues automatically
npm run lint:fix

# Security audit
npm audit
```

**Tools Used**:
- **ESLint**: Code quality and style enforcement
- **Airbnb Config**: Industry-standard rules
- **npm audit**: Security vulnerability detection

---

## 2. 🐘 Database Integration (PostgreSQL)

### Setup

PostgreSQL is automatically started with Docker Compose:

```bash
docker-compose up -d postgres
```

### Connection Details

```
Host: postgres (docker hostname) or localhost
Port: 5432
Database: devops_app
User: devops_user
Password: devops_secure_password
```

### Database Operations

```bash
# Connect to database
docker-compose exec postgres psql -U devops_user -d devops_app

# View tables
\dt

# Exit
\q

# Database backups
docker-compose exec postgres pg_dump -U devops_user devops_app > backup.sql

# Restore database
cat backup.sql | docker-compose exec -T postgres psql -U devops_user -d devops_app
```

---

## 3. 📚 API Documentation (Swagger/OpenAPI)

### Access Swagger UI

```
http://localhost:3000/api/docs
```

### Features

- **Interactive API Explorer**: Try APIs directly from browser
- **Request/Response Schemas**: Clear data structure definitions
- **Authentication Details**: Security requirements documented
- **Endpoint Grouping**: Organized by tags

### Adding Documentation

Example in `app/server-enhanced.js`:

```javascript
/**
 * @swagger
 * /api/endpoint:
 *   get:
 *     summary: Endpoint description
 *     tags:
 *       - Category
 *     responses:
 *       200:
 *         description: Success response
 */
app.get('/api/endpoint', (req, res) => { ... });
```

---

## 4. 🔐 Security Hardening

### Implemented Features

1. **Helmet.js**: Secure HTTP headers
2. **CORS**: Cross-Origin Resource Sharing control
3. **Morgan**: Request logging
4. **Non-root User**: Container runs as `nodejs` user
5. **JWT Authentication**: Token-based auth (ready to implement)
6. **Password Hashing**: bcrypt for secure passwords
7. **Environment Variables**: Secrets not in code

### Security Checklist

```bash
# Check Docker image for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image devops-app:latest

# Audit npm dependencies
npm audit

# Review environment variables
cat app/.env.example
```

---

## 5. 📊 Monitoring & Logging

### Components

**Prometheus** (Metrics Collection)
```
http://localhost:9090
```

**Application Metrics Endpoint**
```
GET http://localhost:3000/metrics
```

### Metrics Provided

- `app_info` - Application metadata
- `nodejs_memory_heap_used_bytes` - Memory usage
- `nodejs_memory_heap_total_bytes` - Total heap
- `process_uptime_seconds` - Application uptime

### Setup Additional Monitoring (Optional)

```bash
# Start complete monitoring stack with Grafana
docker-compose -f docker-compose.yml up -d
docker-compose -f monitoring/docker-compose.monitoring.yml up -d

# Access Grafana
# URL: http://localhost:3001
# Username: admin
# Password: admin123
```

---

## 6. ⚙️ Kubernetes Deployment

### Files

- `kubernetes/deployment.yaml` - Application deployment
- `kubernetes/service.yaml` - Kubernetes service & secrets
- `kubernetes/ingress.yaml` - Ingress & auto-scaling

### Deploy to Kubernetes

```bash
# Apply all manifests
kubectl apply -f kubernetes/

# View deployments
kubectl get deployments
kubectl get pods
kubectl get services

# Check logs
kubectl logs -f deployment/devops-app

# Access application
kubectl port-forward svc/devops-app-service 8080:80
# Then visit http://localhost:8080
```

### Key Features

- **3 Replicas**: High availability
- **Health Checks**: Liveness & readiness probes
- **Resource Limits**: CPU and memory constraints
- **Security Context**: Non-root, read-only filesystem
- **HPA**: Horizontal Pod Autoscaler (2-10 replicas)
- **Secrets Management**: Database credentials encrypted

---

## 7. 🏗️ Terraform (Infrastructure as Code)

### Files

- `terraform/main.tf` - AWS infrastructure
- `terraform/variables.tf` - Input variables
- `terraform/terraform.tfvars.example` - Example values

### Setup

```bash
cd terraform

# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize Terraform
terraform init

# Plan infrastructure
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Infrastructure Created

- **VPC**: Virtual Private Cloud (10.0.0.0/16)
- **Subnets**: 2 Public + 2 Private
- **Security Groups**: Configured for ALB
- **Application Load Balancer**: For traffic distribution
- **Target Groups**: For routing rules

### AWS Requirements

```bash
# Install AWS CLI and configure credentials
aws configure

# Test credentials
aws sts get-caller-identity
```

---

## 8. 🤖 Ansible Playbooks

### Files

- `ansible/playbook.yml` - Deployment playbook
- `ansible/inventory.ini` - Host configuration

### Setup

```bash
# Install Ansible
pip install ansible

# Test connectivity to hosts
ansible -i ansible/inventory.ini webservers -m ping

# Run playbook
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

# Specific tags
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags deploy
```

### Playbook Features

- Ubuntu system updates
- Docker installation
- Application deployment
- Health verification
- Automated error handling

### Edit Hosts

Edit `ansible/inventory.ini`:
```ini
[webservers]
web1 ansible_host=192.168.1.10
web2 ansible_host=192.168.1.11
```

---

## 9. 🚀 Load Testing

### Files

- `load-testing/test.js` - K6 load test script

### Setup

```bash
# Install k6
brew install k6  # macOS
# or download from https://k6.io/docs/getting-started/installation/

# Run load test
k6 run load-testing/test.js

# Custom base URL
k6 run -e BASE_URL=http://custom-url.com load-testing/test.js

# Generate HTML report
k6 run --out html=report.html load-testing/test.js
```

### Test Stages

1. **Ramp-up** (30s): 0 → 10 users
2. **Load** (1.5m): Hold 50 users
3. **Ramp-down** (30s): 50 → 0 users

### Metrics

- **Response Times**: p95 < 500ms
- **Error Rate**: < 10%
- **Throughput**: Requests/second

---

## 10. 🔄 Advanced CI/CD Pipeline

### GitHub Actions Workflow

Located at: `.github/workflows/ci-cd.yml`

### Pipeline Stages

1. **Build & Test**
   - Node.js dependency installation
   - Jest unit tests
   - Code coverage reports

2. **Docker Build**
   - Multi-stage build
   - Image optimization
   - Push to registry

3. **Security Scan**
   - Trivy vulnerability scanning
   - OWASP checks
   - Dependency audit

4. **Deploy**
   - Triggered on main branch push
   - Production deployment
   - Health verification

### Setup GitHub Actions

```bash
# Push code to GitHub
git add .
git commit -m "Enterprise DevOps setup"
git push origin main

# Add GitHub Secrets (if using private registry)
# Go to: Settings → Secrets and variables → Actions
# Add: DOCKER_USERNAME, DOCKER_PASSWORD, etc.
```

### Monitor Pipeline

- Go to **Actions** tab in GitHub
- View workflow runs and logs
- Check build status for each commit

---

## 📋 Enhanced docker-compose Setup

### All Services

```yaml
- app: Node.js application with hot reload
- postgres: PostgreSQL database with persistence
- nginx: Reverse proxy and load balancer
- prometheus: Metrics collection
```

### Start All Services

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Check status
docker-compose ps

# Stop services
docker-compose down
```

---

## 🎯 Complete Workflow

### 1. Local Development

```bash
# Setup
npm install
docker-compose up -d

# Test your changes
npm test

# Run linter
npm run lint

# Access application
curl http://localhost:3000/health
```

### 2. Push to GitHub

```bash
git add .
git commit -m "Feature: add new endpoint"
git push origin feature-branch
```

### 3. GitHub Actions

- Tests run automatically
- Docker image builds
- Security scan runs
- Merge when all checks pass

### 4. Deploy to Production

#### Option A: Docker Compose
```bash
# On production server
docker-compose -f docker-compose.yml up -d
```

#### Option B: Kubernetes
```bash
kubectl apply -f kubernetes/
```

#### Option C: Terraform + Ansible
```bash
terraform apply
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

---

## 🔗 Useful URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Application | http://localhost:3000 | Main app |
| Health Check | http://localhost:3000/health | Status |
| API Docs | http://localhost:3000/api/docs | Swagger UI |
| Metrics | http://localhost:3000/metrics | Prometheus metrics |
| Nginx | http://localhost | Load balancer |
| Postgres | localhost:5432 | Database |
| Prometheus | http://localhost:9090 | Metrics dashboard |
| Grafana | http://localhost:3001 | Grafana (if running) |

---

## 🚨 Troubleshooting

### Application won't start

```bash
# View logs
docker-compose logs app

# Check dependencies installed
cd app && npm install

# Rebuild image
docker-compose build --no-cache
```

### Database connection error

```bash
# Ensure postgres is running
docker-compose ps postgres

# Check logs
docker-compose logs postgres

# Verify connection
docker-compose exec postgres psql -U devops_user -d devops_app
```

### Port conflicts

```bash
# Kill process on port
lsof -i :3000
kill -9 <PID>

# Or use different port in docker-compose.yml
```

---

## 📚 Next Steps for College Approval

✅ **Implemented**:
- Unit tests with Jest
- Code quality with ESLint
- Database integration
- API documentation
- Security hardening
- Monitoring setup
- Kubernetes manifests
- Terraform IaC
- Ansible playbooks
- Advanced CI/CD

🎯 **For Presentation**:
1. Demonstrate local development setup
2. Show test coverage report
3. Show Swagger API documentation
4. Demonstrate monitoring dashboard
5. Explain CI/CD pipeline flow
6. Showcase Kubernetes deployment
7. Explain security features
8. Show load testing results

---

**Last Updated**: April 2026
**Version**: 2.0 (Enterprise Edition)
