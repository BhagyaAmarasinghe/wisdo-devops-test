# terraform/global/shared/provider.tf

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "WisdoApp"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Variables needed for provider configuration
variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
}
