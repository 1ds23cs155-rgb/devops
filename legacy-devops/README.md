# DevOps Project

A comprehensive DevOps demo project showcasing containerization, CI/CD pipelines, and infrastructure best practices.

## 📋 Project Overview

This project demonstrates key DevOps concepts including:

- **Docker**: Multi-stage builds and containerization
- **Docker Compose**: Local development environment
- **CI/CD**: GitHub Actions pipeline with testing and deployment
- **Jenkins**: Self-hosted CI pipeline support
- **Nginx**: Reverse proxy configuration
- **Health Checks**: Application monitoring
- **Security**: Non-root Docker user, vulnerability scanning

## 🏗️ Project Structure

```
legacy-devops/
├── app/                          # Node.js application
│   ├── package.json
│   └── server.js
├── docker/                       # Docker configuration
│   └── Dockerfile               # Multi-stage build
├── configs/                      # Configuration files
│   └── nginx.conf               # Nginx reverse proxy config
├── scripts/                      # Deployment scripts
│   ├── deploy.sh                # Deployment script
│   └── setup.sh                 # Setup script
├── .github/workflows/           # GitHub Actions CI/CD
│   └── ci-cd.yml                # CI/CD pipeline
├── docker-compose.yml           # Local dev environment
├── .gitignore
└── README.md
```

## 🚀 Quick Start

## 🌍 Tourism Website (moved here)

If you want to keep a single folder, the complete tourism website DevOps stack is now available under `devOPS/tourism-devops/`.

Run it:

```bash
cd /Users/ajayreddy/Desktop/devOPS/tourism-devops
docker-compose up -d --build
```

URLs:
- Website: http://localhost:8080
- Health: http://localhost:8080/health
- Prometheus: http://localhost:8090

After you verify it works, you can delete the old standalone folder:

```bash
rm -rf /Users/ajayreddy/Desktop/tourism-devops
```

### Option 1: Using Docker Compose (Recommended)

```bash
# Clone repository
cd /Users/ajayreddy/Desktop/devOPS/legacy-devops

# Start services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down
```

Access the application at:
- **App**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **API Info**: http://localhost:3000/api/info
- **Nginx Proxy**: http://localhost:80
- **Jenkins UI**: http://localhost:8088

### Jenkins Setup (inside legacy-devops)

```bash
# Start Jenkins with the stack
docker-compose up -d

# Get initial admin password
docker exec legacy-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Then open `http://localhost:8088`, complete setup, and create a Pipeline job that points to the `Jenkinsfile` in this folder.

### Option 2: Local Development

```bash
# Install dependencies
cd app
npm install

# Start application
npm start

# Access at http://localhost:3000
```

### Option 3: Deploy with Script

```bash
# Make deploy script executable
chmod +x scripts/deploy.sh

# Run deployment
./scripts/deploy.sh
```

## 🐳 Docker Commands

```bash
# Build image
docker build -f docker/Dockerfile -t devops-app:latest .

# Run container
docker run -d -p 3000:3000 devops-app:latest

# View logs
docker logs <container-id>

# Stop container
docker stop <container-id>
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci-cd.yml`) includes:

1. **Build & Test**: Node.js dependency installation and testing
2. **Docker Build**: Multi-stage Docker image build
3. **Security Scan**: Trivy vulnerability scanning
4. **Deploy**: Deployment to production (main branch)

### To enable CI/CD:

1. Push code to GitHub repository
2. GitHub Actions automatically runs the workflow
3. View results in the **Actions** tab

## 📊 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Home page |
| `/health` | GET | Health check (for monitoring) |
| `/api/info` | GET | API information |

## 🔒 Security Features

- ✅ Non-root Docker user
- ✅ Health checks for container monitoring
- ✅ Vulnerability scanning (Trivy)
- ✅ Multi-stage builds for reduced image size
- ✅ .gitignore for sensitive files

## 📝 Environment Variables

Create `.env` file in the root directory:

```env
NODE_ENV=production
PORT=3000
```

## 🛠️ Useful Commands

```bash
# Setup project
chmod +x scripts/setup.sh
./scripts/setup.sh

# Deploy application
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Check Docker Compose status
docker-compose ps

# View container logs
docker-compose logs app

# Access container shell
docker-compose exec app sh

# Rebuild without cache
docker-compose build --no-cache
```

## 📚 Further Learning

- **Docker Docs**: https://docs.docker.com
- **Docker Compose**: https://docs.docker.com/compose
- **GitHub Actions**: https://github.com/features/actions
- **Nginx**: https://nginx.org/en/docs

## 🎓 Project Ideas for Enhancement

1. Add Kubernetes manifests (Deployment, Service)
2. Add Prometheus/Grafana monitoring
3. Add ELK stack for logging
4. Add Terraform for infrastructure as code
5. Add Ansible playbooks for configuration management
6. Add SonarQube for code quality
7. Add performance testing
8. Add database integration (PostgreSQL/MongoDB)

## 👤 Author

Created for college DevOps project

## 📄 License

MIT

---

## Troubleshooting

### Port already in use
```bash
# Change port in docker-compose.yml or use:
docker-compose down
```

### Container won't start
```bash
# Check logs
docker-compose logs app

# Rebuild image
docker-compose build --no-cache
```

### Permission denied on scripts
```bash
chmod +x scripts/*.sh
```

---

**Last Updated**: 2026-04-03
