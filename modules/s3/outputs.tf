output "production_bucket_name" {
  description = "Name of the production S3 bucket"
  value       = aws_s3_bucket.production.id
}

output "production_bucket_arn" {
  description = "ARN of the production S3 bucket"
  value       = aws_s3_bucket.production.arn
}

output "development_bucket_name" {
  description = "Name of the development S3 bucket"
  value       = aws_s3_bucket.development.id
}

output "development_bucket_arn" {
  description = "ARN of the development S3 bucket"
  value       = aws_s3_bucket.development.arn
}

output "reserved_bucket_name" {
  description = "Name of the reserved S3 bucket"
  value       = aws_s3_bucket.reserved.id
}

output "reserved_bucket_arn" {
  description = "ARN of the reserved S3 bucket"
  value       = aws_s3_bucket.reserved.arn
}
