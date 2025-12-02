variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "task_queue_name" {
  description = "Name of the task queue"
  type        = string
}

variable "result_queue_name" {
  description = "Name of the result queue"
  type        = string
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 1209600
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
