terraform {
  required_version = ">= 1.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Docker Network
resource "docker_network" "tourism_network" {
  name = "tourism-network"
}

# Website Docker Image
resource "docker_image" "website" {
  name         = "devops-website:${var.image_tag}"
  build {
    context    = "${var.project_path}"
    dockerfile = "Dockerfile"
  }
}

# Jenkins Docker Image
resource "docker_image" "jenkins" {
  name         = "devops-jenkins:${var.image_tag}"
  build {
    context    = "${var.project_path}"
    dockerfile = "jenkins/Dockerfile"
  }
}

# Website Container
resource "docker_container" "website" {
  count             = var.website_replicas
  image             = docker_image.website.image_id
  name              = "devops-website-${count.index + 1}"
  restart_policy    = "unless-stopped"
  must_run          = true
  
  ports {
    internal = 80
    external = 3000 + count.index
  }

  networks_advanced {
    name = docker_network.tourism_network.name
  }

  healthcheck {
    test     = ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://127.0.0.1/health"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  env = [
    "NODE_ENV=production"
  ]
}

# Nginx Container (Load Balancer)
resource "docker_container" "nginx" {
  image        = "nginx:alpine"
  name         = "tourism-nginx"
  restart_policy = "unless-stopped"
  must_run     = true

  ports {
    internal = 80
    external = 8080
  }

  volumes {
    host_path      = "${var.project_path}/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.tourism_network.name
  }

  depends_on = [docker_container.website]
}

# Jenkins Container (CI/CD)
resource "docker_container" "jenkins" {
  image        = docker_image.jenkins.image_id
  name         = "tourism-jenkins"
  user         = "0:0"
  restart_policy = "unless-stopped"
  must_run     = true

  ports {
    internal = 8080
    external = 8088
  }
  ports {
    internal = 50000
    external = 50000
  }

  volumes {
    host_path      = "jenkins_home"
    container_path = "/var/jenkins_home"
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  networks_advanced {
    name = docker_network.tourism_network.name
  }

  env = [
    "KUBECONFIG=/root/.kube/config"
  ]
}

# Output URLs
output "website_url" {
  value       = "http://localhost:8080"
  description = "Tourism Website URL (via Nginx)"
}

output "website_direct_url" {
  value       = "http://localhost:3000"
  description = "Direct Website URL"
}

output "jenkins_url" {
  value       = "http://localhost:8088"
  description = "Jenkins CI/CD Dashboard"
}

output "containers" {
  value = {
    website = docker_container.website[*].name
    nginx   = docker_container.nginx.name
    jenkins = docker_container.jenkins.name
  }
  description = "Running containers"
}
