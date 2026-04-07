pipeline {
  agent any

  options {
    skipDefaultCheckout(true)
  }

  stages {
    stage('Checkout') {
      steps {
        deleteDir()
        checkout scm
      }
    }

    stage('Build Image') {
      steps {
        sh 'docker build -t tourism-website:${BUILD_NUMBER} .'
      }
    }

    stage('Run Container Smoke Test') {
      steps {
        sh '''
          docker rm -f tourism-ci-smoke >/dev/null 2>&1 || true
          docker run -d --name tourism-ci-smoke -p 18080:80 tourism-website:${BUILD_NUMBER}
          for i in $(seq 1 20); do
            if curl -fsS http://host.docker.internal:18080/health >/dev/null; then
              exit 0
            fi
            sleep 2
          done
          curl -fsS http://host.docker.internal:18080/health
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
