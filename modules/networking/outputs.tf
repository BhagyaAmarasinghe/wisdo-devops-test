# terraform/modules/networking/outputs.tf

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.vpc.natgw_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "frontend_security_group_id" {
  description = "ID of the frontend security group"
  value       = aws_security_group.frontend.id
}

output "service_a_security_group_id" {
  description = "ID of Service A security group"
  value       = aws_security_group.service_a.id
}

output "service_b_security_group_id" {
  description = "ID of Service B security group"
  value       = aws_security_group.service_b.id
}

output "mongodb_endpoint_security_group_id" {
  description = "ID of the MongoDB endpoint security group"
  value       = aws_security_group.mongodb_endpoint.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = aws_security_group.vpc_endpoints.id
}

output "vpc_endpoint_sqs_id" {
  description = "ID of the SQS VPC endpoint"
  value       = module.vpc.vpc_endpoint_sqs_id
}

output "vpc_endpoint_ecr_api_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = module.vpc.vpc_endpoint_ecr_api_id
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "ID of the ECR Docker VPC endpoint"
  value       = module.vpc.vpc_endpoint_ecr_dkr_id
}

output "vpc_endpoint_logs_id" {
  description = "ID of the CloudWatch Logs VPC endpoint"
  value       = module.vpc.vpc_endpoint_logs_id
}

output "vpc_endpoint_secretsmanager_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = module.vpc.vpc_endpoint_secretsmanager_id
}

output "vpc_endpoint_s3_id" {
  description = "ID of the S3 VPC endpoint"
  value       = module.vpc.vpc_endpoint_s3_id
}

output "public_route_table_ids" {
  description = "IDs of the public route tables"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = module.vpc.private_route_table_ids
}
