variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (optional, uses AES256 if not provided)"
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules"
  type = list(object({
    id      = string
    enabled = bool
    prefix  = optional(string, "")
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration = optional(object({
      days = number
    }))
    noncurrent_version_expiration = optional(object({
      days = number
    }))
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
