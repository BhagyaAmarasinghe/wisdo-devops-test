# terraform/environments/prod/locals.tf

locals {
  # Extract MongoDB credentials from Secrets Manager
  mongodb_creds = jsondecode(data.aws_secretsmanager_secret_version.mongodb_credentials.secret_string)

  mongodb_connection_string = local.mongodb_creds.connection_string
  mongodb_username          = local.mongodb_creds.username
  mongodb_password          = local.mongodb_creds.password

  # Enhanced tags with additional context
  enhanced_tags = merge(
    var.common_tags,
    {
      ProvisionedBy = "Terraform"
      ProvisionedOn = timestamp()
    }
  )

  # Calculate optimal values based on environment
  is_prod = var.environment == "prod"

  # Set proper naming based on environment
  resource_name_prefix = "${var.prefix}-${var.environment}"

  # Auto-calculate proper replica counts based on availability zones
  az_count       = length(var.availability_zones)
  min_task_count = max(local.az_count, var.frontend_min_count)
}
