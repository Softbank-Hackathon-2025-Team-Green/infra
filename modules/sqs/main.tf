# SQS Queue
resource "aws_sqs_queue" "main" {
  name                       = var.queue_name
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  fifo_queue                 = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  tags = merge(
    var.tags,
    {
      Name = var.queue_name
    }
  )
}

# Dead Letter Queue (optional)
resource "aws_sqs_queue" "dlq" {
  count = var.create_dlq ? 1 : 0

  name                      = "${var.queue_name}-dlq"
  message_retention_seconds = var.dlq_message_retention_seconds

  tags = merge(
    var.tags,
    {
      Name = "${var.queue_name}-dlq"
    }
  )
}

# Redrive Policy (optional)
resource "aws_sqs_queue_redrive_policy" "main" {
  count = var.create_dlq ? 1 : 0

  queue_url = aws_sqs_queue.main.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  })
}
