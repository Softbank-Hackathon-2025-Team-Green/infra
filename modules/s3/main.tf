# Production Code Bucket
resource "aws_s3_bucket" "production" {
  bucket = "${var.project_name}-${var.environment}-code-prod-${var.account_id}"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-code-prod"
      Tier = "Production"
    }
  )
}

resource "aws_s3_bucket_versioning" "production" {
  bucket = aws_s3_bucket.production.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "production" {
  bucket = aws_s3_bucket.production.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "production" {
  bucket = aws_s3_bucket.production.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Development Code Bucket
resource "aws_s3_bucket" "development" {
  bucket = "${var.project_name}-${var.environment}-code-dev-${var.account_id}"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-code-dev"
      Tier = "Development"
    }
  )
}

resource "aws_s3_bucket_versioning" "development" {
  bucket = aws_s3_bucket.development.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "development" {
  bucket = aws_s3_bucket.development.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "development" {
  bucket = aws_s3_bucket.development.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Reserved Bucket
resource "aws_s3_bucket" "reserved" {
  bucket = "${var.project_name}-${var.environment}-reserved-${var.account_id}"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-reserved"
      Tier = "Reserved"
    }
  )
}

resource "aws_s3_bucket_versioning" "reserved" {
  bucket = aws_s3_bucket.reserved.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "reserved" {
  bucket = aws_s3_bucket.reserved.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "reserved" {
  bucket = aws_s3_bucket.reserved.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for production bucket
resource "aws_s3_bucket_lifecycle_configuration" "production" {
  bucket = aws_s3_bucket.production.id

  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.lifecycle_glacier_days
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_glacier_days
    }
  }
}
