output "task_queue_url" {
  description = "URL of the task queue"
  value       = aws_sqs_queue.task.url
}

output "task_queue_arn" {
  description = "ARN of the task queue"
  value       = aws_sqs_queue.task.arn
}

output "result_queue_url" {
  description = "URL of the result queue"
  value       = aws_sqs_queue.result.url
}

output "result_queue_arn" {
  description = "ARN of the result queue"
  value       = aws_sqs_queue.result.arn
}

output "task_dlq_arn" {
  description = "ARN of the task dead letter queue"
  value       = aws_sqs_queue.task_dlq.arn
}

output "result_dlq_arn" {
  description = "ARN of the result dead letter queue"
  value       = aws_sqs_queue.result_dlq.arn
}
