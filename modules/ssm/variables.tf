variable "project_name" {
  description = "Project name for parameter naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "parameters" {
  description = "Map of SSM parameters to create"
  type = map(object({
    value       = string
    type        = string
    description = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

