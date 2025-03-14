module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.2"

  cluster_name = "${var.prefix}-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_exec.name
      }
    }
  }

  cluster_settings = {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
        base   = 1
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = var.common_tags
}

# CloudWatch Log Group for ECS Exec
resource "aws_cloudwatch_log_group" "ecs_exec" {
  name              = "/aws/ecs/${var.prefix}/ecs-exec"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

# CloudWatch Log Groups for Services
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/aws/ecs/${var.prefix}/frontend"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "service_a" {
  name              = "/aws/ecs/${var.prefix}/service-a"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "service_b" {
  name              = "/aws/ecs/${var.prefix}/service-b"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

# Define task definitions directly since module doesn't support all parameters
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.prefix}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.frontend_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${var.ecr_repository_url}/frontend:${var.frontend_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.frontend_container_port
          hostPort      = var.frontend_container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "SERVICE_A_URL"
          value = "service-a.${var.service_discovery_namespace}.local:${var.service_a_container_port}"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = var.common_tags
}

resource "aws_ecs_task_definition" "service_a" {
  family                   = "${var.prefix}-service-a"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_a_cpu
  memory                   = var.service_a_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.service_a_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "service-a"
      image     = "${var.ecr_repository_url}/service-a:${var.service_a_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.service_a_container_port
          hostPort      = var.service_a_container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        }
      ]

      secrets = [
        {
          name      = "MONGODB_CONNECTION_STRING"
          valueFrom = "${var.mongodb_secret_arn}:connection_string::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.service_a.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = var.common_tags
}

resource "aws_ecs_task_definition" "service_b" {
  family                   = "${var.prefix}-service-b"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.service_b_cpu
  memory                   = var.service_b_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.service_b_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "service-b"
      image     = "${var.ecr_repository_url}/service-b:${var.service_b_image_tag}"
      essential = true

      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name  = "SQS_QUEUE_URL"
          value = var.sqs_queue_url
        }
      ]

      secrets = [
        {
          name      = "MONGODB_CONNECTION_STRING"
          valueFrom = "${var.mongodb_secret_arn}:connection_string::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.service_b.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = var.common_tags
}

# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = var.service_discovery_namespace
  description = "Private DNS namespace for service discovery"
  vpc         = var.vpc_id # Changed from vpc_id to vpc

  tags = var.common_tags
}

resource "aws_service_discovery_service" "frontend" {
  name = "frontend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = var.common_tags
}

resource "aws_service_discovery_service" "service_a" {
  name = "service-a"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = var.common_tags
}

# ECS Services
resource "aws_ecs_service" "frontend" {
  name                              = "${var.prefix}-frontend"
  cluster                           = module.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.frontend.arn
  desired_count                     = var.frontend_min_count
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"
  health_check_grace_period_seconds = 60
  force_new_deployment              = true
  enable_execute_command            = var.enable_execute_command

  network_configuration {
    security_groups  = [var.frontend_security_group_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "frontend"
    container_port   = var.frontend_container_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.frontend.arn
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.common_tags
}

resource "aws_ecs_service" "service_a" {
  name                   = "${var.prefix}-service-a"
  cluster                = module.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.service_a.arn
  desired_count          = var.service_a_min_count
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  force_new_deployment   = true
  enable_execute_command = var.enable_execute_command

  network_configuration {
    security_groups  = [var.service_a_security_group_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_a.arn
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.common_tags
}

resource "aws_ecs_service" "service_b" {
  name                   = "${var.prefix}-service-b"
  cluster                = module.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.service_b.arn
  desired_count          = var.service_b_min_count
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  force_new_deployment   = true
  enable_execute_command = var.enable_execute_command

  network_configuration {
    security_groups  = [var.service_b_security_group_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.common_tags
}

# Auto Scaling for ECS Services
# Frontend Service Auto Scaling
resource "aws_appautoscaling_target" "frontend" {
  max_capacity       = var.frontend_max_count
  min_capacity       = var.frontend_min_count
  resource_id        = "service/${module.ecs_cluster.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "frontend_latency" {
  name               = "${var.prefix}-frontend-latency"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.frontend.resource_id
  scalable_dimension = aws_appautoscaling_target.frontend.scalable_dimension
  service_namespace  = aws_appautoscaling_target.frontend.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.alb_arn_suffix}/${var.alb_target_group_arn_suffix}"
    }
    target_value       = 1000 # Target requests per instance
    scale_in_cooldown  = 600
    scale_out_cooldown = 180
  }
}

# Service A Auto Scaling
resource "aws_appautoscaling_target" "service_a" {
  max_capacity       = var.service_a_max_count
  min_capacity       = var.service_a_min_count
  resource_id        = "service/${module.ecs_cluster.name}/${aws_ecs_service.service_a.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "service_a_cpu" {
  name               = "${var.prefix}-service-a-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service_a.resource_id
  scalable_dimension = aws_appautoscaling_target.service_a.scalable_dimension
  service_namespace  = aws_appautoscaling_target.service_a.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# Service B Auto Scaling based on SQS Queue
resource "aws_appautoscaling_target" "service_b" {
  max_capacity       = var.service_b_max_count
  min_capacity       = var.service_b_min_count
  resource_id        = "service/${module.ecs_cluster.name}/${aws_ecs_service.service_b.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "service_b_sqs" {
  name               = "${var.prefix}-service-b-sqs"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service_b.resource_id
  scalable_dimension = aws_appautoscaling_target.service_b.scalable_dimension
  service_namespace  = aws_appautoscaling_target.service_b.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "SQSQueueMessagesVisibleAverage"
      resource_label         = var.sqs_queue_name
    }
    target_value       = 10.0 # Target 10 messages per instance
    scale_in_cooldown  = 600
    scale_out_cooldown = 180
  }
}
