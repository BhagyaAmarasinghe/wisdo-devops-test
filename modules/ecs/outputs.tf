# terraform/modules/ecs/outputs.tf

output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs_cluster.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs_cluster.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs_cluster.arn
}

output "frontend_service_id" {
  description = "ID of the frontend service"
  value       = module.frontend_service.id
}

output "frontend_service_name" {
  description = "Name of the frontend service"
  value       = module.frontend_service.name
}

output "service_a_id" {
  description = "ID of Service A"
  value       = module.service_a.id
}

output "service_a_name" {
  description = "Name of Service A"
  value       = module.service_a.name
}

output "service_b_id" {
  description = "ID of Service B"
  value       = module.service_b.id
}

output "service_b_name" {
  description = "Name of Service B"
  value       = module.service_b.name
}

output "frontend_task_definition_arn" {
  description = "ARN of the frontend task definition"
  value       = module.frontend_service.task_definition_arn
}

output "service_a_task_definition_arn" {
  description = "ARN of Service A task definition"
  value       = module.service_a.task_definition_arn
}

output "service_b_task_definition_arn" {
  description = "ARN of Service B task definition"
  value       = module.service_b.task_definition_arn
}

output "frontend_log_group_name" {
  description = "Name of the frontend CloudWatch log group"
  value       = aws_cloudwatch_log_group.frontend.name
}

output "service_a_log_group_name" {
  description = "Name of Service A CloudWatch log group"
  value       = aws_cloudwatch_log_group.service_a.name
}

output "service_b_log_group_name" {
  description = "Name of Service B CloudWatch log group"
  value       = aws_cloudwatch_log_group.service_b.name
}

output "service_discovery_namespace_id" {
  description = "ID of the service discovery namespace"
  value       = aws_service_discovery_private_dns_namespace.main.id
}

output "service_discovery_namespace" {
  description = "Service discovery namespace"
  value       = var.service_discovery_namespace
}

output "service_discovery_service_ids" {
  description = "IDs of the service discovery services"
  value = {
    frontend  = aws_service_discovery_service.frontend.id
    service_a = aws_service_discovery_service.service_a.id
  }
}

output "autoscaling_target_ids" {
  description = "IDs of the autoscaling targets"
  value = {
    frontend  = aws_appautoscaling_target.frontend.id
    service_a = aws_appautoscaling_target.service_a.id
    service_b = aws_appautoscaling_target.service_b.id
  }
}
