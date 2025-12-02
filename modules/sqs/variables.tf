variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "delay_seconds" {
  description = "Delay in seconds for message delivery"
  type        = number
  default     = 0

  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "delay_seconds must be between 0 and 900"
  }
}

variable "max_message_size" {
  description = "Maximum message size in bytes"
  type        = number
  default     = 262144

  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144
    error_message = "max_message_size must be between 1024 and 262144"
  }
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds must be between 60 and 1209600"
  }
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds must be between 0 and 43200"
  }
}

variable "receive_wait_time_seconds" {
  description = "Wait time for ReceiveMessage calls (long polling)"
  type        = number
  default     = 10

  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "receive_wait_time_seconds must be between 0 and 20"
  }
}

variable "fifo_queue" {
  description = "Enable FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

variable "create_dlq" {
  description = "Create a dead letter queue"
  type        = bool
  default     = true
}

variable "dlq_message_retention_seconds" {
  description = "Message retention period for DLQ in seconds"
  type        = number
  default     = 1209600
}

variable "max_receive_count" {
  description = "Maximum number of receives before sending to DLQ"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
