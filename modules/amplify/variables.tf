variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "repository_url" {
  description = "GitHub repository URL"
  type        = string
}

variable "access_token" {
  description = "GitHub access token"
  type        = string
  sensitive   = true
}

variable "branch_name" {
  description = "Git branch name"
  type        = string
  default     = "master"
}

variable "dev_branch_name" {
  description = "Git branch name"
  type        = string
  default     = "develop"
}


variable "build_spec" {
  description = "Custom build specification"
  type        = string
  default     = ""
}

variable "compute_role_arn" {
  description = "IAM SSR compute role ARN for Amplify"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for Amplify app"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
