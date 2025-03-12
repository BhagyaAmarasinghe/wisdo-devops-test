module "global" {
  source = "../../global/shared"

  region      = var.region
  environment = var.environment
}

data "aws_caller_identity" "current" {}

module "networking" {
  source = "../../modules/networking"

  prefix               = var.prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cloudfront_ips       = var.cloudfront_ips
  common_tags          = var.common_tags
}

module "security" {
  source = "../../modules/security"

  prefix                   = var.prefix
  region                   = var.region
  permissions_boundary_arn = var.permissions_boundary_arn
  account_id               = data.aws_caller_identity.current.account_id
  common_tags              = var.common_tags
}

module "messaging" {
  source = "../../modules/messaging"

  prefix      = var.prefix
  common_tags = var.common_tags
}

module "mongodb" {
  source = "../../modules/mongodb"

  prefix                     = var.prefix
  vpc_id                     = module.networking.vpc_id
  subnet_ids                 = module.networking.private_subnet_ids
  security_group_ids         = [module.networking.mongodb_endpoint_sg_id]
  mongodb_connection_string  = var.mongodb_connection_string
  mongodb_username           = var.mongodb_username
  mongodb_password           = var.mongodb_password
  mongodb_atlas_service_name = var.mongodb_atlas_service_name
  common_tags                = var.common_tags

  depends_on = [module.networking]
}

module "load_balancing" {
  source = "../../modules/load_balancing"

  prefix                     = var.prefix
  vpc_id                     = module.networking.vpc_id
  subnet_ids                 = module.networking.private_subnet_ids
  security_group_id          = module.networking.alb_sg_id
  frontend_container_port    = var.frontend_container_port
  alb_certificate_arn        = var.alb_certificate_arn
  cloudfront_certificate_arn = var.cloudfront_certificate_arn
  waf_web_acl_arn            = module.security.waf_web_acl_arn
  common_tags                = var.common_tags

  depends_on = [module.networking, module.security]
}

module "ecs" {
  source = "../../modules/ecs"

  prefix             = var.prefix
  region             = var.region
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids

  frontend_security_group_id  = module.networking.frontend_sg_id
  service_a_security_group_id = module.networking.service_a_sg_id
  service_b_security_group_id = module.networking.service_b_sg_id

  frontend_container_port  = var.frontend_container_port
  service_a_container_port = var.service_a_container_port

  frontend_cpu     = var.frontend_cpu
  frontend_memory  = var.frontend_memory
  service_a_cpu    = var.service_a_cpu
  service_a_memory = var.service_a_memory
  service_b_cpu    = var.service_b_cpu
  service_b_memory = var.service_b_memory

  frontend_min_count      = var.frontend_min_count
  frontend_max_count      = var.frontend_max_count
  frontend_desired_count  = var.frontend_desired_count
  service_a_min_count     = var.service_a_min_count
  service_a_max_count     = var.service_a_max_count
  service_a_desired_count = var.service_a_desired_count
  service_b_min_count     = var.service_b_min_count
  service_b_max_count     = var.service_b_max_count
  service_b_desired_count = var.service_b_desired_count

  ecr_repository_url  = var.ecr_repository_url
  frontend_image_tag  = var.frontend_image_tag
  service_a_image_tag = var.service_a_image_tag
  service_b_image_tag = var.service_b_image_tag

  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  frontend_task_role_arn      = module.security.frontend_task_role_arn
  service_a_task_role_arn     = module.security.service_a_task_role_arn
  service_b_task_role_arn     = module.security.service_b_task_role_arn

  alb_target_group_arn = module.load_balancing.frontend_target_group_arn
  sqs_queue_url        = module.messaging.service_b_queue_url
  mongodb_secret_arn   = module.mongodb.mongodb_credentials_arn

  service_discovery_namespace = var.service_discovery_namespace

  common_tags = var.common_tags

  depends_on = [
    module.networking,
    module.security,
    module.load_balancing,
    module.messaging,
    module.mongodb
  ]
}

module "monitoring" {
  source = "../../modules/monitoring"

  prefix                 = var.prefix
  sns_alert_topic_arn    = var.sns_alert_topic_arn
  alb_arn_suffix         = module.load_balancing.alb_arn_suffix
  frontend_tg_arn_suffix = module.load_balancing.frontend_target_group_arn_suffix
  ecs_cluster_name       = module.ecs.ecs_cluster_name
  service_a_name         = module.ecs.service_a_name
  service_b_name         = module.ecs.service_b_name
  sqs_queue_name         = module.messaging.service_b_queue_name
  common_tags            = var.common_tags

  depends_on = [module.ecs, module.load_balancing, module.messaging]
}
