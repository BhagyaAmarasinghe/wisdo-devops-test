# MongoDB PrivateLink Connection
resource "aws_vpc_endpoint" "mongodb_atlas" {
  # ... MongoDB VPC endpoint configuration
}

# MongoDB Credentials in Secrets Manager
resource "aws_secretsmanager_secret" "mongodb_credentials" {
  # ... MongoDB credentials secret configuration
}

resource "aws_secretsmanager_secret_version" "mongodb_credentials" {
  # ... MongoDB credentials secret version
}
