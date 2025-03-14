output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.load_balancing.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.load_balancing.cloudfront_distribution_id
}

output "alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = module.load_balancing.alb_dns_name
}

output "ecr_repository_url" {
  description = "ECR Repository URL for services"
  value       = var.ecr_repository_url
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.ecs_cluster_name
}

output "service_discovery_namespace" {
  description = "Service discovery namespace"
  value       = module.ecs.service_discovery_namespace
}

output "sqs_queue_url" {
  description = "URL of the SQS queue for Service B"
  value       = module.messaging.service_b_queue_url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue for Service B"
  value       = module.messaging.service_b_queue_arn
}

output "sqs_dlq_url" {
  description = "URL of the SQS dead-letter queue"
  value       = module.messaging.service_b_dlq_url
}

output "mongodb_endpoint_dns" {
  description = "DNS name of the MongoDB PrivateLink endpoint"
  value       = module.mongodb.mongodb_endpoint_dns
}
