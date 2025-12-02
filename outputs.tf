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
  value       = module.s3_production.bucket_id
}

output "s3_production_bucket_arn" {
  description = "ARN of the production S3 bucket"
  value       = module.s3_production.bucket_arn
}

output "s3_development_bucket" {
  description = "Name of the development S3 bucket"
  value       = module.s3_development.bucket_id
}

output "s3_development_bucket_arn" {
  description = "ARN of the development S3 bucket"
  value       = module.s3_development.bucket_arn
}

output "s3_reserved_bucket" {
  description = "Name of the reserved S3 bucket"
  value       = module.s3_reserved.bucket_id
}

output "s3_reserved_bucket_arn" {
  description = "ARN of the reserved S3 bucket"
  value       = module.s3_reserved.bucket_arn
}

# ============================================
# DynamoDB Outputs
# ============================================
output "dynamodb_functions_table" {
  description = "Name of the functions DynamoDB table"
  value       = module.dynamodb_functions.table_name
}

output "dynamodb_functions_table_arn" {
  description = "ARN of the functions DynamoDB table"
  value       = module.dynamodb_functions.table_arn
}

output "dynamodb_executions_table" {
  description = "Name of the executions DynamoDB table"
  value       = module.dynamodb_executions.table_name
}

output "dynamodb_executions_table_arn" {
  description = "ARN of the executions DynamoDB table"
  value       = module.dynamodb_executions.table_arn
}

output "dynamodb_logs_table" {
  description = "Name of the logs DynamoDB table"
  value       = module.dynamodb_logs.table_name
}

output "dynamodb_logs_table_arn" {
  description = "ARN of the logs DynamoDB table"
  value       = module.dynamodb_logs.table_arn
}

output "dynamodb_logs_stream_arn" {
  description = "Stream ARN of the logs DynamoDB table"
  value       = module.dynamodb_logs.stream_arn
}

# ============================================
# SQS Outputs
# ============================================
output "sqs_task_queue_url" {
  description = "URL of the task queue"
  value       = module.sqs_task.queue_url
}

output "sqs_task_queue_arn" {
  description = "ARN of the task queue"
  value       = module.sqs_task.queue_arn
}

output "sqs_task_dlq_url" {
  description = "URL of the task DLQ"
  value       = module.sqs_task.dlq_url
}

output "sqs_result_queue_url" {
  description = "URL of the result queue"
  value       = module.sqs_result.queue_url
}

output "sqs_result_queue_arn" {
  description = "ARN of the result queue"
  value       = module.sqs_result.queue_arn
}

output "sqs_result_dlq_url" {
  description = "URL of the result DLQ"
  value       = module.sqs_result.dlq_url
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
# K3s Control Plane Outputs (if enabled)
# ============================================
output "k3s_control_plane_instance_id" {
  description = "ID of the K3s control plane instance"
  value       = var.enable_compute_instance ? module.k3s_control_plane[0].instance_id : null
}

output "k3s_control_plane_private_ip" {
  description = "Private IP of the K3s control plane instance"
  value       = var.enable_compute_instance ? module.k3s_control_plane[0].private_ip : null
}

output "k3s_control_plane_public_ip" {
  description = "Public IP of the K3s control plane instance"
  value       = var.enable_compute_instance ? module.k3s_control_plane[0].public_ip : null
}

# ============================================
# K3s Worker Nodes Outputs (if enabled)
# ============================================
output "k3s_worker_asg_name" {
  description = "Name of the K3s worker Auto Scaling Group"
  value       = var.enable_worker_asg ? module.k3s_worker[0].autoscaling_group_name : null
}

output "k3s_worker_asg_arn" {
  description = "ARN of the K3s worker Auto Scaling Group"
  value       = var.enable_worker_asg ? module.k3s_worker[0].autoscaling_group_arn : null
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
