# terraform/environments/prod/data.tf

# Current AWS account information
data "aws_caller_identity" "current" {}

# Current AWS region
data "aws_region" "current" {}

# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get CloudFront managed policy for IP ranges
data "aws_ip_ranges" "cloudfront" {
  services = ["cloudfront"]
}

# Get Route53 zone for Wisdo domain
data "aws_route53_zone" "wisdo" {
  name = "wisdo.com."
}

# Get Wisdo secret values from AWS Secrets Manager
data "aws_secretsmanager_secret" "mongodb_credentials" {
  name = "wisdo/prod/mongodb-credentials"
}

data "aws_secretsmanager_secret_version" "mongodb_credentials" {
  secret_id = data.aws_secretsmanager_secret.mongodb_credentials.id
}
