variable "project_path" {
  description = "Path to the project directory"
  type        = string
  default     = "."
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "website_replicas" {
  description = "Number of website container replicas"
  type        = number
  default     = 1

  validation {
    condition     = var.website_replicas > 0 && var.website_replicas <= 10
    error_message = "Website replicas must be between 1 and 10."
  }
}
