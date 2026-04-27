# Kubernetes Demo Guide - Tourism Website

Complete guide to set up and demonstrate Kubernetes working for your tourism website project.

## Prerequisites

Before starting, ensure you have:
- **Docker Desktop** with Kubernetes enabled (recommended for local development)
- **kubectl** installed: `kubectl version --client`
- **Docker** installed: `docker --version`
- **4GB RAM** available for Kubernetes cluster
- **Terminal/Command Prompt** access

### Enable Kubernetes in Docker Desktop (Windows)
1. Open Docker Desktop
2. Go to Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Click "Apply & Restart"
5. Wait for the cluster to start (2-5 minutes)
6. Verify: `kubectl cluster-info`

---

## Step 1: Build Docker Image

```bash
# Navigate to project directory
cd c:\Users\abhir\OneDrive\Desktop\devops

# Build the Docker image
docker build -t tourism-website:latest .

# Verify the image was created
docker images | grep tourism-website
```

**Expected Output:**
```
REPOSITORY              TAG       IMAGE ID      CREATED        SIZE
tourism-website         latest    abc123def     2 minutes ago   45MB
```

---

## Step 2: Deploy to Kubernetes

### 2.1 Create Deployment
```bash
# Apply the deployment configuration
kubectl apply -f kubernetes/deployment.yaml

# Watch deployment progress
kubectl rollout status deployment/tourism-website --timeout=5m

# View deployment details
kubectl get deployment tourism-website -o wide
```

**Expected Output:**
```
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
tourism-website      3/3     3            3           2m
```

### 2.2 Create Service
```bash
# Apply the service configuration
kubectl apply -f kubernetes/service.yaml

# View services
kubectl get service tourism-website
```

**Expected Output:**
```
NAME               TYPE          CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
tourism-website    LoadBalancer  10.96.123.45   localhost     80:30123/TCP   1m
```

---

## Step 3: Verify Pods are Running

```bash
# List all pods
kubectl get pods -l app=tourism-website

# View pod details
kubectl get pods -l app=tourism-website -o wide

# Check specific pod
kubectl describe pod <pod-name>

# View pod logs
kubectl logs -l app=tourism-website --all-containers=true

# Stream logs from a pod
kubectl logs -l app=tourism-website -f
```

**Expected Output:**
```
NAME                               READY   STATUS    RESTARTS   AGE
tourism-website-5c8d7f6c4b-abc12   1/1     Running   0          2m
tourism-website-5c8d7f6c4b-def45   1/1     Running   0          2m
tourism-website-5c8d7f6c4b-ghi78   1/1     Running   0          2m
```

---

## Step 4: Test the Deployment

### 4.1 Port Forward to Access Service
```bash
# Forward local port 8080 to service port 80
kubectl port-forward svc/tourism-website 8080:80

# In another terminal, test endpoints
curl http://localhost:8080/
curl http://localhost:8080/about.html
curl http://localhost:8080/destination.html
curl http://localhost:8080/health
```

### 4.2 Access from Browser
- Main page: `http://localhost:8080`
- About page: `http://localhost:8080/about.html`
- Destination page: `http://localhost:8080/destination.html`
- Health check: `http://localhost:8080/health`

---

## Step 5: Monitor and Verify Health

```bash
# Check health probes
kubectl get pod <pod-name> -o jsonpath='{.status.conditions[*]}'

# View resource usage (requires metrics-server)
kubectl top nodes
kubectl top pods -l app=tourism-website

# Check events
kubectl get events --sort-by='.lastTimestamp'

# View HPA status
kubectl get hpa tourism-website-hpa
```

---

## Step 6: Scale and Load Testing

### 6.1 Manual Scaling
```bash
# Scale to 5 replicas
kubectl scale deployment tourism-website --replicas=5

# Watch scaling in progress
kubectl get pods -l app=tourism-website -w

# Scale back to 3
kubectl scale deployment tourism-website --replicas=3
```

### 6.2 Check HPA (Horizontal Pod Autoscaler)
```bash
# View HPA status
kubectl get hpa tourism-website-hpa

# Monitor HPA in real-time
kubectl get hpa tourism-website-hpa -w

# View HPA details
kubectl describe hpa tourism-website-hpa
```

### 6.3 Generate Load (Optional)
```bash
# Install Apache Bench if not available
# Then run:
ab -n 1000 -c 10 http://localhost:8080/

# Or use the following script:
# while true; do curl http://localhost:8080 > /dev/null 2>&1; done
```

---

## Step 7: Cleanup

```bash
# Delete service (includes LoadBalancer cleanup)
kubectl delete service tourism-website

# Delete deployment (removes all pods)
kubectl delete deployment tourism-website

# Delete HPA
kubectl delete hpa tourism-website-hpa

# Delete network policy (if created)
kubectl delete networkpolicy tourism-website-netpol

# Verify deletion
kubectl get all -l app=tourism-website
```

---

## Complete Verification Script

Run this script to verify everything is working:

```bash
#!/bin/bash

echo "=== Kubernetes Deployment Verification ==="
echo ""

echo "1. Checking Kubernetes Cluster..."
kubectl cluster-info
echo ""

echo "2. Checking Deployments..."
kubectl get deployment tourism-website
echo ""

echo "3. Checking Pods..."
kubectl get pods -l app=tourism-website
echo ""

echo "4. Checking Services..."
kubectl get service tourism-website
echo ""

echo "5. Pod Details..."
kubectl get pods -l app=tourism-website -o wide
echo ""

echo "6. Checking Pod Health..."
kubectl get pod -l app=tourism-website -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}'
echo ""

echo "7. Checking HPA..."
kubectl get hpa tourism-website-hpa
echo ""

echo "8. Resource Usage..."
kubectl top pods -l app=tourism-website 2>/dev/null || echo "Note: Metrics not available. Install metrics-server for resource monitoring."
echo ""

echo "✅ Verification Complete!"
```

---

## Troubleshooting

### Issue: Pods stuck in "Pending" state
```bash
# Check cluster resources
kubectl describe node

# Check pod events
kubectl describe pod <pod-name>

# Solution: May need more resources or image not available
docker load < <image-file> # if using local image
```

### Issue: Pod crashes or "CrashLoopBackOff"
```bash
# Check pod logs
kubectl logs <pod-name>

# Check previous logs
kubectl logs <pod-name> --previous

# Check events
kubectl describe pod <pod-name>
```

### Issue: Service not reachable
```bash
# Check service endpoints
kubectl get endpoints tourism-website

# Verify pod is running
kubectl get pods -l app=tourism-website

# Check service configuration
kubectl describe service tourism-website
```

### Issue: Image pull error
```bash
# Ensure image is built locally
docker build -t tourism-website:latest .

# Set imagePullPolicy to IfNotPresent in deployment.yaml (already set)
```

---

## Dashboard (Optional)

View Kubernetes resources in GUI:

```bash
# Start Kubernetes Dashboard (if available)
kubectl proxy

# Access at: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

# Or use Lens (IDE for Kubernetes)
# Download from: https://k8slens.dev/
```

---

## Next Steps

1. **Network Policy**: Enable network policies (already configured in service.yaml)
2. **Ingress**: Configure Ingress controller for domain-based routing
3. **TLS/SSL**: Set up Let's Encrypt with cert-manager
4. **Monitoring**: Add Prometheus + Grafana for metrics
5. **Logging**: Add ELK Stack or similar for centralized logging

---

## Quick Reference Commands

```bash
# Deployment
kubectl apply -f kubernetes/deployment.yaml
kubectl get deployment
kubectl describe deployment tourism-website
kubectl rollout status deployment/tourism-website
kubectl rollout restart deployment/tourism-website

# Pods
kubectl get pods
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/sh
kubectl port-forward <pod-name> 8080:80

# Service
kubectl apply -f kubernetes/service.yaml
kubectl get service
kubectl describe service tourism-website

# Scaling
kubectl scale deployment tourism-website --replicas=5
kubectl autoscale deployment tourism-website --min=2 --max=10

# Cleanup
kubectl delete all -l app=tourism-website
```

---

## Project Tools Overview

This project includes the following tools and technologies:

| Tool | Purpose | Status |
|------|---------|--------|
| **Docker** | Containerization | ✅ Configured |
| **Kubernetes** | Container Orchestration | ✅ Configured |
| **Terraform** | Infrastructure as Code | ✅ Configured |
| **Jenkins** | CI/CD Pipeline | ✅ Configured |
| **Nginx** | Web Server | ✅ Configured |
| **Prometheus** | Metrics Collection | ✅ Configured (in deployment) |

---

## Contact & Support

For issues or questions, refer to:
- [Deployment Guide](DEPLOYMENT_GUIDE.md)
- [Architecture](ARCHITECTURE.md)
- [Getting Started](GETTING_STARTED.md)
