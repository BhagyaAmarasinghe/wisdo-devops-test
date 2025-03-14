# Wisdo AWS Infrastructure Solution

This repository contains the solution for deploying the Wisdo application infrastructure on AWS. The solution includes highly available and secure components across multiple availability zones.

## Architecture Overview

![Architecture Diagram](https://github.com/BhagyaAmarasinghe/wisdo-devops-test/blob/main/architecture-diagram.png)

The architecture follows a multi-AZ deployment model with these key components:

- **Frontend Layer**: CloudFront distribution connects to a Next.js frontend static web hosting service
- **Network Layer**: VPC with multi-AZ deployment (Zones A and B), each with both public and private subnets
- **Application Layer**: 
  - ECS Cluster running in Fargate mode across both availability zones
  - Frontend service (Next.js) deployed on ECS
  - Service A providing gRPC communication
  - Service B consuming messages from SQS
- **Integration Layer**: 
  - Internal Application Load Balancer routing traffic
  - Interface Endpoints for secure communication
  - AWS PrivateLink connecting to MongoDB Atlas
- **Database Layer**: MongoDB Atlas deployed in multiple subnets with replica sets (R6g instances)

## Network Security Design

### Secure Network Segmentation

- **Private Backend Services**: All application services run in private subnets with no direct internet access
- **Public-facing Components**: Only CloudFront is exposed to end users
- **NAT Gateways**: Deployed in public subnets for outbound connectivity from private subnets

### Access Control
- **Load Balancer Protection**: The Application Load Balancer is deployed in private subnets and only accepts traffic from CloudFront IP ranges
- **VPC Endpoints**: Private connections to AWS services like SQS, ECR, CloudWatch, and Secrets Manager
- **PrivateLink**: Secure connection to MongoDB Atlas without traversing the public internet
- **Security Groups**: Precise rules defining allowed communication paths between services

## Auto Scaling Strategy

### Frontend and Service A (based on latency)
- **Metrics**: p90 latency and request count per target
- **Thresholds**:
  - Scale out: When p90 latency > 500ms for 3 consecutive minutes
  - Scale in: When p90 latency < 200ms for 10 consecutive minutes
- **Configuration**:
  - Minimum: 2 tasks (for high availability across AZs)
  - Maximum: 10 tasks
  - Cooldown periods: 180s for scale out, 600s for scale in

### Service B (based on SQS queue depth)
- **Metrics**: ApproximateNumberOfMessagesVisible
- **Thresholds**:
  - Scale out: When queue depth > 100 messages for 3 consecutive minutes
  - Scale in: When queue depth < 20 messages for 10 consecutive minutes
- **Configuration**:
  - Minimum: 2 tasks
  - Maximum: 20 tasks
  - Cooldown periods: 180s for scale out, 600s for scale in

## IAM Permissions Strategy

Following the principle of least privilege, each service has carefully scoped permissions:

### Frontend Service
- Read access to SSM Parameter Store for configuration
- CloudWatch logging permissions
- Access to pull from its ECR repository only

### Service A (gRPC)
- Access to MongoDB credentials in Secrets Manager
- CloudWatch logging permissions
- Service discovery registration permissions

### Service B (SQS Consumer)
- Permissions to read and delete messages from specific SQS queue
- Access to MongoDB credentials in Secrets Manager
- CloudWatch logging permissions

All IAM roles use permission boundaries for additional security and are regularly reviewed through automated tools.

## Infrastructure Implementation

The infrastructure is defined using Terraform with a modular approach:

```text
terraform/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/    # VPC, subnets, security groups
│   ├── ecs/           # ECS cluster, services, task definitions
│   ├── load_balancing/ # ALB and CloudFront
│   ├── security/      # IAM roles and policies
│   ├── mongodb/       # PrivateLink connection
│   ├── messaging/     # SQS queues
│   └── monitoring/    # CloudWatch alarms
└── global/
    └── shared/        # Common provider configurations


Community modules are leveraged where appropriate for standardization and best practices.

## CI/CD Pipeline

The infrastructure is deployed through a GitHub Actions pipeline that follows these stages:

1. **Validate**: Terraform format check and validation
2. **Build**: Docker image building and ECR pushing
3. **Plan**: Terraform plan stage to preview changes
4. **Apply**: Apply infrastructure changes with appropriate approvals
5. **Test**: Run post-deployment tests to verify functionality
6. **Notify**: Send deployment status notifications

Environment-specific configurations and manual approval gates ensure safe deployments to production.