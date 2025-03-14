module "global" {
  source = "../../global/shared"

  region      = var.region
  environment = var.environment
}

# VPC and Network Infrastructure
module "networking" {
  source = "../../modules/networking"

  prefix               = var.prefix
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cloudfront_ips       = var.cloudfront_ips

  # Service ports
  frontend_container_port  = var.frontend_container_port
  service_a_container_port = var.service_a_container_port

  # VPC features
  enable_vpc_flow_logs     = true
  flow_logs_retention_days = 14

  common_tags = var.common_tags
}

# Security module for IAM roles and policies
module "security" {
  source = "../../modules/security"

  prefix                   = var.prefix
  region                   = var.region
  environment              = var.environment
  permissions_boundary_arn = var.permissions_boundary_arn

  # Define permissions for services
  frontend_permissions  = ["ssm:GetParameter*", "cloudwatch:PutMetricData"]
  service_a_permissions = ["secretsmanager:GetSecretValue"]
  service_b_permissions = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes", "secretsmanager:GetSecretValue"]

  common_tags = var.common_tags
}

# SQS queues for messaging
module "messaging" {
  source = "../../modules/messaging"

  prefix             = var.prefix
  environment        = var.environment
  visibility_timeout = 300
  message_retention  = 86400 # 1 day
  max_receive_count  = 5

  common_tags = var.common_tags
}

# MongoDB Atlas connectivity
module "mongodb" {
  source = "../../modules/mongodb"

  prefix                     = var.prefix
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  subnet_ids                 = module.networking.private_subnet_ids
  security_group_id          = module.networking.mongodb_endpoint_security_group_id
  mongodb_connection_string  = local.mongodb_connection_string
  mongodb_username           = local.mongodb_username
  mongodb_password           = local.mongodb_password
  mongodb_atlas_service_name = var.mongodb_atlas_service_name

  common_tags = var.common_tags

  depends_on = [module.networking]
}

# Load balancing and CDN
module "load_balancing" {
  source = "../../modules/load_balancing"

  prefix                     = var.prefix
  environment                = var.environment
  vpc_id                     = module.networking.vpc_id
  private_subnet_ids         = module.networking.private_subnet_ids
  alb_security_group_id      = module.networking.alb_security_group_id
  frontend_container_port    = var.frontend_container_port
  health_check_path          = "/api/health"
  alb_certificate_arn        = var.alb_certificate_arn
  cloudfront_certificate_arn = var.cloudfront_certificate_arn
  domain_name                = var.domain_name

  common_tags = var.common_tags

  depends_on = [module.networking]
}

# ECS Cluster and Services
module "ecs" {
  source = "../../modules/ecs"

  prefix             = var.prefix
  region             = var.region
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  # Security groups
  frontend_security_group_id  = module.networking.frontend_security_group_id
  service_a_security_group_id = module.networking.service_a_security_group_id
  service_b_security_group_id = module.networking.service_b_security_group_id

  # IAM roles
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  frontend_task_role_arn      = module.security.frontend_task_role_arn
  service_a_task_role_arn     = module.security.service_a_task_role_arn
  service_b_task_role_arn     = module.security.service_b_task_role_arn

  # Container configuration
  frontend_container_port  = var.frontend_container_port
  service_a_container_port = var.service_a_container_port

  # Container compute resources
  frontend_cpu     = var.frontend_cpu
  frontend_memory  = var.frontend_memory
  service_a_cpu    = var.service_a_cpu
  service_a_memory = var.service_a_memory
  service_b_cpu    = var.service_b_cpu
  service_b_memory = var.service_b_memory

  # Auto-scaling configuration
  frontend_min_count  = var.frontend_min_count
  frontend_max_count  = var.frontend_max_count
  service_a_min_count = var.service_a_min_count
  service_a_max_count = var.service_a_max_count
  service_b_min_count = var.service_b_min_count
  service_b_max_count = var.service_b_max_count

  # Images
  ecr_repository_url  = var.ecr_repository_url
  frontend_image_tag  = var.frontend_image_tag
  service_a_image_tag = var.service_a_image_tag
  service_b_image_tag = var.service_b_image_tag

  # Load balancer
  alb_target_group_arn        = module.load_balancing.frontend_target_group_arn
  alb_arn_suffix              = module.load_balancing.alb_arn_suffix
  alb_target_group_arn_suffix = module.load_balancing.frontend_target_group_arn_suffix

  # SQS
  sqs_queue_url  = module.messaging.service_b_queue_url
  sqs_queue_name = module.messaging.service_b_queue_name

  # MongoDB
  mongodb_secret_arn = module.mongodb.mongodb_credentials_arn

  # Service discovery
  service_discovery_namespace = "wisdo-internal"

  # Features
  enable_execute_command    = var.enable_execute_command
  enable_container_insights = var.enable_container_insights
  log_retention_days        = 30

  common_tags = var.common_tags

  depends_on = [
    module.networking,
    module.security,
    module.load_balancing,
    module.messaging,
    module.mongodb
  ]
}

# Monitoring and Alarms
module "monitoring" {
  source = "../../modules/monitoring"

  prefix              = var.prefix
  environment         = var.environment
  sns_alert_topic_arn = var.sns_alert_topic_arn

  # Services to monitor
  ecs_cluster_name = module.ecs.cluster_name
  frontend_service = module.ecs.frontend_service_name
  service_a_name   = module.ecs.service_a_name
  service_b_name   = module.ecs.service_b_name

  # Resources to monitor
  alb_arn_suffix          = module.load_balancing.alb_arn_suffix
  target_group_arn_suffix = module.load_balancing.frontend_target_group_arn_suffix
  sqs_queue_name          = module.messaging.service_b_queue_name
  sqs_dlq_name            = module.messaging.service_b_dlq_name

  common_tags = var.common_tags

  depends_on = [module.ecs, module.load_balancing, module.messaging]
}

# Route53 DNS records
module "dns" {
  source = "../../modules/dns"

  domain_name                = var.domain_name
  cloudfront_distribution_id = module.load_balancing.cloudfront_distribution_id

  create_api_subdomain = true
  api_subdomain        = "api"

  common_tags = var.common_tags

  depends_on = [module.load_balancing]
}
