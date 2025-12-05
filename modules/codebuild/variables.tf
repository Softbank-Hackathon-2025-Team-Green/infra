variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "codebuild_role_arn" {
  description = "IAM role ARN for CodeBuild"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket for artifacts"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "compute_type" {
  description = "CodeBuild compute type"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "CodeBuild Docker image"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "timeout_minutes" {
  description = "Build timeout in minutes"
  type        = number
  default     = 60
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "sqs_queue_url" {
  description = "SQS task queue URL"
  type        = string
  default     = ""
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = ""
}

variable "amplify_domain" {
  description = "Amplify domain url"
}

variable "codebuild_source_location" {
  description = "CodeBuild source location (e.g. GitHub repo URL)"
  type        = string
}
