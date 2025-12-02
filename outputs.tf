# ============================================
# VPC Outputs
# ============================================
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.vpc.private_subnet_id
}

# ============================================
# S3 Outputs
# ============================================
output "s3_production_bucket" {
  description = "Name of the production S3 bucket"
  value       = module.s3.production_bucket_name
}

output "s3_development_bucket" {
  description = "Name of the development S3 bucket"
  value       = module.s3.development_bucket_name
}

output "s3_reserved_bucket" {
  description = "Name of the reserved S3 bucket"
  value       = module.s3.reserved_bucket_name
}

# ============================================
# DynamoDB Outputs
# ============================================
output "dynamodb_functions_table" {
  description = "Name of the functions DynamoDB table"
  value       = module.dynamodb.functions_table_name
}

output "dynamodb_executions_table" {
  description = "Name of the executions DynamoDB table"
  value       = module.dynamodb.executions_table_name
}

output "dynamodb_logs_table" {
  description = "Name of the logs DynamoDB table"
  value       = module.dynamodb.logs_table_name
}

output "dynamodb_logs_stream_arn" {
  description = "ARN of the logs table stream"
  value       = module.dynamodb.logs_stream_arn
}

# ============================================
# SQS Outputs
# ============================================
output "sqs_task_queue_url" {
  description = "URL of the task queue"
  value       = module.sqs.task_queue_url
}

output "sqs_result_queue_url" {
  description = "URL of the result queue"
  value       = module.sqs.result_queue_url
}

# ============================================
# ECR Outputs
# ============================================
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

# ============================================
# IAM Outputs
# ============================================
output "faas_execution_role_arn" {
  description = "ARN of the FaaS execution role"
  value       = module.iam.faas_execution_role_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam.lambda_execution_role_arn
}

output "codebuild_role_arn" {
  description = "ARN of the CodeBuild role"
  value       = module.iam.codebuild_role_arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile for SSM"
  value       = module.iam.ec2_instance_profile_name
}

# ============================================
# CodeBuild Outputs
# ============================================
output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = module.codebuild.project_name
}

# ============================================
# Amplify Outputs
# ============================================
output "amplify_app_id" {
  description = "ID of the Amplify app"
  value       = module.amplify.app_id
}

output "amplify_default_domain" {
  description = "Default domain for the Amplify app"
  value       = module.amplify.default_domain
}

# ============================================
# NLB Outputs
# ============================================
output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = module.nlb.nlb_dns_name
}

output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = module.nlb.nlb_arn
}

# ============================================
# Security Group Outputs
# ============================================
output "faas_security_group_id" {
  description = "ID of the FaaS security group"
  value       = module.faas_sg.security_group_id
}

# ============================================
# EC2 Compute Outputs (if enabled)
# ============================================
output "compute_instance_id" {
  description = "ID of the compute instance"
  value       = var.enable_compute_instance ? module.compute[0].instance_id : null
}

output "compute_private_ip" {
  description = "Private IP of the compute instance"
  value       = var.enable_compute_instance ? module.compute[0].private_ip : null
}

# ============================================
# Auto Scaling Group Outputs (if enabled)
# ============================================
output "worker_asg_name" {
  description = "Name of the worker Auto Scaling Group"
  value       = var.enable_worker_asg ? module.worker_asg[0].autoscaling_group_name : null
}

output "worker_asg_arn" {
  description = "ARN of the worker Auto Scaling Group"
  value       = var.enable_worker_asg ? module.worker_asg[0].autoscaling_group_arn : null
}

# ============================================
# General Information
# ============================================
output "project_name" {
  description = "Name of the project"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}
