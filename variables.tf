# ============================================
# General Configuration
# ============================================
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production"
  }
}

variable "project_name" {
  description = "Name of the project for FaaS platform"
  type        = string
  default     = "faas-platform"
}

# ============================================
# Network Configuration
# ============================================
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block"
  }
}

variable "availability_zones" {
  description = "List of AZs to use for VPC subnets"
  type        = list(string)
  default = [
    "ap-northeast-2a",
    "ap-northeast-2c",
  ]
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks (one per AZ)"
  type        = list(string)
  default = [
    "10.0.0.0/24",
    "10.0.1.0/24",
  ]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks (one per AZ)"
  type        = list(string)
  default = [
    "10.0.10.0/24",
    "10.0.11.0/24",
  ]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC flow logs"
  type        = number
  default     = 7
}

# ============================================
# DynamoDB Configuration
# ============================================
variable "dynamodb_function_table" {
  description = "Name of the DynamoDB table for function metadata"
  type        = string
  default     = "faas-functions"
}

variable "dynamodb_execution_table" {
  description = "Name of the DynamoDB table for execution tracking"
  type        = string
  default     = "faas-executions"
}

variable "dynamodb_workspaces_table" {
  description = "Name of the DynamoDB table for users' workspaces"
  type        = string
  default     = "faas-logs"
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_read_capacity" {
  description = "Read capacity units for DynamoDB (used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Write capacity units for DynamoDB (used if billing_mode is PROVISIONED)"
  type        = number
  default     = 5
}

# ============================================
# S3 Configuration
# ============================================
variable "enable_s3_versioning" {
  description = "Enable versioning for S3 buckets"
  type        = bool
  default     = true
}

variable "s3_lifecycle_glacier_days" {
  description = "Number of days before transitioning to Glacier"
  type        = number
  default     = 90
}

# ============================================
# SQS Configuration
# ============================================
variable "sqs_task_queue_name" {
  description = "Name of the SQS queue for task processing"
  type        = string
  default     = "faas-task-queue"
}

variable "sqs_result_queue_name" {
  description = "Name of the SQS queue for results"
  type        = string
  default     = "faas-result-queue"
}

variable "sqs_message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 1209600 # 14 days
}

variable "sqs_visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 300 # 5 minutes
}

# ============================================
# ECR Configuration
# ============================================
variable "ecr_image_tag_mutability" {
  description = "Image tag mutability setting for ECR (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push to ECR"
  type        = bool
  default     = true
}

variable "ecr_lifecycle_max_image_count" {
  description = "Maximum number of images to retain in ECR"
  type        = number
  default     = 10
}

# ============================================
# CodeBuild Configuration
# ============================================
variable "codebuild_compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_image" {
  description = "CodeBuild Docker image"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "codebuild_timeout_minutes" {
  description = "CodeBuild timeout in minutes"
  type        = number
  default     = 60
}

variable "codebuild_source_location" {
  description = "CodeBuild source location (GitHub repo URL)"
  type        = string
  default     = "https://github.com/Softbank-Hackathon-2025-Team-Green/codebuild-repo"
}

# ============================================
# Amplify Configuration
# ============================================
variable "amplify_repository_url" {
  description = "GitHub repository URL for Amplify app"
  type        = string
  default     = ""
}

variable "amplify_access_token" {
  description = "GitHub personal access token for Amplify"
  type        = string
  sensitive   = true
  default     = ""
}

variable "amplify_branch_name" {
  description = "Git branch name for Amplify deployment"
  type        = string
  default     = "master"
}

variable "amplify_dev_branch_name" {
  description = "Git branch name for Amplify development"
  type        = string
  default     = "develop"
}

variable "amplify_build_spec" {
  description = "Custom build specification for Amplify"
  type        = string
  default     = ""
}

variable "amplify_api_endpoint" {
  description = "API endpoint for Amplify app"
  type        = string
  default     = "empty"
}

variable "amplify_dynamodb_workspace_table" {
  description = "DynamoDB workspace table name for Amplify"
  type        = string
  default     = ""
}

variable "amplify_dynamodb_table" {
  description = "DynamoDB table name for Amplify"
  type        = string
  default     = ""
}

variable "amplify_s3_bucket" {
  description = "S3 bucket name for Amplify"
  type        = string
  default     = ""
}

variable "amplify_openai_api_key" {
  description = "OpenAI API key for Amplify"
  type        = string
  sensitive   = true
  default     = ""
}

variable "amplify_slack_webhook"{
  description = "Slack webhook URL for Amplify notifications"
  type        = string
  sensitive   = true
  default     = ""
}

variable "amplify_function_call_baseurl" {
  description = "Base URL for function calls from Amplify"
  type        = string
  default     = ""
}

# ============================================
# EC2 Compute Configuration
# ============================================
variable "enable_compute_instance" {
  description = "Enable standalone compute instance for management/testing"
  type        = bool
  default     = false
}

variable "compute_instance_type" {
  description = "EC2 instance type for standalone compute"
  type        = string
  default     = "t3.medium"
}

variable "ec2_key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = null
}

# ============================================
# Auto Scaling Configuration
# ============================================
variable "enable_worker_asg" {
  description = "Enable Auto Scaling Group for FaaS workers"
  type        = bool
  default     = true
}

variable "worker_instance_type" {
  description = "EC2 instance type for FaaS workers"
  type        = string
  default     = "t3.medium"
}

variable "worker_desired_capacity" {
  description = "Desired number of worker instances"
  type        = number
  default     = 2
}

variable "worker_min_size" {
  description = "Minimum number of worker instances"
  type        = number
  default     = 1
}

variable "worker_max_size" {
  description = "Maximum number of worker instances"
  type        = number
  default     = 10
}

variable "worker_target_cpu" {
  description = "Target CPU utilization for worker scaling"
  type        = number
  default     = 70
}

# ============================================
# Cognito Configuration
# ============================================
variable "cognito_domain_suffix" {
  description = "Suffix for Cognito domain (must be globally unique)"
  type        = string
  default     = ""
}

variable "cognito_callback_urls" {
  description = "List of callback URLs for Cognito OAuth"
  type        = list(string)
  default     = ["http://localhost:3000/"]
}

variable "cognito_logout_urls" {
  description = "List of logout URLs for Cognito OAuth"
  type        = list(string)
  default     = ["http://localhost:3000/"]
}

variable "enable_google_provider" {
  description = "Enable Google as identity provider for Cognito"
  type        = bool
  default     = false
}

variable "google_client_id" {
  description = "Google OAuth Client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cognito_mfa_configuration" {
  description = "MFA configuration for Cognito (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OFF"
}

variable "cognito_deletion_protection" {
  description = "Enable deletion protection for Cognito user pool"
  type        = bool
  default     = false
}

# ============================================
# Common Tags
# ============================================
variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
