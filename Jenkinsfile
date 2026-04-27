pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  environment {
    IMAGE_NAME = 'devops-website'
    IMAGE_TAG = "${BUILD_NUMBER}"
    SMOKE_CONTAINER = 'tourism-ci-smoke'
    SMOKE_PORT = '18080'
  }

  triggers {
    githubPush()
  }

  stages {
    stage('Pipeline Version') {
      steps {
        echo 'PIPELINE_VERSION: WIN_FIX_2026_04_27_B'
        script {
          if (isUnix()) {
            sh 'git rev-parse --short HEAD || true'
          } else {
            bat 'git rev-parse --short HEAD'
          }
        }
      }
    }

    stage('Checkout') {
      steps {
        deleteDir()
        checkout scm
        script {
          if (isUnix()) {
            sh 'git rev-parse --short HEAD'
          } else {
            bat 'git rev-parse --short HEAD'
          }
        }
      }
    }

    stage('Validate Website Files') {
      steps {
        script {
          if (isUnix()) {
            sh '''
              set -e
              test -d website
              test -f website/index.html
              COUNT=$(find website -maxdepth 1 -type f -name '*.html' | wc -l)
              echo "Found ${COUNT} HTML files in website/"
              if [ "$COUNT" -lt 1 ]; then
                echo "No HTML files found in website/"
                exit 1
              fi
            '''
          } else {
            bat '''
              @echo off
              setlocal enabledelayedexpansion
              if not exist website (
                echo website folder missing
                exit /b 1
              )
              if not exist website\\index.html (
                echo website\\index.html missing
                exit /b 1
              )
              for /f %%A in ('dir /b /a-d website\\*.html ^| find /c /v ""') do set COUNT=%%A
              echo Found !COUNT! HTML files in website/
              if !COUNT! LSS 1 (
                echo No HTML files found in website/
                exit /b 1
              )
            '''
          }
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          if (isUnix()) {
            sh '''
              set -e
              docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
              docker image ls ${IMAGE_NAME}
            '''
          } else {
            bat '''
              @echo off
              docker build -t %IMAGE_NAME%:%IMAGE_TAG% -t %IMAGE_NAME%:latest .
              docker image ls %IMAGE_NAME%
            '''
          }
        }
      }
    }

    stage('Smoke Test Container') {
      steps {
        script {
          if (isUnix()) {
            sh '''
              set -e
              docker rm -f ${SMOKE_CONTAINER} >/dev/null 2>&1 || true
              docker run -d --name ${SMOKE_CONTAINER} -p ${SMOKE_PORT}:80 ${IMAGE_NAME}:${IMAGE_TAG}

              for i in $(seq 1 20); do
                if curl -fsS http://127.0.0.1:${SMOKE_PORT}/healthcheck.html >/dev/null; then
                  echo "Health check passed"
                  break
                fi
                sleep 1
              done

              curl -fsS http://127.0.0.1:${SMOKE_PORT}/healthcheck.html >/dev/null
              curl -fsS http://127.0.0.1:${SMOKE_PORT}/index.html >/dev/null
              echo "Smoke tests passed"
            '''
          } else {
            bat '''
              @echo off
              powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; docker rm -f $env:SMOKE_CONTAINER *> $null; docker run -d --name $env:SMOKE_CONTAINER -p ($env:SMOKE_PORT + ':80') ($env:IMAGE_NAME + ':' + $env:IMAGE_TAG) *> $null; $ok=$false; for($i=0; $i -lt 20; $i++){ try { Invoke-WebRequest -UseBasicParsing ('http://127.0.0.1:' + $env:SMOKE_PORT + '/healthcheck.html') *> $null; $ok=$true; break } catch { Start-Sleep -Seconds 1 } }; if(-not $ok){ throw 'Health check failed' }; Invoke-WebRequest -UseBasicParsing ('http://127.0.0.1:' + $env:SMOKE_PORT + '/index.html') *> $null; Write-Host 'Smoke tests passed'"
            '''
          }
        }
      }
    }

    stage('Deploy Website Services') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        script {
          if (isUnix()) {
            sh '''
              set -e
              if command -v docker-compose >/dev/null 2>&1; then
                COMPOSE_CMD="docker-compose"
              else
                COMPOSE_CMD="docker compose"
              fi

              ${COMPOSE_CMD} up -d --build website nginx
              ${COMPOSE_CMD} ps
            '''
          } else {
            bat '''
              @echo off
              powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; if (Get-Command docker-compose -ErrorAction SilentlyContinue) { docker-compose up -d --build website nginx; docker-compose ps } else { docker compose up -d --build website nginx; docker compose ps }"
            '''
          }
        }
      }
    }

    stage('Verify Deployment') {
      when {
        anyOf {
          branch 'main'
          branch 'master'
        }
      }
      steps {
        script {
          if (isUnix()) {
            sh '''
              set -e
              for i in $(seq 1 20); do
                if curl -fsS http://127.0.0.1:3000/healthcheck.html >/dev/null; then
                  echo "Website deployment healthy"
                  exit 0
                fi
                sleep 1
              done

              echo "Deployment health check failed"
              exit 1
            '''
          } else {
            bat '''
              @echo off
              powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ok=$false; for($i=0; $i -lt 20; $i++){ try { Invoke-WebRequest -UseBasicParsing 'http://127.0.0.1:3000/healthcheck.html' *> $null; $ok=$true; break } catch { Start-Sleep -Seconds 1 } }; if(-not $ok){ throw 'Deployment health check failed' }; Write-Host 'Website deployment healthy'"
            '''
          }
        }
      }
    }
  }

  post {
    always {
      script {
        if (isUnix()) {
          sh 'docker rm -f ${SMOKE_CONTAINER} >/dev/null 2>&1 || true'
        } else {
          bat 'docker rm -f %SMOKE_CONTAINER% >nul 2>&1 || exit /b 0'
        }
      }
    }

    success {
      echo 'Pipeline completed successfully. Website is ready.'
    }

    failure {
      echo 'Pipeline failed. Check stage logs for details.'
    }
  }
}
