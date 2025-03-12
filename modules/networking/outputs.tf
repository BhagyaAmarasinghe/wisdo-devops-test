output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "alb_sg_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb_sg.id
}

output "frontend_sg_id" {
  description = "ID of the frontend security group"
  value       = aws_security_group.frontend_sg.id
}

output "service_a_sg_id" {
  description = "ID of the Service A security group"
  value       = aws_security_group.service_a_sg.id
}

output "service_b_sg_id" {
  description = "ID of the Service B security group"
  value       = aws_security_group.service_b_sg.id
}

output "mongodb_endpoint_sg_id" {
  description = "ID of the MongoDB endpoint security group"
  value       = aws_security_group.mongodb_endpoint_sg.id
}
