#!/usr/bin/env pwsh

# Kubernetes Tourism Website Deployment Verification Script
# Run this script to verify your Kubernetes deployment is working correctly

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Kubernetes Deployment Verification" -ForegroundColor Cyan
Write-Host "Tourism Website Project" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Color functions
function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-ErrorMsg { Write-Host "[ERROR] $args" -ForegroundColor Red }
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Blue }
function Write-WarningMsg { Write-Host "[WARN] $args" -ForegroundColor Yellow }

# Step 1: Check kubectl
Write-Info "Step 1: Checking kubectl installation..."
try {
    $kubectlVersion = kubectl version --client --short 2>$null
    Write-Success "kubectl is installed"
    Write-Host "  $kubectlVersion"
} catch {
    Write-ErrorMsg "kubectl is not installed or not in PATH"
    Write-Info "Install kubectl from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
}
Write-Host ""

# Step 2: Check cluster connectivity
Write-Info "Step 2: Checking Kubernetes cluster..."
try {
    $clusterInfo = kubectl cluster-info 2>$null
    Write-Success "Connected to Kubernetes cluster"
    Write-Host "  $($clusterInfo[0])"
} catch {
    Write-ErrorMsg "Cannot connect to Kubernetes cluster"
    Write-WarningMsg "Make sure Kubernetes is running (Docker Desktop or Minikube)"
    exit 1
}
Write-Host ""

# Step 3: Check deployment
Write-Info "Step 3: Checking Deployment..."
$deployment = kubectl get deployment tourism-website -o json 2>$null | ConvertFrom-Json
if ($deployment.metadata.name -eq "tourism-website") {
    Write-Success "Deployment 'tourism-website' exists"
    $ready = $deployment.status.readyReplicas
    $desired = $deployment.spec.replicas
    Write-Host "  Replicas: $ready/$desired ready"
    
    if ($ready -eq $desired) {
        Write-Success "All replicas are ready"
    } else {
        Write-WarningMsg "Some replicas are not ready yet. Wait a moment..."
    }
} else {
    Write-ErrorMsg "Deployment 'tourism-website' not found"
    Write-Info "Run: kubectl apply -f kubernetes/deployment.yaml"
}
Write-Host ""

# Step 4: Check pods
Write-Info "Step 4: Checking Pods..."
$pods = kubectl get pods -l app=tourism-website -o json 2>$null | ConvertFrom-Json
$podCount = $pods.items.Count
if ($podCount -gt 0) {
    Write-Success "$podCount pod(s) found"
    foreach ($pod in $pods.items) {
        $status = $pod.status.phase
        $name = $pod.metadata.name
        $statusSymbol = if ($status -eq "Running") { "[*]" } else { "[X]" }
        Write-Host "  $statusSymbol $name - Status: $status"
    }
} else {
    Write-ErrorMsg "No pods found for tourism-website"
}
Write-Host ""

# Step 5: Check service
Write-Info "Step 5: Checking Service..."
$service = kubectl get service tourism-website -o json 2>$null | ConvertFrom-Json
if ($service.metadata.name -eq "tourism-website") {
    Write-Success "Service 'tourism-website' exists"
    Write-Host "  Type: $($service.spec.type)"
    Write-Host "  Port: $($service.spec.ports[0].port) → $($service.spec.ports[0].targetPort)"
} else {
    Write-ErrorMsg "Service 'tourism-website' not found"
    Write-Info "Run: kubectl apply -f kubernetes/service.yaml"
}
Write-Host ""

# Step 6: Check pod readiness
Write-Info "Step 6: Checking Pod Health..."
$allReady = $true
foreach ($pod in $pods.items) {
    $name = $pod.metadata.name
    $conditions = $pod.status.conditions
    $isReady = $conditions | Where-Object { $_.type -eq "Ready" -and $_.status -eq "True" }
    
    if ($isReady) {
        Write-Success "$name is healthy"
    } else {
        Write-WarningMsg "$name is not ready yet"
        $allReady = $false
    }
}

if ($allReady) {
    Write-Host ""
    Write-Success "All pods are healthy!"
} else {
    Write-Host ""
    Write-WarningMsg "Some pods are still starting. Please wait..."
}
Write-Host ""

# Step 7: Test connectivity
Write-Info "Step 7: Testing Connectivity..."
try {
    # Check if service has an endpoint
    $endpoints = kubectl get endpoints tourism-website -o json 2>$null | ConvertFrom-Json
    if ($endpoints.subsets.Count -gt 0) {
        Write-Success "Service endpoints are available"
        Write-Host "  Endpoints: $($endpoints.subsets.addresses.Count) pod(s)"
    } else {
        Write-WarningMsg "No endpoints available yet"
    }
} catch {
    Write-WarningMsg "Could not check endpoints"
}
Write-Host ""

# Step 8: Provide access instructions
Write-Info "Step 8: Access Instructions..."
Write-Host "
To access your website, use port forwarding:

  kubectl port-forward svc/tourism-website 8080:80

Then open these URLs in your browser:
  - Main page: http://localhost:8080
  - About: http://localhost:8080/about.html
  - Destination: http://localhost:8080/destination.html
  - Health check: http://localhost:8080/health
"

# Step 9: Additional diagnostics
Write-Info "Step 9: Additional Commands..."
Write-Host "
View pod logs:
  kubectl logs -l app=tourism-website -f

Check resources:
  kubectl top pods -l app=tourism-website

Scale deployment:
  kubectl scale deployment tourism-website --replicas=5

Get detailed info:
  kubectl describe deployment tourism-website
  kubectl describe pod <pod-name>

Delete deployment:
  kubectl delete -f kubernetes/deployment.yaml
  kubectl delete -f kubernetes/service.yaml
"

# Final summary
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$issues = 0
if ($ready -ne $desired) { $issues++ }
if ($podCount -eq 0) { $issues++ }

if ($issues -eq 0) {
    Write-Success "Kubernetes deployment is working correctly!"
    Write-Info "Your tourism website is running on 3 replicas with Kubernetes"
} else {
    Write-WarningMsg "There are $issues issue(s) to resolve"
    Write-Info "Check the deployment status and pod logs"
}

Write-Host ""
Write-Info "For more details, see: KUBERNETES_DEMO.md"
Write-Host ""
