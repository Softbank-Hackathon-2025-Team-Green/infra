output "functions_table_name" {
  description = "Name of the functions DynamoDB table"
  value       = aws_dynamodb_table.functions.name
}

output "functions_table_arn" {
  description = "ARN of the functions DynamoDB table"
  value       = aws_dynamodb_table.functions.arn
}

output "executions_table_name" {
  description = "Name of the executions DynamoDB table"
  value       = aws_dynamodb_table.executions.name
}

output "executions_table_arn" {
  description = "ARN of the executions DynamoDB table"
  value       = aws_dynamodb_table.executions.arn
}

output "logs_table_name" {
  description = "Name of the logs DynamoDB table"
  value       = aws_dynamodb_table.logs.name
}

output "logs_table_arn" {
  description = "ARN of the logs DynamoDB table"
  value       = aws_dynamodb_table.logs.arn
}

output "logs_stream_arn" {
  description = "ARN of the logs table stream"
  value       = aws_dynamodb_table.logs.stream_arn
}
