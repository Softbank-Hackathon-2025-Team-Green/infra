variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "dynamodb_table_arns" {
  description = "ARNs of DynamoDB tables"
  type        = list(string)
  default     = []
}

variable "s3_bucket_arns" {
  description = "ARNs of S3 buckets"
  type        = list(string)
  default     = []
}

variable "sqs_queue_arns" {
  description = "ARNs of SQS queues"
  type        = list(string)
  default     = []
}

variable "ecr_repository_arn" {
  description = "ARN of ECR repository"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

variable "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool (for SSR role permissions)"
  type        = string
  default     = ""
}

variable "codebuild_project_arn" {
  description = "ARN of the CodeBuild project (for SSR role permissions)"
  type        = string
  default     = ""
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue for sending messages"
  type        = string
}
