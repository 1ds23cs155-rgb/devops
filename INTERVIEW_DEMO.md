# Interview Demo (Tourism DevOps Stack)

This is a **5–10 minute interview walkthrough** to prove you included Docker, Compose, Nginx, Prometheus monitoring, Kubernetes, Terraform, and CI/CD.

## 0) 20-second pitch

- Static tourism site packaged as a **Docker image**
- Locally orchestrated with **Docker Compose**
- Traffic routed via **Nginx reverse proxy / load balancer**
- **Prometheus** included for monitoring
- **Kubernetes** manifests + **Terraform** infra code included for cloud/cluster deployment
- **GitHub Actions** workflow included for CI/CD

## 1) Fast “evidence map” (what files to open)

- Docker
  - `Dockerfile`
  - `docker-compose.yml`
- Nginx
  - `nginx.conf` — load balancer / reverse proxy
  - `nginx.website.conf` — website container serves static HTML
- Monitoring
  - `monitoring/prometheus.yml`
- Kubernetes
  - `kubernetes/` (Deployment/Service/HPA/Ingress/NetworkPolicy)
- Terraform
  - `terraform/`
- CI/CD
  - `.github/workflows/ci-cd.yml`

## 2) Live demo (local) — 3 minutes

From the repo root:

- `docker-compose up -d --build`
- `docker-compose ps`

Show the website:

- Open: `http://localhost:8080/`
- Or in terminal:
  - `curl -i http://localhost:8080/`
  - `curl -i http://localhost:8080/about.html`
  - `curl -i http://localhost:8080/health`

Show monitoring:

- Open: `http://localhost:8090/`
- Readiness:
  - `curl -i http://localhost:8090/-/ready`

## 3) Nginx load balancing proof — 60 seconds

What to say:

- “The website container is a pure static Nginx server.”
- “The `nginx` service is a reverse proxy that routes all requests to the website service.”

What to show:

- Open `nginx.conf` and point to `proxy_pass`.
- Open `docker-compose.yml` and show `nginx` exposes `8080:80`.

## 4) CI/CD proof — 60 seconds

- Open `.github/workflows/ci-cd.yml`.
- Say: “Push triggers build, scan, and image build; deploy steps are structured for staging/production.”

Best proof:

- GitHub repo → Actions tab → open a run (green checks)

## 5) Kubernetes proof — 60 seconds

No cluster required:

- `kubectl apply --dry-run=client -f kubernetes/`

If you have a cluster (optional):

- `kubectl apply -f kubernetes/`
- `kubectl get pods,svc`

## 6) Terraform proof — 60 seconds

Safe commands (no AWS apply needed):

- `cd terraform`
- `terraform fmt -check`
- `terraform init -backend=false`
- `terraform validate`

If AWS creds exist (optional):

- `terraform plan`

## 7) Close: “what I can explain confidently”

- Docker image build and healthchecks
- Compose orchestration + port mapping
- Nginx reverse proxy basics
- Prometheus readiness and target scraping
- K8s objects and rolling updates
- Terraform plan/apply workflow
