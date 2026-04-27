# Jenkins Pipeline Setup Guide - Step by Step 🚀

This guide will help you set up a complete CI/CD pipeline using Jenkins for the Tourism Website DevOps project.

---

## 📋 Prerequisites

Before starting, ensure you have:

- ✅ Jenkins installed (v2.346+)
- ✅ Docker installed on Jenkins server
- ✅ Kubernetes cluster running (for K8s deployments)
- ✅ Git installed
- ✅ GitHub account with push access to `https://github.com/1ds23cs155-rgb/devops.git`
- ✅ GitHub Personal Access Token with `repo` and `workflow` scopes
- ✅ Docker Hub account (optional, for image registry)

---

## 🎯 Step 1: Access Jenkins Dashboard

### Option A: Local Jenkins
```bash
# Navigate to Jenkins in your browser
http://localhost:8080
```

### Option B: Jenkins in Docker
```bash
# If running Jenkins in Docker
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

### Initial Setup
1. Get the initial admin password:
   ```bash
   # For Docker
   docker logs <jenkins-container-id> | grep "Initial Admin Password"
   ```

2. Enter the password in Jenkins UI
3. Complete the initial setup wizard
4. Install suggested plugins
5. Create an admin user account

---

## 🔐 Step 2: Configure GitHub Credentials

### 2.1 Create GitHub Personal Access Token

1. Go to GitHub: `https://github.com/settings/tokens`
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. **Settings:**
   - Token name: `Jenkins-DevOps-Token`
   - Expiration: `90 days` (or your preference)
   - **Scopes:**
     ✅ `repo` (Full control of private repositories)
     ✅ `workflow` (Update GitHub Action workflows)
4. Click **"Generate token"**
5. **Copy and save the token securely** (you can't view it again!)

### 2.2 Add Credentials to Jenkins

1. In Jenkins Dashboard, click **"Manage Jenkins"**
2. Click **"Manage Credentials"**
3. Click **"(global)"** domain
4. Click **"Add Credentials"** (top-left)
5. **Configure:**
   - Kind: `Username with password`
   - Username: Your GitHub username
   - Password: Paste the token from Step 2.1
   - ID: `github-credentials`
   - Description: `GitHub DevOps Repository Credentials`
6. Click **"Create"**

### 2.3 Add Docker Hub Credentials (Optional)

For pushing Docker images to Docker Hub:

1. Click **"Add Credentials"** again
2. **Configure:**
   - Kind: `Username with password`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password or access token
   - ID: `docker-hub-credentials`
   - Description: `Docker Hub Registry Credentials`
3. Click **"Create"**

---

## ⚙️ Step 3: Configure Jenkins System Settings

### 3.1 GitHub Plugin Configuration

1. Go to **"Manage Jenkins"** → **"Configure System"**
2. Scroll to **"GitHub"** section
3. Click **"Add GitHub Server"**
4. **Configure:**
   - Name: `GitHub-Production`
   - API URL: `https://api.github.com` (or your GitHub Enterprise URL)
   - Credentials: Select `github-credentials` created in Step 2.2
5. Click **"Test connection"** to verify
6. Click **"Save"**

### 3.2 Docker Configuration

1. Go to **"Manage Jenkins"** → **"Configure System"**
2. Scroll to **"Docker"** section (if Docker plugin installed)
3. **Configure:**
   - Docker URL: `unix:///var/run/docker.sock`
   - Registry URL: `https://index.docker.io/v1/`
   - Registry Credentials: Select `docker-hub-credentials`
4. Click **"Save"**

---

## 📦 Step 4: Install Required Jenkins Plugins

1. Go to **"Manage Jenkins"** → **"Manage Plugins"**
2. Go to **"Available"** tab
3. Search and install these plugins:

**Essential:**
- ✅ `Git` - Git plugin
- ✅ `Docker` - Docker integration
- ✅ `Docker Pipeline` - Docker steps in Pipeline
- ✅ `Kubernetes` - Kubernetes integration
- ✅ `Kubernetes CLI` - kubectl commands
- ✅ `GitHub` - GitHub integration
- ✅ `GitHub Branch Source` - GitHub multibranch repos
- ✅ `Pipeline` - Jenkins Pipeline

**Monitoring & Reporting:**
- ✅ `Prometheus metrics` - Export Jenkins metrics to Prometheus
- ✅ `Email Extension Plugin` - Email notifications
- ✅ `Slack Notification` - Slack integration (optional)

**Other Useful:**
- ✅ `AnsiColor` - ANSI color support in logs
- ✅ `Timestamper` - Timestamps in console output
- ✅ `Green Balls` - Better build status icons

After selecting, click **"Install without restart"** or **"Download now and install after restart"**

---

## 🔧 Step 5: Create a New Pipeline Job

### 5.1 Create a New Item

1. Click **"+ New Item"** on the dashboard
2. Enter job name: `DevOps-Tourism-Website-Pipeline`
3. Select **"Pipeline"** (not Freestyle Job)
4. Click **"OK"**

### 5.2 Configure Pipeline Job

#### General Section:
- **Description:** 
  ```
  CI/CD Pipeline for Tourism Website DevOps Project
  - Clones from: https://github.com/1ds23cs155-rgb/devops.git
  - Builds Docker image
  - Tests container
  - Deploys to Kubernetes
  - Sets up monitoring (Prometheus + Grafana)
  ```
- ✅ Check **"GitHub project"**
  - Project url: `https://github.com/1ds23cs155-rgb/devops.git`

#### Build Triggers Section:
Choose one or both:

**Option 1: GitHub Webhook (Automatic on Push)**
- ✅ Check **"GitHub hook trigger for GITscm polling"**
- This will auto-trigger on git push

**Option 2: Poll SCM (Manual Polling)**
- ✅ Check **"Poll SCM"**
- Schedule: `H/15 * * * *` (every 15 minutes)

#### Pipeline Section:
- **Definition:** Select **"Pipeline script from SCM"**
- **SCM:** Select **"Git"**
- **Repository URL:** `https://github.com/1ds23cs155-rgb/devops.git`
- **Credentials:** Select `github-credentials`
- **Branch Specifier:** `*/main`
- **Script Path:** `Jenkinsfile` (default)
- ✅ Check **"Lightweight checkout"**

**Advanced:**
- Timeout: `1 hour`

Click **"Save"**

---

## 🌐 Step 6: Configure GitHub Webhook (For Auto-Triggering)

### 6.1 In GitHub Repository

1. Go to your repo: `https://github.com/1ds23cs155-rgb/devops`
2. Click **"Settings"** → **"Webhooks"**
3. Click **"Add webhook"**
4. **Configure:**
   - **Payload URL:** `http://your-jenkins-url:8080/github-webhook/`
   - **Content type:** `application/json`
   - **Which events would you like to trigger this webhook?**
     - Select: **"Let me select individual events."**
       - ✅ Push events
       - ✅ Pull requests
       - ✅ Releases
   - ✅ **"Active"** checkbox is checked
5. Click **"Add webhook"**

**Test Webhook:**
- Click the webhook
- Click **"Recent Deliveries"**
- Should show successful delivery (green checkmark)

### 6.2 Verify Jenkins Receives Webhook

1. In Jenkins, click on your pipeline job
2. Go to **"Build History"**
3. Make a test push to GitHub:
   ```bash
   cd /path/to/devops
   echo "# Test" >> README.md
   git add README.md
   git commit -m "Test webhook trigger"
   git push origin main
   ```
4. A new build should appear in Jenkins within 10 seconds

---

## ▶️ Step 7: Run Your First Pipeline Build

### 7.1 Manual Trigger

1. Click **"Build Now"** on the job page
2. Click the build number (e.g., `#1`)
3. Click **"Console Output"** to see real-time logs

### 7.2 Monitor Build Progress

You'll see these stages execute:

```
✅ Stage 1: Checkout
   - Clones the repository

✅ Stage 2: Build Image
   - Builds Docker image
   - Executes: docker build -t tourism-website:${BUILD_NUMBER} .

✅ Stage 3: Run Container Smoke Test
   - Starts container
   - Tests health endpoint
   - Cleans up on success/failure

✅ Stage 4: Deploy Monitoring Stack
   - Applies Prometheus ConfigMap
   - Deploys Prometheus
   - Deploys Grafana

✅ Stage 5: Deploy Application to Kubernetes
   - Applies K8s deployment manifest
   - Applies K8s service manifest
   - Waits for rollout completion

✅ Stage 6: Verify Monitoring Stack
   - Health checks for Prometheus
   - Health checks for Grafana
   - Health checks for website

✅ Stage 7: Display Access URLs
   - Shows where to access the services
```

---

## 📊 Step 8: Access Deployed Services

After a successful pipeline run, access:

### Website
```
http://localhost:80
or
http://<K8S-NODE-IP>:<Service-NodePort>
```

### Prometheus (Metrics Collection)
```
http://localhost:9090
```
**Default login:** No authentication required

**Useful queries:**
- `up{job="tourism-website"}` - Check if website is up
- `rate(http_requests_total[5m])` - HTTP request rate
- `container_memory_usage_bytes` - Memory usage

### Grafana (Visualization)
```
http://localhost:3000
```
**Default login:**
- Username: `admin`
- Password: `admin` (change on first login!)

**Setup Grafana Dashboard:**
1. Login to Grafana
2. Click **"+"** → **"Dashboard"**
3. Click **"Add panel"**
4. **Query:** 
   - Data source: `Prometheus`
   - Metrics: `up{job="tourism-website"}`
5. Click **"Save"**

---

## 🔄 Step 9: Continuous Monitoring & Improvement

### 9.1 Monitor Pipeline Metrics

```bash
# View pipeline execution times
# In Jenkins: Metrics are available at:
# http://localhost:8080/prometheus

# Example Prometheus queries:
jenkins_builds_duration_seconds_sum{job="DevOps-Tourism-Website-Pipeline"}
jenkins_builds_success_total
jenkins_builds_failed_total
```

### 9.2 Set Up Alerts

In Grafana:
1. Create alert rules in **"Alerts"** menu
2. Configure notification channels
3. Set alert thresholds

Example Alert Rules (already in `alert_rules.yml`):
- Website down > 2 minutes
- High CPU usage > 80%
- High memory usage > 85%
- Container restart loops
- High HTTP error rate

### 9.3 Scale Your Deployment

```bash
# Scale the deployment
kubectl scale deployment tourism-website --replicas=3

# Monitor scaling
kubectl get pods -o wide
```

---

## 🛠️ Step 10: Troubleshooting

### Issue: Build fails at "Checkout" stage

**Solution:**
```bash
# Check Git credentials
# Go to Jenkins: Manage Jenkins → Manage Credentials
# Verify github-credentials are set correctly

# Test manually:
git clone https://github.com/1ds23cs155-rgb/devops.git
cd devops
ls -la
```

### Issue: Docker build fails

**Solution:**
```bash
# Ensure Docker is running
docker ps

# Check Docker daemon accessibility
docker info

# If Jenkins runs in container, ensure socket mount:
docker run ... -v /var/run/docker.sock:/var/run/docker.sock ...
```

### Issue: Health check fails

**Solution:**
```bash
# Check if /health endpoint exists
docker run -it <image-id> bash
curl http://localhost/health

# If not found, add health endpoint to application
# Or update DEPLOYMENT.md with endpoint info
```

### Issue: Kubernetes deployment fails

**Solution:**
```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes

# Check KUBECONFIG path in Jenkinsfile
# Ensure Jenkins has access to kubeconfig

# Test kubectl from Jenkins:
# Click "Build now" → "Console Output" → Check kubectl commands
```

### Issue: Prometheus/Grafana not accessible

**Solution:**
```bash
# Check if pods are running
kubectl get pods -l app=prometheus,grafana

# Check pod logs
kubectl logs deployment/prometheus
kubectl logs deployment/grafana

# Check service endpoints
kubectl get svc
```

---

## 📝 Step 11: Best Practices

### Security
- 🔐 Never commit secrets to Git
- 🔐 Use Jenkins credentials for sensitive data
- 🔐 Rotate GitHub Personal Access Tokens regularly
- 🔐 Use branch protection rules on `main` branch

### Performance
- ⚡ Enable "Lightweight checkout" in Pipeline
- ⚡ Use Docker image caching
- ⚡ Implement artifact cleanup (post build)

### Reliability
- 🛡️ Add timeout to stages (prevents hanging builds)
- 🛡️ Implement proper health checks
- 🛡️ Set up notifications for build failures
- 🛡️ Monitor disk space on Jenkins server

### Maintenance
- 📋 Review build logs regularly
- 📋 Clean up old builds: Configure job → Discard old builds
- 📋 Update plugins monthly
- 📋 Backup Jenkins configuration:
  ```bash
  tar -czf jenkins_backup_$(date +%Y%m%d).tar.gz /var/jenkins_home/
  ```

---

## 🎓 Advanced Configurations

### Multi-Branch Pipeline

For multiple environments (dev, staging, prod):

1. Create a new job with type "Multibranch Pipeline"
2. Configure to scan all branches
3. Jenkins will auto-create jobs for each branch
4. Use different Jenkinsfile logic per branch

### Docker Registry Push

Add to Jenkinsfile:

```groovy
stage('Push to Registry') {
  steps {
    script {
      sh '''
        docker login -u $DOCKER_USER -p $DOCKER_PASS
        docker tag tourism-website:${BUILD_NUMBER} $DOCKER_USER/tourism-website:${BUILD_NUMBER}
        docker push $DOCKER_USER/tourism-website:${BUILD_NUMBER}
      '''
    }
  }
}
```

### Slack Notifications

Add to Jenkinsfile:

```groovy
post {
  success {
    slackSend(channel: '#deployments', message: 'Build SUCCESS ✅', color: 'good')
  }
  failure {
    slackSend(channel: '#deployments', message: 'Build FAILED ❌', color: 'danger')
  }
}
```

---

## 📚 Additional Resources

- **Jenkins Pipeline Documentation:** https://www.jenkins.io/doc/book/pipeline/
- **Kubernetes Documentation:** https://kubernetes.io/docs/
- **Prometheus Documentation:** https://prometheus.io/docs/
- **Grafana Documentation:** https://grafana.com/docs/
- **GitHub Webhooks:** https://docs.github.com/en/developers/webhooks-and-events/webhooks

---

## ✅ Verification Checklist

Before considering the setup complete:

- [ ] Jenkins is running and accessible
- [ ] GitHub credentials configured in Jenkins
- [ ] GitHub webhook is set up and working
- [ ] Pipeline job created and saved
- [ ] First build completed successfully
- [ ] Website is accessible and healthy
- [ ] Prometheus is collecting metrics
- [ ] Grafana is accessible with Prometheus datasource
- [ ] Docker images are being built
- [ ] Kubernetes deployments are running
- [ ] Alerts are configured (optional but recommended)

---

## 🎉 Congratulations!

Your Jenkins CI/CD pipeline is now fully configured and running! 

### Next Steps:
1. **Monitor:** Watch the pipeline builds in Jenkins
2. **Optimize:** Improve build times and add more tests
3. **Scale:** Increase deployment replicas
4. **Alert:** Set up notifications for your team
5. **Secure:** Add authentication and encryption layers

---

**For issues or questions, refer to:**
- Jenkins Server Logs: `/var/log/jenkins/jenkins.log`
- Build Logs: Jenkins UI → Job → Build Number → Console Output
- Kubernetes Logs: `kubectl logs <pod-name>`
- Docker Logs: `docker logs <container-id>`
