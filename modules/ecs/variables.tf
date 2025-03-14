# terraform/modules/ecs/variables.tf

# General configuration
variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Network configuration
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

# Security groups
variable "frontend_security_group_id" {
  description = "Security group ID for the frontend service"
  type        = string
}

variable "service_a_security_group_id" {
  description = "Security group ID for Service A"
  type        = string
}

variable "service_b_security_group_id" {
  description = "Security group ID for Service B"
  type        = string
}

# IAM roles
variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "frontend_task_role_arn" {
  description = "ARN of the frontend task role"
  type        = string
}

variable "service_a_task_role_arn" {
  description = "ARN of the Service A task role"
  type        = string
}

variable "service_b_task_role_arn" {
  description = "ARN of the Service B task role"
  type        = string
}

# Container configuration
variable "frontend_container_port" {
  description = "Port for the frontend container"
  type        = number
  default     = 3000
}

variable "service_a_container_port" {
  description = "Port for Service A container"
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

# Container images
variable "ecr_repository_url" {
  description = "URL of the ECR repository"
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

# Load balancer configuration
variable "alb_target_group_arn" {
  description = "ARN of the ALB target group for the frontend service"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB (for CloudWatch metrics)"
  type        = string
}

variable "alb_target_group_arn_suffix" {
  description = "ARN suffix of the ALB target group (for CloudWatch metrics)"
  type        = string
}

# SQS configuration
variable "sqs_queue_url" {
  description = "URL of the SQS queue"
  type        = string
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue (for CloudWatch metrics)"
  type        = string
}

# MongoDB configuration
variable "mongodb_secret_arn" {
  description = "ARN of the MongoDB credentials secret"
  type        = string
}

# Service discovery
variable "service_discovery_namespace" {
  description = "Namespace for service discovery"
  type        = string
  default     = "internal"
}

# Logging
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

# Features
variable "enable_execute_command" {
  description = "Enable ECS Exec for the tasks"
  type        = bool
  default     = false
}

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = true
}

# Tagging
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
