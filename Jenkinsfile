pipeline {
  agent any

  environment {
    KUBECONFIG = '/root/.kube/config'
    GIT_URL = 'https://github.com/1ds23cs155-rgb/devops.git'
  }

  stages {
    stage('Checkout') {
      steps {
        script {
          sh 'rm -rf devops || true'
          sh 'git clone -b main ${GIT_URL} devops'
          sh 'cd devops && ls -la'
        }
      }
    }

    stage('Build Image') {
      steps {
        script {
          sh '''
            cd devops
            docker build -t tourism-website:${BUILD_NUMBER} .
          '''
        }
      }
    }

    stage('Run Container Smoke Test') {
      steps {
        script {
          sh '''
            docker rm -f tourism-ci-smoke >/dev/null 2>&1 || true
            CONTAINER_ID=$(docker run -d --name tourism-ci-smoke tourism-website:${BUILD_NUMBER})
            sleep 1
            CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID)
            echo "Container IP: $CONTAINER_IP"
            
            for i in $(seq 1 5); do
              if curl -fsS http://$CONTAINER_IP/health >/dev/null; then
                echo "✓ Health check passed!"
                docker rm -f tourism-ci-smoke >/dev/null 2>&1
                exit 0
              fi
              sleep 1
            done
            echo "✗ Health check failed!"
            docker rm -f tourism-ci-smoke >/dev/null 2>&1
            exit 1
          '''
        }
      }
    }

    stage('Deploy Monitoring Stack') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        script {
          sh '''
            echo "Deploying Prometheus and Grafana..."
            kubectl apply -f kubernetes/prometheus-configmap.yaml
            kubectl apply -f kubernetes/prometheus-deployment.yaml
            kubectl apply -f kubernetes/grafana-deployment.yaml
            sleep 10
            kubectl get pod,svc -l app=prometheus,grafana
          '''
        }
      }
    }

    stage('Deploy Application to Kubernetes') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        sh '''
          echo "Deploying tourism website application..."
          kubectl apply -f kubernetes/deployment.yaml
          kubectl apply -f kubernetes/service.yaml
          kubectl rollout status deployment/tourism-website --timeout=120s
          
          echo "===== Deployment Summary ====="
          kubectl get deploy,pods,svc
          echo "============================="
          
          # Get service endpoints
          echo "Service endpoints:"
          kubectl get svc tourism-website -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || echo "LoadBalancer IP not available yet"
        '''
      }
    }

    stage('Verify Monitoring Stack') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        script {
          sh '''
            echo "Verifying monitoring stack health..."
            sleep 15
            
            # Check Prometheus
            PROMETHEUS_POD=$(kubectl get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}')
            echo "Prometheus pod: $PROMETHEUS_POD"
            kubectl exec $PROMETHEUS_POD -- wget -q -O- http://localhost:9090/-/healthy || echo "Prometheus health check failed"
            
            # Check Grafana
            GRAFANA_POD=$(kubectl get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}')
            echo "Grafana pod: $GRAFANA_POD"
            kubectl exec $GRAFANA_POD -- wget -q -O- http://localhost:3000/api/health || echo "Grafana health check failed"
            
            # Check website
            WEBSITE_POD=$(kubectl get pod -l app=tourism-website -o jsonpath='{.items[0].metadata.name}')
            echo "Website pod: $WEBSITE_POD"
            kubectl exec $WEBSITE_POD -- wget -q -O- http://localhost/health || echo "Website health check failed"
            
            echo "===== Pod Status ====="
            kubectl get pods -o wide
          '''
        }
      }
    }

    stage('Display Access URLs') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        script {
          sh '''
            echo "============================================"
            echo "   Tourism Website Deployment Complete!"
            echo "============================================"
            echo ""
            echo "Access URLs:"
            echo "- Website: http://localhost:80 or http://<K8S-NODE-IP>:<NodePort>"
            echo "- Prometheus: http://localhost:9090 or http://<K8S-NODE-IP>:30090"
            echo "- Grafana: http://localhost:3000 or http://<K8S-NODE-IP>:30300"
            echo "  - Username: admin"
            echo "  - Password: admin"
            echo ""
            echo "Kubernetes Resources:"
            kubectl get all -o wide
            echo ""
            echo "To view logs:"
            echo "  kubectl logs -f deployment/tourism-website"
            echo ""
            echo "To scale deployment:"
            echo "  kubectl scale deployment tourism-website --replicas=3"
            echo ""
            echo "============================================"
          '''
        }
      }
    }
  }

  post {
    always {
      sh '''
        echo "Cleaning up temporary resources..."
        docker rm -f tourism-ci-smoke >/dev/null 2>&1 || true
        docker image prune -f || true
      '''
    }
    success {
      echo '''
        ✅ Jenkins pipeline completed successfully!
        
        Monitoring Stack Endpoints:
        - Prometheus: http://localhost:9090
        - Grafana: http://localhost:3000
        
        Check the 'Display Access URLs' stage for complete information.
      '''
    }
    failure {
      echo '''
        ❌ Pipeline failed. Check stage logs for details.
        
        Common issues:
        1. Docker image build failed - check Dockerfile
        2. Health check failed - ensure /health endpoint exists
        3. Kubernetes deployment failed - check cluster status: kubectl get nodes
        4. Monitoring stack failed - check storage availability
      '''
    }
    unstable {
      echo '⚠️  Pipeline is unstable. Some tests may have failed.'
    }
  }
}
