# DevOps Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  User / Browser                          │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   Nginx (Port 80)      │
        │  Reverse Proxy         │
        └────────────┬───────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   Node.js App          │
        │   (Port 3000)          │
        │                        │
        │  - Express Server      │
        │  - Routes              │
        │  - Health Check        │
        └────────────────────────┘
```

## Deployment Flow

```
Developer
    │
    ├─► Push Code to GitHub
    │
    ▼
GitHub Actions (CI/CD Pipeline)
    │
    ├─► 1. Build & Test
    ├─► 2. Build Docker Image
    ├─► 3. Security Scan (Trivy)
    └─► 4. Deploy (if main branch)
    │
    ▼
Production Environment
    │
    ├─► Docker Container
    └─► Running Application
```

## Local Development Environment (Docker Compose)

```
docker-compose up
    │
    ├─► Service: app
    │   ├─► Node.js application
    │   ├─► Volume mount for live reloading
    │   └─► Environment: development
    │
    └─► Service: nginx
        ├─► Reverse proxy
        └─► Port 80 → app:3000
```

## Docker Image Layers (Multi-stage Build)

```
Stage 1: Builder
├─ Base: node:18-alpine
├─ Install dependencies
└─ Output: node_modules

Stage 2: Runtime
├─ Base: node:18-alpine (fresh)
├─ Copy node_modules from builder
├─ Copy application code
├─ Health check setup
└─ Output: Final production image
```

## File Structure & Responsibilities

| Directory | Purpose |
|-----------|---------|
| `app/` | Node.js application code |
| `docker/` | Dockerfile and Docker configs |
| `configs/` | Configuration files (nginx.conf) |
| `scripts/` | Deployment and setup scripts |
| `.github/workflows/` | GitHub Actions CI/CD pipelines |
| `docs/` | Documentation |

## Key Technologies

| Technology | Version | Purpose |
|-----------|--------|---------|
| Node.js | 18-alpine | Application runtime |
| Express | 4.18+ | Web framework |
| Docker | Latest | Containerization |
| Docker Compose | 3.8 | Local orchestration |
| Nginx | Alpine | Reverse proxy |
| GitHub Actions | - | CI/CD automation |
| Trivy | - | Security scanning |

## Environment Stages

### Development
- Local machine with Docker Compose
- Hot reloading enabled
- Full logging
- NODE_ENV=development

### Production
- Optimized Docker image
- Multi-stage build
- Health checks enabled
- NODE_ENV=production

## Monitoring & Health Checks

### Container Health Check
```
Endpoint: http://localhost:3000/health
Interval: 30 seconds
Timeout: 3 seconds
Retries: 3
```

### Response Example
```json
{
  "status": "healthy",
  "timestamp": "2026-04-03T10:30:00.000Z",
  "uptime": 300.45
}
```

## Security Measures

1. **Non-Root User**: Application runs as `nodejs:1001`
2. **Health Checks**: Automatic restart on failure
3. **Vulnerability Scanning**: Trivy in CI/CD
4. **Multi-Stage Builds**: Reduced attack surface
5. **Environment Variables**: Sensitive data not in code
6. **.gitignore**: Secrets not committed

## Scaling Considerations

### Horizontal Scaling (Multiple Instances)
- Run multiple app containers
- Use load balancer (Nginx, HAProxy)
- Share storage for stateless design

### Vertical Scaling
- Increase CPU/Memory allocation
- Optimize Docker resource limits

### Database (Future)
- Add PostgreSQL/MongoDB service in docker-compose
- Use environment variables for connection strings

## CI/CD Pipeline Stages

```
1. Build & Test
   └─ npm ci && npm test

2. Docker Build
   └─ Multi-stage build, push to registry

3. Security Scan
   └─ Trivy filesystem and image scanning

4. Deploy (main branch only)
   └─ Trigger deployment script
```

## Network Configuration

### Docker Compose Network
- App service: `app:3000` (internal)
- Nginx service: `nginx:80` (exposed)
- Auto DNS resolution between services

### Port Mappings
| Service | Internal | External |
|---------|----------|----------|
| App | 3000 | 3000 |
| Nginx | 80 | 80 |

---

See [README.md](../README.md) for quick start instructions.
