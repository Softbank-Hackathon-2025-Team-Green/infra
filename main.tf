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

# ============================================
# S3 Buckets
# ============================================
module "s3" {
  source = "./modules/s3"

  project_name           = var.project_name
  environment            = var.environment
  account_id             = data.aws_caller_identity.current.account_id
  enable_versioning      = var.enable_s3_versioning
  lifecycle_glacier_days = var.s3_lifecycle_glacier_days

  tags = var.tags
}

# ============================================
# DynamoDB Tables
# ============================================
module "dynamodb" {
  source = "./modules/dynamodb"

  project_name         = var.project_name
  environment          = var.environment
  function_table_name  = var.dynamodb_function_table
  execution_table_name = var.dynamodb_execution_table
  logs_table_name      = var.dynamodb_logs_table
  billing_mode         = var.dynamodb_billing_mode
  read_capacity        = var.dynamodb_read_capacity
  write_capacity       = var.dynamodb_write_capacity

  tags = var.tags
}

# ============================================
# SQS Queues
# ============================================
module "sqs" {
  source = "./modules/sqs"

  project_name               = var.project_name
  environment                = var.environment
  task_queue_name            = var.sqs_task_queue_name
  result_queue_name          = var.sqs_result_queue_name
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds

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
    module.dynamodb.functions_table_arn,
    module.dynamodb.executions_table_arn,
    module.dynamodb.logs_table_arn
  ]

  s3_bucket_arns = [
    module.s3.production_bucket_arn,
    module.s3.development_bucket_arn,
    module.s3.reserved_bucket_arn
  ]

  sqs_queue_arns = [
    module.sqs.task_queue_arn,
    module.sqs.result_queue_arn,
    module.sqs.task_dlq_arn,
    module.sqs.result_dlq_arn
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
      value       = module.sqs.task_queue_url
      type        = "String"
      description = "SQS task queue URL"
    }
    result_queue_url = {
      name        = null
      value       = module.sqs.result_queue_url
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
      value       = module.dynamodb.functions_table_name
      type        = "String"
      description = "DynamoDB functions table name"
    }
    executions_table = {
      name        = null
      value       = module.dynamodb.executions_table_name
      type        = "String"
      description = "DynamoDB executions table name"
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
  s3_bucket_name     = module.s3.production_bucket_name
  ecr_repository_url = module.ecr.repository_url
  compute_type       = var.codebuild_compute_type
  image              = var.codebuild_image
  timeout_minutes    = var.codebuild_timeout_minutes

  tags = var.tags
}

# ============================================
# Amplify (Conditional)
# ============================================
module "amplify" {
  source = "./modules/amplify"

  project_name   = var.project_name
  environment    = var.environment
  repository_url = var.amplify_repository_url
  access_token   = var.amplify_access_token
  branch_name    = var.amplify_branch_name
  build_spec     = var.amplify_build_spec

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
# EC2 Compute Instance (Optional - for management/testing)
# ============================================
module "compute" {
  count  = var.enable_compute_instance ? 1 : 0
  source = "./modules/ec2"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.private_subnet_id
  security_group_ids    = [module.faas_sg.security_group_id]
  instance_type         = var.compute_instance_type
  iam_instance_profile  = module.iam.ec2_instance_profile_name
  key_name              = var.ec2_key_name
  enable_public_ip      = false
  root_volume_size      = 30

  tags = var.tags
}

# ============================================
# Auto Scaling Group for FaaS Workers
# ============================================
module "worker_asg" {
  count  = var.enable_worker_asg ? 1 : 0
  source = "./modules/asg"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = [module.vpc.private_subnet_id]
  security_group_ids    = [module.faas_sg.security_group_id]
  instance_type         = var.worker_instance_type
  iam_instance_profile  = module.iam.ec2_instance_profile_name
  desired_capacity      = var.worker_desired_capacity
  min_size              = var.worker_min_size
  max_size              = var.worker_max_size
  target_cpu_utilization = var.worker_target_cpu
  root_volume_size      = 30

  tags = var.tags
}
