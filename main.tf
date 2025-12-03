# Data Sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ============================================
# VPC Module
# ============================================
module "vpc" {
  source = "./modules/vpc"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zone        = var.availability_zone
  public_subnet_cidr       = var.public_subnet_cidr
  private_subnet_cidr      = var.private_subnet_cidr
  enable_nat_gateway       = var.enable_nat_gateway
  enable_flow_logs         = var.enable_vpc_flow_logs
  flow_logs_retention_days = var.flow_logs_retention_days

  tags = var.tags
}

# ============================================
# Security Groups
# ============================================
module "faas_sg" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  sg_name     = "${var.project_name}-${var.environment}-faas-sg"
  description = "Security group for FaaS workloads"

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "Allow HTTP within VPC"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "Allow HTTPS within VPC"
    }
  ]

  tags = var.tags
}

module "k3s_control_plane_sg" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  sg_name     = "${var.project_name}-${var.environment}-k3s-control-sg"
  description = "Security group for K3s control plane"

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH from anywhere"
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr]
      description = "Allow all traffic from within the VPC"
    }
  ]

  tags = var.tags
}

module "k3s_worker_sg" {
  source = "./modules/sg"

  vpc_id      = module.vpc.vpc_id
  sg_name     = "${var.project_name}-${var.environment}-k3s-worker-sg"
  description = "Security group for K3s worker nodes"

  ingress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr]
      description = "Allow all traffic from within the VPC"
    }
  ]

  tags = var.tags
}

# ============================================
# S3 Buckets
# ============================================
module "s3_production" {
  source = "./modules/s3"

  bucket_name       = "${var.project_name}-${var.environment}-code-prod-${data.aws_caller_identity.current.account_id}"
  enable_versioning = var.enable_s3_versioning
  force_destroy     = false

  lifecycle_rules = [
    {
      id      = "archive-old-versions"
      enabled = true
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = var.s3_lifecycle_glacier_days
          storage_class = "GLACIER"
        }
      ]
      noncurrent_version_expiration = {
        days = var.s3_lifecycle_glacier_days
      }
    }
  ]

  tags = merge(
    var.tags,
    {
      Tier = "Production"
    }
  )
}

module "s3_development" {
  source = "./modules/s3"

  bucket_name       = "${var.project_name}-${var.environment}-code-dev-${data.aws_caller_identity.current.account_id}"
  enable_versioning = var.enable_s3_versioning
  force_destroy     = false

  tags = merge(
    var.tags,
    {
      Tier = "Development"
    }
  )
}

module "s3_reserved" {
  source = "./modules/s3"

  bucket_name       = "${var.project_name}-${var.environment}-reserved-${data.aws_caller_identity.current.account_id}"
  enable_versioning = var.enable_s3_versioning
  force_destroy     = false

  tags = merge(
    var.tags,
    {
      Tier = "Reserved"
    }
  )
}

# ============================================
# DynamoDB Tables
# ============================================
# Functions Table
module "dynamodb_functions" {
  source = "./modules/dynamodb"

  table_name   = "${var.project_name}-${var.environment}-${var.dynamodb_function_table}"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "userId"
  range_key    = "functionId"

  attributes = [
    { name = "userId", type = "S" },
    { name = "functionId", type = "S" }
  ]

  global_secondary_indexes = []

  tags = var.tags
}

# Executions Table
module "dynamodb_executions" {
  source = "./modules/dynamodb"

  table_name   = "${var.project_name}-${var.environment}-${var.dynamodb_execution_table}"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "functionId"
  range_key    = "executionId"

  attributes = [
    { name = "functionId", type = "S" },
    { name = "executionId", type = "S" }
  ]

  global_secondary_indexes = []

  ttl_enabled        = true
  ttl_attribute_name = "ttl"

  tags = var.tags
}

# Workspaces Table
module "dynamodb_workspaces" {
  source = "./modules/dynamodb"

  table_name   = "${var.project_name}-${var.environment}-${var.dynamodb_workspaces_table}"
  billing_mode = var.dynamodb_billing_mode
  hash_key     = "userId"

  attributes = [
    { name = "userId", type = "S" }
  ]

  tags = var.tags
}

# ============================================
# SQS Queues
# ============================================
# Task Queue
module "sqs_task" {
  source = "./modules/sqs"

  queue_name                 = "${var.project_name}-${var.environment}-${var.sqs_task_queue_name}"
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  receive_wait_time_seconds  = 10
  create_dlq                 = true
  max_receive_count          = 3

  tags = var.tags
}

# Result Queue
module "sqs_result" {
  source = "./modules/sqs"

  queue_name                 = "${var.project_name}-${var.environment}-${var.sqs_result_queue_name}"
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  receive_wait_time_seconds  = 10
  create_dlq                 = true
  max_receive_count          = 3

  tags = var.tags
}

# ============================================
# ECR Repository
# ============================================
module "ecr" {
  source = "./modules/ecr"

  project_name              = var.project_name
  environment               = var.environment
  image_tag_mutability      = var.ecr_image_tag_mutability
  scan_on_push              = var.ecr_scan_on_push
  lifecycle_max_image_count = var.ecr_lifecycle_max_image_count

  tags = var.tags
}

# ============================================
# IAM Roles and Policies
# ============================================
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
  aws_region   = var.aws_region

  dynamodb_table_arns = [
    module.dynamodb_functions.table_arn,
    module.dynamodb_executions.table_arn,
    module.dynamodb_workspaces.table_arn
  ]

  s3_bucket_arns = [
    module.s3_production.bucket_arn,
    module.s3_development.bucket_arn,
    module.s3_reserved.bucket_arn
  ]

  sqs_queue_arns = [
    module.sqs_task.queue_arn,
    module.sqs_result.queue_arn,
    module.sqs_task.dlq_arn,
    module.sqs_result.dlq_arn
  ]

  ecr_repository_arn = module.ecr.repository_arn

  tags = var.tags
}

# ============================================
# SSM Parameter Store
# ============================================
module "ssm" {
  source = "./modules/ssm"

  project_name = var.project_name
  environment  = var.environment

  parameters = {
    task_queue_url = {
      name        = null
      value       = module.sqs_task.queue_url
      type        = "String"
      description = "SQS task queue URL"
    }
    result_queue_url = {
      name        = null
      value       = module.sqs_result.queue_url
      type        = "String"
      description = "SQS result queue URL"
    }
    ecr_repository_url = {
      name        = null
      value       = module.ecr.repository_url
      type        = "String"
      description = "ECR repository URL"
    }
    functions_table = {
      name        = null
      value       = module.dynamodb_functions.table_name
      type        = "String"
      description = "DynamoDB functions table name"
    }
    executions_table = {
      name        = null
      value       = module.dynamodb_executions.table_name
      type        = "String"
      description = "DynamoDB executions table name"
    }
    k3s_cluster_token = {
      name        = "/k3s/cluster-token"
      value       = "placeholder"
      type        = "SecureString"
      description = "K3s cluster join token (updated by control plane)"
    }
    k3s_cluster_status = {
      name        = "/k3s/cluster-status"
      value       = "initializing"
      type        = "String"
      description = "K3s cluster initialization status"
    }
  }

  tags = var.tags
}

# ============================================
# CodeBuild Project
# ============================================
module "codebuild" {
  source = "./modules/codebuild"

  project_name       = var.project_name
  environment        = var.environment
  codebuild_role_arn = module.iam.codebuild_role_arn
  s3_bucket_name     = module.s3_production.bucket_id
  ecr_repository_url = module.ecr.repository_url
  compute_type       = var.codebuild_compute_type
  image              = var.codebuild_image
  timeout_minutes    = var.codebuild_timeout_minutes

  tags = var.tags
}

# ============================================
# Cognito (User Pool & Identity Pool)
# ============================================
module "cognito" {
  source = "./modules/cognito"

  project_name           = var.project_name
  environment            = var.environment
  domain_suffix          = var.cognito_domain_suffix != "" ? var.cognito_domain_suffix : "${var.project_name}-${var.environment}"
  callback_urls          = var.cognito_callback_urls
  logout_urls            = var.cognito_logout_urls
  enable_google_provider = var.enable_google_provider
  google_client_id       = var.google_client_id
  google_client_secret   = var.google_client_secret
  mfa_configuration      = var.cognito_mfa_configuration
  deletion_protection    = var.cognito_deletion_protection

  tags = var.tags
}

# ============================================
# Amplify (Conditional)
# ============================================
module "amplify" {
  source = "./modules/amplify"

  project_name     = var.project_name
  environment      = var.environment
  repository_url   = var.amplify_repository_url
  access_token     = var.amplify_access_token
  branch_name      = var.amplify_branch_name
  dev_branch_name  = var.amplify_dev_branch_name
  build_spec       = var.amplify_build_spec
  service_role_arn = module.iam.amplify_service_role_arn
  compute_role_arn = module.iam.amplify_ssr_role_arn
  platform         = "WEB_COMPUTE"
  framework        = "Next.js - SSR"

  environment_variables = {
    NEXT_PUBLIC_AWS_REGION               = var.aws_region
    NEXT_PUBLIC_API_ENDPOINT             = ""
    NEXT_PUBLIC_DYNAMODB_WORKSPACE_TABLE = module.dynamodb_workspaces.table_name
    NEXT_PUBLIC_DYNAMODB_TABLE           = module.dynamodb_functions.table_name
    NEXT_PUBLIC_S3_BUCKET                = module.s3_production.bucket_id
    NEXT_PUBLIC_USER_POOL_ID             = module.cognito.user_pool_id
    NEXT_PUBLIC_USER_POOL_CLIENT_ID      = module.cognito.user_pool_client_id
    OPENAI_API_KEY                       = var.amplify_openai_api_key
  }

  tags = var.tags
}

# ============================================
# Network Load Balancer (Module Only)
# ============================================
module "nlb" {
  source = "./modules/nlb"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [module.vpc.public_subnet_id]

  tags = var.tags
}

# ============================================
# K3s Control Plane Instance (Optional)
# ============================================
module "k3s_control_plane" {
  count  = var.enable_compute_instance ? 1 : 0
  source = "./modules/ec2"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.public_subnet_id
  security_group_ids   = [module.k3s_control_plane_sg.security_group_id]
  instance_type        = var.compute_instance_type
  iam_instance_profile = module.iam.ec2_instance_profile_name
  key_name             = var.ec2_key_name
  enable_public_ip     = true
  root_volume_size     = 30
  user_data            = file("${path.module}/userdata/k3s-control.sh")

  tags = var.tags
}

# ============================================
# K3s Worker Nodes (Auto Scaling Group)
# ============================================
module "k3s_worker" {
  count  = var.enable_worker_asg ? 1 : 0
  source = "./modules/asg"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = [module.vpc.private_subnet_id]
  security_group_ids     = [module.k3s_worker_sg.security_group_id]
  instance_type          = var.worker_instance_type
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  desired_capacity       = var.worker_desired_capacity
  min_size               = var.worker_min_size
  max_size               = var.worker_max_size
  target_cpu_utilization = var.worker_target_cpu
  root_volume_size       = 30
  server_private_ip      = var.enable_compute_instance ? module.k3s_control_plane[0].private_ip : ""
  user_data = templatefile("${path.module}/userdata/k3s-worker.sh.tpl", {
    server_private_ip = var.enable_compute_instance ? module.k3s_control_plane[0].private_ip : ""
  })

  tags = var.tags
}
