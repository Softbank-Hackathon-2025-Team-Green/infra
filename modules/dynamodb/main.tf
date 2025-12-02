# Function Metadata Table
resource "aws_dynamodb_table" "functions" {
  name           = "${var.project_name}-${var.environment}-${var.function_table_name}"
  billing_mode   = var.billing_mode
  hash_key       = "function_id"
  range_key      = "version"

  attribute {
    name = "function_id"
    type = "S"
  }

  attribute {
    name = "version"
    type = "N"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "user_id"
    range_key       = "function_id"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-functions"
    }
  )
}

# Execution Tracking Table
resource "aws_dynamodb_table" "executions" {
  name           = "${var.project_name}-${var.environment}-${var.execution_table_name}"
  billing_mode   = var.billing_mode
  hash_key       = "execution_id"

  attribute {
    name = "execution_id"
    type = "S"
  }

  attribute {
    name = "function_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  global_secondary_index {
    name            = "FunctionIdTimestampIndex"
    hash_key        = "function_id"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  ttl {
    enabled        = true
    attribute_name = "ttl"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-executions"
    }
  )
}

# Logs Table
resource "aws_dynamodb_table" "logs" {
  name           = "${var.project_name}-${var.environment}-${var.logs_table_name}"
  billing_mode   = var.billing_mode
  hash_key       = "execution_id"
  range_key      = "timestamp"

  attribute {
    name = "execution_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  ttl {
    enabled        = true
    attribute_name = "ttl"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-logs"
    }
  )
}
