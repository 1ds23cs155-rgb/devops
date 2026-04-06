# Interview Demo (DevOps Tools Proof)

This file is a **5–10 minute walkthrough script** you can use to prove you included DevOps tools in this repo.

## 0) 30-second “what this project is”

- A Node.js app packaged with **Docker** and run locally via **Docker Compose**
- A **CI/CD pipeline** via GitHub Actions (tests + scan + build/push)
- Deployment/infra examples via **Kubernetes** manifests + **Terraform** (present in repo)
- Ops support via **Nginx reverse proxy**, health checks, and monitoring assets

## 1) Fast evidence map (what to open in VS Code)

Open these files/folders and say what they do:

- Docker
  - `docker/Dockerfile` — multi-stage container build
  - `docker-compose.yml` — local stack definition
- CI/CD
  - `.github/workflows/ci-cd.yml` — pipeline (build/test, security scan, docker build/push, deploy placeholders)
- Reverse proxy
  - `configs/nginx.conf` — Nginx routing/proxy configuration
- Kubernetes
  - `kubernetes/` — manifests for running the app on a cluster
- Terraform
  - `terraform/` — infrastructure-as-code (cloud provisioning examples)
- Scripts
  - `scripts/deploy.sh` — automation entry-point for deployment steps

## 2) Live demo (local) — 3 minutes

### A) Start the stack

From the repo root:

- `docker-compose up -d --build`
- `docker-compose ps`

### B) Show the app is alive + healthchecked

- `curl -i http://localhost:3000/health`
- `curl -i http://localhost:3000/api/info`

If you also expose Nginx locally:

- `curl -i http://localhost/`

### C) Prove containerization + runtime behavior

- `docker images | head`
- `docker-compose logs -n 50 app`
- `docker stats --no-stream`

## 3) CI/CD proof — 60 seconds

What to say:

- “Every push/PR triggers Build+Test and Security Scan.”
- “On push it can build and publish an image to GHCR.”

What to show:

- Open `.github/workflows/ci-cd.yml` and point to these jobs:
  - Build & Test (matrix Node 18/20)
  - Trivy scan output as SARIF
  - Docker Buildx build + optional push

Best visual proof:

- Your GitHub repo → **Actions tab** → open a recent run → show green checks and artifacts.

## 4) Kubernetes proof — 60 seconds

What to say:

- “This repo includes manifests that can deploy the same container on a cluster.”

What to do (no cluster required):

- `kubectl apply --dry-run=client -f kubernetes/`

If you have a local cluster (optional):

- `kubectl apply -f kubernetes/`
- `kubectl get pods`
- `kubectl port-forward svc/<service-name> 8080:80`

## 5) Terraform proof — 60 seconds

What to say:

- “Infrastructure is defined as code; changes are reviewable via plan output.”

What to do (safe commands):

- `cd terraform`
- `terraform fmt -check`
- `terraform init -backend=false`
- `terraform validate`

If you have credentials configured (optional):

- `terraform plan`

## 6) Monitoring / Ops proof — 30 seconds

- Point to health endpoints and Nginx config.
- Mention container logs and `docker stats` as basic runtime observability.

## 7) Close (what you learned)

Use one line each:

- Docker: image build, non-root, healthchecks
- Compose: multi-container local orchestration
- CI/CD: automated tests + security scans + image build
- K8s: declarative deployment model
- Terraform: reproducible infra with plan/apply
