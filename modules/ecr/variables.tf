variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "image_tag_mutability" {
  description = "Image tag mutability"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "lifecycle_max_image_count" {
  description = "Maximum number of images to retain"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
