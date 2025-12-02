output "queue_id" {
  description = "ID of the SQS queue"
  value       = aws_sqs_queue.main.id
}

output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.main.url
}

output "dlq_id" {
  description = "ID of the DLQ (if created)"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].id : null
}

output "dlq_arn" {
  description = "ARN of the DLQ (if created)"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_url" {
  description = "URL of the DLQ (if created)"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].url : null
}
