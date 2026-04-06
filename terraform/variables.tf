variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "container_image" {
  description = "Container image URL"
  type        = string
  default     = "tourism-website"
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.tourism.dns_name
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.tourism.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.tourism.name
}

output "website_url" {
  description = "URL to access the website"
  value       = "http://${aws_lb.tourism.dns_name}"
}
