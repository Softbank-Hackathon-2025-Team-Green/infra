# Task Queue
resource "aws_sqs_queue" "task" {
  name                       = "${var.project_name}-${var.environment}-${var.task_queue_name}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = 10

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-task-queue"
    }
  )
}

# Task Dead Letter Queue
resource "aws_sqs_queue" "task_dlq" {
  name                      = "${var.project_name}-${var.environment}-${var.task_queue_name}-dlq"
  message_retention_seconds = 1209600  # 14 days

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-task-dlq"
    }
  )
}

resource "aws_sqs_queue_redrive_policy" "task" {
  queue_url = aws_sqs_queue.task.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.task_dlq.arn
    maxReceiveCount     = 3
  })
}

# Result Queue
resource "aws_sqs_queue" "result" {
  name                       = "${var.project_name}-${var.environment}-${var.result_queue_name}"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  receive_wait_time_seconds  = 10

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-result-queue"
    }
  )
}

# Result Dead Letter Queue
resource "aws_sqs_queue" "result_dlq" {
  name                      = "${var.project_name}-${var.environment}-${var.result_queue_name}-dlq"
  message_retention_seconds = 1209600

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-result-dlq"
    }
  )
}

resource "aws_sqs_queue_redrive_policy" "result" {
  queue_url = aws_sqs_queue.result.id

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.result_dlq.arn
    maxReceiveCount     = 3
  })
}
