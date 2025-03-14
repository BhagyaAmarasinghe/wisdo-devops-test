# terraform/modules/networking/main.tf

# Use the AWS VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Enable NAT Gateway - one per AZ for high availability
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # DNS settings
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs
  enable_flow_log                   = var.enable_vpc_flow_logs
  flow_log_destination_type         = "cloud-watch-logs"
  flow_log_destination_arn          = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  flow_log_cloudwatch_iam_role_arn  = aws_iam_role.vpc_flow_logs[0].arn
  flow_log_traffic_type             = "ALL"
  flow_log_max_aggregation_interval = 60

  # VPC Endpoints for AWS services
  enable_s3_endpoint             = true
  enable_sqs_endpoint            = true
  enable_ecr_api_endpoint        = true
  enable_ecr_dkr_endpoint        = true
  enable_logs_endpoint           = true
  enable_secretsmanager_endpoint = true

  # Configure security groups for VPC endpoints
  ecr_api_endpoint_security_group_ids        = [aws_security_group.vpc_endpoints.id]
  ecr_dkr_endpoint_security_group_ids        = [aws_security_group.vpc_endpoints.id]
  sqs_endpoint_security_group_ids            = [aws_security_group.vpc_endpoints.id]
  logs_endpoint_security_group_ids           = [aws_security_group.vpc_endpoints.id]
  secretsmanager_endpoint_security_group_ids = [aws_security_group.vpc_endpoints.id]

  # Resource tags
  tags = var.common_tags
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "/aws/vpc-flow-logs/${var.prefix}"
  retention_in_days = var.flow_logs_retention_days

  tags = var.common_tags
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.prefix}-vpc-flow-logs-policy"
  role  = aws_iam_role.vpc_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.prefix}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS from VPC CIDR"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-vpc-endpoints-sg"
    }
  )
}

# Security Groups
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb-sg"
  description = "Security group for internal ALB"
  vpc_id      = module.vpc.vpc_id

  # HTTPS from CloudFront
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cloudfront_ips
    description = "HTTPS from CloudFront"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-alb-sg"
    }
  )
}

# Frontend Service Security Group
resource "aws_security_group" "frontend" {
  name        = "${var.prefix}-frontend-sg"
  description = "Security group for frontend service"
  vpc_id      = module.vpc.vpc_id

  # Allow traffic from ALB
  ingress {
    from_port       = var.frontend_container_port
    to_port         = var.frontend_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Access from ALB"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-frontend-sg"
    }
  )
}

# Service A Security Group
resource "aws_security_group" "service_a" {
  name        = "${var.prefix}-service-a-sg"
  description = "Security group for Service A (gRPC)"
  vpc_id      = module.vpc.vpc_id

  # Allow gRPC traffic from frontend
  ingress {
    from_port       = var.service_a_container_port
    to_port         = var.service_a_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
    description     = "gRPC from frontend service"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-service-a-sg"
    }
  )
}

# Service B Security Group
resource "aws_security_group" "service_b" {
  name        = "${var.prefix}-service-b-sg"
  description = "Security group for Service B (SQS consumer)"
  vpc_id      = module.vpc.vpc_id

  # No inbound rules needed for SQS consumer

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-service-b-sg"
    }
  )
}

# MongoDB Endpoint Security Group
resource "aws_security_group" "mongodb_endpoint" {
  name        = "${var.prefix}-mongodb-endpoint-sg"
  description = "Security group for MongoDB Atlas PrivateLink endpoint"
  vpc_id      = module.vpc.vpc_id

  # MongoDB access from services
  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    security_groups = [
      aws_security_group.service_a.id,
      aws_security_group.service_b.id
    ]
    description = "MongoDB access from services"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.prefix}-mongodb-endpoint-sg"
    }
  )
}
