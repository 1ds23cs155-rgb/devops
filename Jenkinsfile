pipeline {
  agent any

  environment {
    KUBECONFIG = '/root/.kube/config'
    GIT_URL = 'https://github.com/ABHIRAMCHOWDARY24/devops.git'
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
            sleep 3
            CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_ID)
            echo "Container IP: $CONTAINER_IP"
            
            for i in $(seq 1 10); do
              if curl -fsS http://$CONTAINER_IP/health >/dev/null; then
                echo "Health check passed!"
                docker rm -f tourism-ci-smoke >/dev/null 2>&1
                exit 0
              fi
              sleep 2
            done
            echo "Health check failed!"
            docker rm -f tourism-ci-smoke >/dev/null 2>&1
            exit 1
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        sh '''
          kubectl apply -f kubernetes/
          kubectl rollout status deployment/tourism-website --timeout=120s
          kubectl get deploy,pods,svc,hpa,ingress
        '''
      }
    }
  }

  post {
    always {
      sh 'docker rm -f tourism-ci-smoke >/dev/null 2>&1 || true'
    }
    success {
      echo 'Jenkins pipeline completed successfully.'
    }
    failure {
      echo 'Pipeline failed. Check stage logs for details.'
    }
  }
}
