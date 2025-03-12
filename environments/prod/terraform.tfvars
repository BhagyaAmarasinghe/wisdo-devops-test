# terraform/environments/prod/terraform.tfvars

# General configuration
prefix      = "wisdo-app"
region      = "us-east-1"
environment = "prod"

# VPC and networking
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

# Container configuration
frontend_container_port  = 3000
service_a_container_port = 50051

# ECS task sizing
frontend_cpu     = 1024
frontend_memory  = 2048
service_a_cpu    = 1024
service_a_memory = 2048
service_b_cpu    = 1024
service_b_memory = 2048

# Auto scaling settings
frontend_min_count     = 2
frontend_max_count     = 10
frontend_desired_count = 2

service_a_min_count     = 2
service_a_max_count     = 10
service_a_desired_count = 2

service_b_min_count     = 2
service_b_max_count     = 20
service_b_desired_count = 2

# Container images
ecr_repository_url  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/wisdo"
frontend_image_tag  = "1.0.0"
service_a_image_tag = "1.0.0"
service_b_image_tag = "1.0.0"

# Certificates and security
alb_certificate_arn        = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-a123-456b-789c-1234abcd5678"
cloudfront_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/efgh5678-e123-456f-789g-5678efgh9012"

# MongoDB Atlas configuration
mongodb_atlas_service_name = "com.amazonaws.vpce.us-east-1.vpce-svc-0123456789abcdef0"

# Service discovery
service_discovery_namespace = "wisdo-internal"

# Monitoring
sns_alert_topic_arn = "arn:aws:sns:us-east-1:123456789012:wisdo-alerts-prod"

# Tagging
common_tags = {
  Project      = "WisdoApp"
  Environment  = "Production"
  ManagedBy    = "Terraform"
  Owner        = "Wisdo-DevOps"
  BusinessUnit = "Wisdo-Platform"
}
