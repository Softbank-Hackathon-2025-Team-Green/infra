# FaaS Platform Infrastructure

This Terraform project provisions a complete Function-as-a-Service (FaaS) platform on AWS with best practices.

## Architecture Overview

The infrastructure includes:

- **VPC**: Single AZ deployment with public/private subnets, NAT Gateway, Internet Gateway, and VPC Flow Logs
- **Amplify**: Frontend hosting with CI/CD from GitHub repository
- **S3**: Three buckets (production code, development code, and reserved)
- **CodeBuild**: Docker image building and ECR push automation
- **DynamoDB**: Three tables for function metadata, execution tracking, and logs
- **VPC Networking**: Best practice setup with proper routing and DNS
- **Security Groups**: Properly configured for FaaS workloads
- **SSM Parameter Store**: Centralized configuration management
- **IAM**: Comprehensive roles and policies for all services
- **SQS**: Task and result queues with dead letter queues
- **Network Load Balancer**: Module for traffic distribution
- **ECR**: Container registry with lifecycle policies

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured
- Terraform Cloud account (organization: softbank-hackathon-2025-team-green)
- GitHub personal access token (for Amplify)

## Quick Start

1. Copy the example variables file:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:

   ```hcl
   project_name = "your-project-name"
   environment  = "dev"

   # Add GitHub repository URL and token for Amplify
   amplify_repository_url = "https://github.com/your-org/your-repo"
   amplify_access_token = "ghp_your_token_here"
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Plan the deployment:

   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Module Structure

````
infra/
├── main.tf                 # Main configuration with all module calls
├── variables.tf            # All input variables with validation
├── outputs.tf              # All outputs from modules
├── provider.tf             # Provider and backend configuration
├── terraform.tfvars.example # Example variables file
└── modules/
    ├── vpc/                # VPC with single AZ
    ├── sg/                 # Security Groups
    ├── s3/                 # S3 Buckets (3 buckets)
    ├── dynamodb/           # DynamoDB Tables (3 tables)
    ├── sqs/                # SQS Queues with DLQs
    ├── ecr/                # Elastic Container Registry
    ├── iam/                # IAM Roles and Policies
    ├── ssm/                # Systems Manager Parameter Store
    ├── codebuild/          # CodeBuild Projects
    ├── amplify/            # AWS Amplify
    └── nlb/                # Network Load Balancer

## Resource Naming Convention

All resources follow the naming pattern: `{project_name}-{environment}-{resource_type}`

Example: `faas-platform-dev-vpc`

## DynamoDB Tables

### 1. Functions Table
- **Purpose**: Store function metadata
- **Hash Key**: function_id
- **Range Key**: version
- **GSI**: UserIdIndex (user_id, function_id)

### 2. Executions Table
- **Purpose**: Track function executions
- **Hash Key**: execution_id
- **GSI**: FunctionIdTimestampIndex (function_id, timestamp)
- **Features**: TTL enabled

### 3. Logs Table
- **Purpose**: Store execution logs
- **Hash Key**: execution_id
- **Range Key**: timestamp
- **Features**: TTL enabled, DynamoDB Streams enabled

## S3 Buckets

1. **Production Bucket**: For production function code
2. **Development Bucket**: For development/testing code
3. **Reserved Bucket**: Reserved for future use

All buckets have:
- Versioning enabled
- Server-side encryption (AES256)
- Public access blocked
- Lifecycle policies (transition to Glacier after 90 days)

## SQS Queues

1. **Task Queue**: For incoming function execution requests
2. **Result Queue**: For function execution results
3. **Dead Letter Queues**: For both task and result queues (max 3 retries)

## Security Features

- VPC Flow Logs enabled
- All S3 buckets encrypted and private
- DynamoDB encryption at rest
- ECR image scanning on push
- IMDSv2 required (if using EC2)
- Security groups with minimal required access
- IAM roles following least privilege principle

## Outputs

The configuration outputs important information including:
- VPC and subnet IDs
- S3 bucket names
- DynamoDB table names
- SQS queue URLs
- ECR repository URL
- IAM role ARNs
- NLB DNS name
- Amplify app domain

## Cost Optimization

- DynamoDB: PAY_PER_REQUEST billing mode
- NAT Gateway: Can be disabled for dev environments
- VPC Flow Logs: 7-day retention
- ECR: Lifecycle policy keeps only last 10 images
- S3: Lifecycle transitions to cheaper storage classes

## Customization

Key variables you can customize:

- `vpc_cidr`: VPC CIDR block
- `availability_zone`: Single AZ for all resources
- `enable_nat_gateway`: Enable/disable NAT Gateway
- `enable_vpc_flow_logs`: Enable/disable VPC Flow Logs
- `dynamodb_billing_mode`: DynamoDB billing mode
- `ecr_lifecycle_max_image_count`: Max ECR images to retain

## Troubleshooting

### Terraform Initialization Issues
```bash
terraform init -upgrade
````

### Module Not Found

Ensure all module directories exist with main.tf, variables.tf, and outputs.tf

### Authentication Errors

```bash
aws configure
# Or use environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

## Best Practices Implemented

✅ Single AZ deployment for cost optimization  
✅ VPC with public/private subnet architecture  
✅ NAT Gateway for private subnet internet access  
✅ VPC Flow Logs for network monitoring  
✅ All resources tagged consistently  
✅ DNS resolution enabled in VPC  
✅ S3 versioning and lifecycle policies  
✅ DynamoDB encryption and point-in-time recovery  
✅ SQS dead letter queues  
✅ ECR image scanning and lifecycle policies  
✅ IAM roles with least privilege  
✅ Security groups with specific rules  
✅ SSM Parameter Store for configuration  
✅ CloudWatch Logs integration

## Contributing

1. Make changes in a feature branch
2. Run `terraform fmt` to format code
3. Run `terraform validate` to validate syntax
4. Test in dev environment first
5. Create pull request for review

## License

Managed by: Softbank Hackathon 2025 Team Green

## Support

For issues or questions, contact the infrastructure team.
