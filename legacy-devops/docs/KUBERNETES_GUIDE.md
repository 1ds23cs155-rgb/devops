# Kubernetes Deployment Guide

## Overview

Kubernetes manifests for deploying the DevOps application with production-grade features.

## Files

- `deployment.yaml` - Pod deployment specification
- `service.yaml` - Service, ConfigMap, Secret, and ServiceAccount
- `ingress.yaml` - Ingress controller and HPA

## Prerequisites

```bash
# Install kubectl
kubectl version --client

# Ensure cluster is running
kubectl cluster-info

# Verify nodes
kubectl get nodes
```

## Quick Start

### 1. Create Secrets and ConfigMaps

```bash
kubectl apply -f kubernetes/service.yaml
```

### 2. Deploy Application

```bash
kubectl apply -f kubernetes/deployment.yaml
```

### 3. Setup Ingress & Auto-scaling

```bash
kubectl apply -f kubernetes/ingress.yaml
```

### 4. Monitor Deployment

```bash
# Watch deployment progress
kubectl rollout status deployment/devops-app

# View pods
kubectl get pods -l app=devops-app

# View ReplicaSet
kubectl get replicasets -l app=devops-app

# View service
kubectl get service devops-app-service
```

## Access Application

### Port Forward

```bash
# Forward port 8080 locally to service port 80
kubectl port-forward svc/devops-app-service 8080:80

# Access at http://localhost:8080
```

### Load Balancer IP

```bash
# Get external IP
kubectl get service devops-app-service

# Will show something like: 35.192.100.10
# Access at: http://35.192.100.10
```

### Ingress

```bash
# Get Ingress IP
kubectl get ingress devops-app-ingress

# Add to hosts file (if not using DNS)
echo "35.192.100.10 devops.example.com" >> /etc/hosts

# Access at: http://devops.example.com
```

## Health Checks

### Liveness Probe
- Checks if container is alive
- Restarts container if fails
- Endpoint: `/health`
- Failure threshold: 3

### Readiness Probe
- Checks if container is ready for traffic
- Removes from service if fails
- Endpoint: `/health`
- Failure threshold: 2

## Horizontal Pod Autoscaler (HPA)

Automatically scales pods based on metrics.

### Configuration

```yaml
minReplicas: 2
maxReplicas: 10
targetCPUUtilizationPercentage: 70
targetMemoryUtilizationPercentage: 80
```

### Monitor HPA

```bash
# View HPA status
kubectl get hpa devops-app-hpa

# Watch autoscaling
kubectl get hpa devops-app-hpa -w

# View detailed metrics
kubectl describe hpa devops-app-hpa
```

## Scaling

### Manual Scaling

```bash
# Scale to 5 replicas
kubectl scale deployment devops-app --replicas=5

# Verify
kubectl get pods
```

### View Resource Metrics

```bash
# Install metrics-server if needed
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View resource usage
kubectl top nodes
kubectl top pods
```

## Updating Deployment

### Rolling Update

```bash
# Update image
kubectl set image deployment/devops-app app=devops-app:v1.0.1

# Monitor rollout
kubectl rollout status deployment/devops-app

# View history
kubectl rollout history deployment/devops-app
```

### Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/devops-app

# Rollback to specific revision
kubectl rollout undo deployment/devops-app --to-revision=2
```

## Logging & Debugging

### View Logs

```bash
# Recent logs
kubectl logs deployment/devops-app

# Stream logs
kubectl logs -f deployment/devops-app

# All replicas
kubectl logs -l app=devops-app --all-containers=true
```

### Execute Commands

```bash
# Shell into container
kubectl exec -it deployment/devops-app -- /bin/sh

# Run command
kubectl exec deployment/devops-app -- wget -O- http://localhost:3000/health
```

### Describe Resources

```bash
# Deployment details
kubectl describe deployment devops-app

# Pod details
kubectl describe pod <pod-name>

# Events
kubectl get events --sort-by='.lastTimestamp'
```

## Secrets & ConfigMaps

### View Current Values

```bash
# ConfigMap
kubectl get configmap devops-config -o yaml

# Secret (base64 encoded)
kubectl get secret devops-secrets -o yaml

# Secret (decoded)
kubectl get secret devops-secrets -o jsonpath='{.data.db\.username}' | base64 -d
```

### Update Secrets

```bash
# Edit secret
kubectl edit secret devops-secrets

# Or use kubectl patch
kubectl patch secret devops-secrets -p \
  '{"data":{"jwt.secret":"'$(echo -n "new-secret" | base64)'"}}'
```

## Service Accounts & RBAC

### Current Setup

- Namespace: `default`
- ServiceAccount: `devops-app`
- Role: Minimal (can be customized)

### Create Custom Role (Optional)

```bash
kubectl create role <role-name> --verb=get,list --resource=pods
kubectl create rolebinding <binding-name> --role=<role-name> --serviceaccount=default:devops-app
```

## Networking

### Network Policies (Optional)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: devops-app-policy
spec:
  podSelector:
    matchLabels:
      app: devops-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 3000
```

## Cleanup

### Delete Specific Resources

```bash
# Delete deployment
kubectl delete deployment devops-app

# Delete service
kubectl delete service devops-app-service

# Delete all at once
kubectl delete -f kubernetes/
```

### Delete Entire Namespace

```bash
# Delete namespace (removes all resources)
kubectl delete namespace default
```

## Production Checklist

- [ ] Use specific image versions (not `latest`)
- [ ] Set resource requests/limits
- [ ] Configure readiness/liveness probes
- [ ] Setup HPA for autoscaling
- [ ] Use Ingress for external access
- [ ] Configure network policies
- [ ] Setup monitoring (Prometheus)
- [ ] Configure centralized logging
- [ ] Use HTTPS/TLS
- [ ] Regular backups of data
- [ ] Pod security policies
- [ ] Secrets encryption at rest

## Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

