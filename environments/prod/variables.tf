# terraform/environments/prod/variables.tf

# General configuration
variable "prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "wisdo-app"
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

# VPC and networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "cloudfront_ips" {
  description = "List of CloudFront IP ranges"
  type        = list(string)
  default     = ["130.176.0.0/16", "64.252.64.0/18", "99.84.0.0/16", "52.124.128.0/17", "204.246.164.0/22", "54.230.0.0/16", "54.192.0.0/16"]
}

# Container configuration
variable "frontend_container_port" {
  description = "Port exposed by the frontend container"
  type        = number
  default     = 3000
}

variable "service_a_container_port" {
  description = "Port exposed by Service A container (gRPC)"
  type        = number
  default     = 50051
}

# ECS task sizing
variable "frontend_cpu" {
  description = "CPU units for the frontend task"
  type        = number
  default     = 512
}

variable "frontend_memory" {
  description = "Memory for the frontend task (MiB)"
  type        = number
  default     = 1024
}

variable "service_a_cpu" {
  description = "CPU units for Service A task"
  type        = number
  default     = 512
}

variable "service_a_memory" {
  description = "Memory for Service A task (MiB)"
  type        = number
  default     = 1024
}

variable "service_b_cpu" {
  description = "CPU units for Service B task"
  type        = number
  default     = 512
}

variable "service_b_memory" {
  description = "Memory for Service B task (MiB)"
  type        = number
  default     = 1024
}

# Auto scaling settings
variable "frontend_min_count" {
  description = "Minimum number of frontend tasks"
  type        = number
  default     = 2
}

variable "frontend_max_count" {
  description = "Maximum number of frontend tasks"
  type        = number
  default     = 10
}

variable "frontend_desired_count" {
  description = "Desired number of frontend tasks"
  type        = number
  default     = 2
}

variable "service_a_min_count" {
  description = "Minimum number of Service A tasks"
  type        = number
  default     = 2
}

variable "service_a_max_count" {
  description = "Maximum number of Service A tasks"
  type        = number
  default     = 10
}

variable "service_a_desired_count" {
  description = "Desired number of Service A tasks"
  type        = number
  default     = 2
}

variable "service_b_min_count" {
  description = "Minimum number of Service B tasks"
  type        = number
  default     = 2
}

variable "service_b_max_count" {
  description = "Maximum number of Service B tasks"
  type        = number
  default     = 20
}

variable "service_b_desired_count" {
  description = "Desired number of Service B tasks"
  type        = number
  default     = 2
}

# Container images
variable "ecr_repository_url" {
  description = "ECR Repository URL"
  type        = string
}

variable "frontend_image_tag" {
  description = "Image tag for the frontend service"
  type        = string
  default     = "latest"
}

variable "service_a_image_tag" {
  description = "Image tag for Service A"
  type        = string
  default     = "latest"
}

variable "service_b_image_tag" {
  description = "Image tag for Service B"
  type        = string
  default     = "latest"
}

# Certificates and security
variable "alb_certificate_arn" {
  description = "ARN of the SSL certificate for the ALB"
  type        = string
}

variable "cloudfront_certificate_arn" {
  description = "ARN of the SSL certificate for CloudFront"
  type        = string
}

variable "permissions_boundary_arn" {
  description = "ARN of the IAM permissions boundary to apply to all roles"
  type        = string
  default     = null
}

# MongoDB Atlas configuration
variable "mongodb_connection_string" {
  description = "MongoDB Atlas connection string"
  type        = string
  sensitive   = true
}

variable "mongodb_username" {
  description = "MongoDB Atlas username"
  type        = string
  sensitive   = true
}

variable "mongodb_password" {
  description = "MongoDB Atlas password"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_service_name" {
  description = "MongoDB Atlas PrivateLink service name"
  type        = string
}

# Service discovery
variable "service_discovery_namespace" {
  description = "Namespace for service discovery"
  type        = string
  default     = "internal"
}

# Monitoring
variable "sns_alert_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
}

# Tagging
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "WisdoApp"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
