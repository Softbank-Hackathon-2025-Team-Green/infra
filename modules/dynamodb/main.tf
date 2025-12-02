# DynamoDB Table
resource "aws_dynamodb_table" "main" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = lookup(global_secondary_index.value, "range_key", null)
      projection_type = global_secondary_index.value.projection_type
      read_capacity   = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", null) : null
      write_capacity  = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", null) : null
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  server_side_encryption {
    enabled = var.server_side_encryption
  }

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  tags = merge(
    var.tags,
    {
      Name = var.table_name
    }
  )
}
