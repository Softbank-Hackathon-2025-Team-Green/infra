variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zone" {
  description = "Single availability zone for resources"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Multi-AZ
variable "additional_availability_zone" {
  description = "Extra AZ to create additional public/private subnets in"
  type        = string
  default     = []
}

variable "additional_public_subnet_cidr" {
  description = "CIDR block for additional public subnets (one per extra AZ)"
  type        = string
  default     = []
}

variable "additional_private_subnet_cidr" {
  description = "CIDR block for additional private subnets (one per extra AZ)"
  type        = string
  default     = []
}
