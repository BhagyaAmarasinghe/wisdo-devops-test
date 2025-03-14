# terraform/modules/networking/variables.tf

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "cloudfront_ips" {
  description = "List of CloudFront IP ranges for ALB access"
  type        = list(string)
  default = [
    "130.176.0.0/16",
    "64.252.64.0/18",
    "99.84.0.0/16",
    "52.124.128.0/17",
    "204.246.164.0/22",
    "54.230.0.0/16",
    "54.192.0.0/16"
  ]
}

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

variable "enable_vpc_flow_logs" {
  description = "Enable VPC flow logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC flow logs"
  type        = number
  default     = 14
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Create one NAT Gateway per availability zone"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable a VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_s3_endpoint" {
  description = "Enable S3 Gateway endpoint"
  type        = bool
  default     = true
}

variable "enable_sqs_endpoint" {
  description = "Enable SQS Interface endpoint"
  type        = bool
  default     = true
}

variable "enable_ecr_api_endpoint" {
  description = "Enable ECR API Interface endpoint"
  type        = bool
  default     = true
}

variable "enable_ecr_dkr_endpoint" {
  description = "Enable ECR Docker Interface endpoint"
  type        = bool
  default     = true
}

variable "enable_logs_endpoint" {
  description = "Enable CloudWatch Logs Interface endpoint"
  type        = bool
  default     = true
}

variable "enable_secretsmanager_endpoint" {
  description = "Enable Secrets Manager Interface endpoint"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
